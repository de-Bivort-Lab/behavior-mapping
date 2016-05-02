function pcagmmswRunSingleFlies(jobTag)

% pcagmmswRunSingleFlies(jobTag)
% Run PCA20 GMM sparse watershed (all data points) clustering on all of our flies, use lockfiles for synchronization
%
% Inputs:
% jobTag [string]: folder where we store results, we extract k from the end of the jobTag
%                  e.g. tmRound1_104 becomes tmRound1 with k=104

% Parse k from the given job tag
tokens=regexp(jobTag,'^(.*)_(\d+)$','tokens');
jobTag=tokens{1}{1};
flyk=str2double(tokens{1}{2});

% We want to process all flies with the given k
jobs=struct();
flies=allFlies();
for iFly=1:length(flies)
    jobs(iFly).flyName=flies{iFly};
    jobs(iFly).k=flyk;
end

% Add our co-fit flies with specific k's
job.flyName='all';
allks=[60 90 120 160 180 250 300 400 500];
for allk=allks
    job.k=allk;
    if isempty(fieldnames(jobs))
        jobs=job;
    else
        jobs(end+1)=job; %#ok<AGROW>
    end
end

% The GMM fit uses only one core, so we have an outer parfor loop here
[numCores,slurmTaskID]=odysseyEnvInfo();
fprintf('SLURM %d | Running outer parfor loop with %d workers\n',slurmTaskID,numCores);
parfor iParIndex=1:numCores
    % Seed our random number generator with the SLURM task ID and the parallel pool index. This ensures that each node will
    % have a different RNG state
    rng(mod(round(abs(RandStream.shuffleSeed*round(slurmTaskID)*iParIndex)),2^31));
    
    % Look through all of the flies, process any unprocessed flies we encounter. Keep looping until we find no work to do
    foundJob=true;
    while foundJob
        foundJob=false;
        for iJob=randperm(length(jobs))
            job=jobs(iJob);

            % Create results and lockfile paths for this fly
            pathResult=sprintf('~/results/%s/%s_pca20gmmsw_%s_%d.mat',jobTag,jobTag,job.flyName,job.k);
            pathLock=[pathResult '.lock'];

            % Check for a missing results file
            if ~exist(pathResult,'file')
                % Try to create and lock our lockfile, don't retry - if lockfile fails, we'll just go to the next file
                if ~system(sprintf('lockfile -r 0 %s',pathLock))
                    foundJob=true;
                    % We succeeded, so process this fly/k
                    pcagmmswSingleFly(jobTag,job.flyName,job.k,pathResult);

                    % Now remove the lockfile
                    system(sprintf('rm -f %s',pathLock));
                end
            end
        end
    end
    
end
