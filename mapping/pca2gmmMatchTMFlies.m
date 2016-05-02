function pca2gmmMatchTMFlies(jobTag)

% pca2gmmMatchTMFlies(jobTag)
% Run PCA2 GMM clustering on all of our flies, take k from previous t-SNE mapping run
%
% Inputs:
% jobTag [string]: folder where we store results

flies=allFlies();
parfor iFly=1:length(flies)
    flyName=flies{iFly};

    % Load this fly's t-SNE mapping results, use its watershed count for our k
    vars=load(sprintf('~/results/%s/%s_tm2_%s.mat',jobTag,jobTag,flyName));
    [~,numWatersheds]=wshedProcess(vars.embeddingValues);
    k=numWatersheds;

    % Create our results path and process this fly
    pathResult=sprintf('~/results/%s/%s_pca2gmm_%s_%d.mat',jobTag,jobTag,flyName,k);
    pca2gmmSingleFly(flyName,k,pathResult);
end
