function [numCores,slurmTaskID]=odysseyEnvInfo()

% odysseyEnvInfo()
% Return SLURM info from our environment: our core count for this node and our SLURM task id. In non-SLURM
% environments, return defaults for testing locally
%
% Outputs:
% numCores [double]: number of cores running on the local Odyssey node
% slurmTaskID [double]: unique ID for the local Odyssey node

numCoresString=getenv('SLURM_NTASKS_PER_NODE');
if isempty(numCoresString)
    numCores=2;  % just use a default value outside SLURM
else
    numCores=str2double(numCoresString);
end

slurmTaskIDString=getenv('SLURM_ARRAY_TASK_ID');
if isempty(slurmTaskIDString)
    slurmTaskID=1;  % just use a default value outside SLURM
else
    slurmTaskID=str2double(slurmTaskIDString);
end
