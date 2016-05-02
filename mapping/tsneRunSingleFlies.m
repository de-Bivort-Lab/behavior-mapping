function tsneRunSingleFlies(jobTag)

% tsneRunSingleFlies(jobTag)
% Run t-SNE mapping on all of our flies, use lockfiles for synchronization
%
% Inputs:
% jobTag [string]: folder where we store results, we extract the number of t-SNE dims from the end of the
%                  jobTag e.g. tmRound1_20 becomes tmRound1 with 20 dims

% Parse number of dims from the given job tag
tokens=regexp(jobTag,'^(.*)_(\d+)$','tokens');
jobTag=tokens{1}{1};
numEmbeddedDims=str2double(tokens{1}{2});

% The embedding step uses a parfor loop, so we have only one worker here
[numCores,slurmTaskID]=odysseyEnvInfo();
fprintf('SLURM %d | Running one outer worker, there are %d inner workers\n',slurmTaskID,numCores);

% Seed our random number generator with the SLURM task ID. This ensures that each node will
% have a different RNG state
rng(mod(round(abs(RandStream.shuffleSeed*round(slurmTaskID))),2^31));

% Look through all of the flies, process any unprocessed flies we encounter. Keep looping until we find
% no work to do
foundJob=true;
while foundJob
    foundJob=false;
    flies=allFlies();
    for iFly=randperm(length(flies))
        flyName=flies{iFly};

        % Create results and lockfile paths for this fly
        pathResult=sprintf('~/results/%s/%s_tm%d_%s.mat',jobTag,jobTag,numEmbeddedDims,flyName);
        pathLock=[pathResult '.lock'];
        
        % Check for a missing results file
        if ~exist(pathResult,'file')
            % Try to create and lock our lockfile, don't retry - if lockfile fails, we'll just go to the next file
            if ~system(sprintf('lockfile -r 0 %s',pathLock))
                foundJob=true;
                % We succeeded, so process this fly
                tsneProcess(flyName,numEmbeddedDims,pathResult,sprintf('SLURM %d | ',slurmTaskID));
                % Now remove the lockfile
                system(sprintf('rm -f %s',pathLock));
            end
        end

    end
end
