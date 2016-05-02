function tsnewshedMatchSWFlies(jobTag)

% tsnewshedMatchSWFlies(jobTag)
% Run t-SNE2 watershed clustering on all of our flies, take k from previous PCA20 GMM sparse watershed mapping run
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

    % Load this fly's t-SNE mapping results
    vars=load(sprintf('~/results/%s/%s_tm2_%s.mat',jobTag,jobTag,flyName));
    embeddingValues=vars.embeddingValues;

    % Now run t-SNE2 watershed mapping with the desired value of k
    pathResult=sprintf('~/results/%s/%s_tsne2wshed_%s_%d.mat',jobTag,jobTag,flyName,k);
    tsnewshedSingleFly(embeddingValues,pathResult,k);
end
