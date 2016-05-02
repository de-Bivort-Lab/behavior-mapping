function tsnewshedRunSingleFlies(jobTag)

% tsnewshedRunSingleFlies(jobTag)
% Run t-SNE watershed clustering on all of our flies, use embedded values from previous t-SNE
% mapping run
%
% Inputs:
% jobTag [string]: folder where we store results, previous t-SNE mapping results must be stored here

flies=allFlies();
parfor iFly=1:length(flies)
    flyName=flies{iFly};

    % Load this fly's t-SNE mapping results and process them
    vars=load(sprintf('~/results/%s/%s_tm_%s.mat',jobTag,jobTag,flyName));
    embeddingValues=vars.embeddingValues;

    pathResult=sprintf('~/results/%s/%s_tsnewshed_%s.mat',jobTag,jobTag,flyName);
    tsnewshedSingleFly(embeddingValues,pathResult);
end
