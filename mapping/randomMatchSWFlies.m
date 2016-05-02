function randomMatchSWFlies(jobTag)

% randomMatchSWFlies(jobTag)
% Run random clustering on all of our flies, take k from previous PCA20 GMM sparse watershed mapping run
%
% Inputs:
% jobTag [string]: folder where we store results, previous PCA20 GMM sparse watershed mapping results must be stored here

for flyNameCell=allFlies()
    flyName=flyNameCell{1};

    % Load this fly's sparse watershed mapping results, use its mapped k for our k
    files=dir(sprintf('~/results/%s/%s_pca20gmmswmapped_%s_*.mat',jobTag,jobTag,flyName));
    assert(length(files)==1);
    tokens=regexp(files(1).name,sprintf('^%s_pca20gmmswmapped_%s_(\\d+)\\.mat$',jobTag,flyName),'tokens');
    k=str2double(tokens{1}{1});
    assert(k>0);

    % Create our results path and process this fly/k
    pathResult=sprintf('~/results/%s/%s_random_%s_%d.mat',jobTag,jobTag,flyName,k);
    randomSingleFly(flyName,k,pathResult);
end
