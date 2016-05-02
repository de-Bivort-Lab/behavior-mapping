function randomMatchTMFlies(jobTag)

% randomMatchTMFlies(jobTag)
% Run random clustering on all of our flies, take k from previous t-SNE mapping run
%
% Inputs:
% jobTag [string]: folder where we store results, previous t-SNE mapping results must be stored here

for flyNameCell=allFlies()
    flyName=flyNameCell{1};

    % Load this fly's t-SNE mapping results, use its watershed count for our k
    vars=load(sprintf('~/results/%s/%s_tm_%s.mat',jobTag,jobTag,flyName));
    [~,numWatersheds]=wshedProcess(vars.embeddingValues);
    k=numWatersheds;

    % Create our results path and process this fly/k
    pathResult=sprintf('~/results/%s/%s_random_%s_%d.mat',jobTag,jobTag,flyName,k);
    randomSingleFly(flyName,k,pathResult);
end
