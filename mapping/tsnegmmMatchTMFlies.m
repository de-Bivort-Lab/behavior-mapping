function tsnegmmMatchTMFlies(jobTag)

% tsnegmmMatchTMFlies(jobTag)
% Run t-SNE GMM clustering on all of our flies, take k from previous t-SNE mapping run, use lockfiles for synchronization
%
% Inputs:
% jobTag [string]: folder where we store results, previous t-SNE mapping results must be stored here

% The GMM fit uses only one core, so we have an outer parfor loop here
[numCores,slurmTaskID]=odysseyEnvInfo();
fprintf('SLURM %d | Running outer parfor loop with %d workers\n',slurmTaskID,numCores);
parfor iParIndex=1:numCores
    % Seed our random number generator with the SLURM task ID and the parallel pool index. This ensures that each node will
    % have a different RNG state
    rng(mod(round(abs(RandStream.shuffleSeed*round(slurmTaskID)*iParIndex)),2^31));
    
    % Look through all of the flies, process any unprocessed flies we encounter. Keep looping
    % until we find no work to do
    foundJob=true;
    while foundJob
        foundJob=false;
        flies=allFlies();
        for iFly=randperm(length(flies))
            flyName=flies{iFly};
            
            % Load this fly's t-SNE mapping results, use its watershed count for our k
            vars=load(sprintf('~/results/%s/%s_tm_%s.mat',jobTag,jobTag,flyName));
            embeddingValues=vars.embeddingValues;
            [~,numWatersheds]=wshedProcess(embeddingValues);
            k=numWatersheds;
            
            % Create results and lockfile paths for this fly
            pathResult=sprintf('~/results/%s/%s_tsnegmm_%s_%d.mat',jobTag,jobTag,flyName,k);
            pathLock=[pathResult '.lock'];

            % Check for a missing results file
            if ~exist(pathResult,'file')
                % Try to create and lock our lockfile, don't retry - if lockfile fails, we'll just go to the next file
                if ~system(sprintf('lockfile -r 0 %s',pathLock))
                    foundJob=true;
                    % We succeeded, so process this fly/k
                    tsnegmmSingleFly(flyName,embeddingValues,k,pathResult,sprintf('SLURM %d | ',slurmTaskID));
                    % Now remove the lockfile
                    system(sprintf('rm -f %s',pathLock));
                end
            end
        end
    end
    
end
