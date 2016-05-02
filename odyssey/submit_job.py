#!/usr/bin/env python
"""Submit a job to Odyssey."""

from __future__ import print_function
import ipdb as pdb  # pylint: disable=W0611

import os
from random import randint
import sys


# This is where we write our jobs and result fetching script
SCRIPTS_FOLDER = '~/results/jobs'
# This is where we copy results .mat files
RESULTS_FOLDER = '~/results'

# We generate a batch script with the following template, then pass it to ssh to run on an odyssey
# node
JOB_TEMPLATE = '''
cat > ~/jobs/{job_name}_{job_id}.sh <<OUTER
#!/bin/bash

#SBATCH -n {num_cores}       #Number of cores
#SBATCH -N 1                 #Ensure that all cores are on one machine
#SBATCH --ntasks-per-node={num_cores}  #This sets SLURM_NTASKS_PER_NODE so MATLAB can see it
#SBATCH -t {runtime_minutes} #Runtime in minutes
#SBATCH -p general           #Partition to submit to
#SBATCH --mem={total_memory_mb}      #Total memory required in MB
#SBATCH -o {job_name}_%a_{job_id}.out      #File to which standard out will be written
#SBATCH -e {job_name}_%a_{job_id}.err      #File to which standard err will be written

# Create a local work directory
mkdir -p /scratch/$USER/{job_id}_\\${{SLURM_ARRAY_TASK_ID}}

# Create results folder
mkdir -p ~/results/{job_root_name}

# Now run MATLAB
matlab-default -nosplash -nodisplay <<EOF # Create a local work directory

% Create a local cluster object
pc = parcluster('local');
% Explicitly set the JobStorageLocation to the temp directory that was created above
pc.JobStorageLocation = ['/scratch/', getenv('USER'), '/{job_id}_', getenv('SLURM_ARRAY_TASK_ID')];
% Start the matlabpool with one worker per core, make sure the workers don't time out if we don't
% use them for a while
p=parpool(pc, {num_cores});
p.IdleTimeout=Inf;

% Compile MotionMapper's MEX files
cd ~/motifs/MotionMapper
compile_mex_files


% Set up our path
addpath(genpath('~/motifs'));
% Run our command
cd ~/motifs/{command_folder}
{command}('{job_name}');

% Clean up our parallel pool
poolobj = gcp('nocreate');
delete(poolobj);

exit

EOF

# Cleanup local work directory
rm -rf /scratch/$USER/{job_id}_\\${{SLURM_ARRAY_TASK_ID}}
OUTER

cd ~/jobs
sbatch --array=1-{array_size} ~/jobs/{job_name}_{job_id}.sh
'''

# This script runs our job script via ssh, entering our password and verification code for us
RUN_TEMPLATE = '''\
#!/usr/bin/expect -f

set config_fd [open "~/.odyssey" "r"]
gets $config_fd odyssey_username
gets $config_fd odyssey_password
gets $config_fd odyssey_secret

spawn ssh $odyssey_username@odyssey

expect {{
    "Password:" {{
        sleep 1
        send "$odyssey_password\r"
        exp_continue
    }} "Verification code:" {{
        sleep 1
        set verification_code [exec oathtool --totp --base32 $odyssey_secret]
        send "$verification_code\r"
        exp_continue
    }} "~]$ " {{
        set job_fd [open [glob {scripts_folder}/{job_name}_{job_id}.sh]]
        while {{[gets $job_fd line] != -1}} {{
            send "$line\\r"
        }}
        send "logout\\r"
        interact
    }}
}}
'''


def run(job_name, num_cores, gb_per_core, array_size, runtime_hours, command_folder, command):
    """Run our script with the given args."""

    # Generate a random job ID, we can't seem to access SLURM_JOB_ID from the above script so we
    # simply generate our own unique 8-digit integer here
    job_id = randint(10 ** 7, 10 ** 8 - 1)

    # Write our jobs script
    job_path = "{}/{}_{}.sh".format(SCRIPTS_FOLDER, job_name, job_id)
    job_script = JOB_TEMPLATE.format(job_name=job_name, job_root_name=job_name.split('_')[0],
                                     job_id=job_id, num_cores=num_cores,
                                     total_memory_mb=num_cores * gb_per_core * 1024,
                                     runtime_minutes=runtime_hours * 60, array_size=array_size,
                                     command_folder=command_folder, command=command)
    with open(os.path.expanduser(job_path), 'w') as f:
        f.write(job_script)

    # Write our run script
    run_path = "{}/run_{}_{}.sh".format(SCRIPTS_FOLDER, job_name, job_id)
    run_script = RUN_TEMPLATE.format(job_name=job_name, job_id=job_id,
                                     scripts_folder=SCRIPTS_FOLDER)
    with open(os.path.expanduser(run_path), 'w') as f:
        f.write(run_script)
    os.system("chmod u+x {}".format(run_path))

    # Now execute our run script
    os.system(run_path)


def parse():
    """Parse command-line args and run our command."""

    # Sanity-check args
    if len(sys.argv) != 8:
        print("Usage: {} <job_name> <num_cores> <gb_per_core> <array_size> <runtime_hours> "
              "<command_folder> <command>\n".
              format(sys.argv[0]))
        print("Example: {} sept13_1 8 32 27 120 feb5 run_test".
              format(sys.argv[0]))
    else:
        job_name, num_cores, gb_per_core, array_size, runtime_hours, command_folder, command = \
            sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]), int(sys.argv[5]), \
            sys.argv[6], sys.argv[7]
        print("Running job {} with:".format(job_name))
        print("{} cores".format(num_cores))
        print("{} GB memory per core (total = {} GB memory)".format(gb_per_core,
                                                                    num_cores * gb_per_core))
        print("{} job array size".format(array_size))
        print("{} runtime hours".format(runtime_hours))
        print("Command {}/{}('{}')".format(command_folder, command, job_name))
        run(sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]), int(sys.argv[5]),
            sys.argv[6], sys.argv[7])

if __name__ == '__main__':
    parse()
