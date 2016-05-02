function pcawshedMatchSWFlies(jobTag)

% pcawshedMatchSWFlies(jobTag)
% Run PCA2 watershed clustering on all of our flies, take k from previous PCA20 GMM sparse watershed mapping run
%
% Inputs:
% jobTag [string]: folder where we store results, previous PCA20 GMM sparse watershed results must be stored here

flies=allFlies();
parfor iFly=1:length(flies)
    flyName=flies{iFly};

    % Load this fly's sparse watershed mapping results, use its mapped k for our k
    files=dir(sprintf('~/results/%s/%s_pca20gmmswmapped_%s_*.mat',jobTag,jobTag,flyName));
    assert(length(files)==1);
    tokens=regexp(files(1).name,sprintf('^%s_pca20gmmswmapped_%s_(\\d+)\\.mat$',jobTag,flyName),'tokens');
    k=str2double(tokens{1}{1});
    assert(k>0);

    % Create our results path and process this fly
    pathResult=sprintf('~/results/%s/%s_pca2wshed_%s_%d.mat',jobTag,jobTag,flyName,k);
    pcawshedSingleFly(flyName,pathResult,k);
end
