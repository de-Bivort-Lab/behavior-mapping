function tsnegmmSingleFly(flyName,embeddingValues,k,pathResult,outputPrefix)

% tsnegmmSingleFly(flyName,embeddingValues,k,pathResult,outputPrefix)
% Run t-SNE GMM clustering on a single fly
%
% Inputs:
% flyName [string]: tag for fly we're processing
% embeddingValues [NHighVarFrames x 2]: coords of high-variance frame-normalized data in t-SNE space
% k [double]: number of clusters to produce
% pathResult [string]: path to file where we save GMM and cluster assignments
% outputPrefix [string]: prefix added to all progress output, helps disambiguate from other jobs running in parallel
%
% Results:
% gmm [gmdistribution]: Gaussian Mixture Model fit to t-SNE embedded high-variance frame-normalized wavelet data
% hvclusters [NHighVarFrames x 1]: cluster assignment (1:k) for each high-variance frame

% Run GMM, note that we need a smaller regularization value than suggested in the documentation here (determined
% empirically)
fprintf('%sRunning GMM on %s, k=%d...\n',outputPrefix,flyName,k);
startTime=clock();
gmm=fitgmdist(embeddingValues,k,'RegularizationValue',1e-5,'Options',statset('MaxIter',1000,'Display','iter'));
fprintf('%s...ran GMM on %s, k=%d, in %0.2f hours\n',outputPrefix,flyName,k,etime(clock(),startTime)/3600);

% Now produce clusters using our mixture model
fprintf('%sGMM clustering on %s, k=%d...\n',outputPrefix,flyName,k);
startTime=clock();
hvclusters=gmm.cluster(embeddingValues); %#ok<NASGU>
fprintf('%s...finished GMM clustering %s - %d in %0.2f hours\n',outputPrefix,flyName,k,etime(clock(),startTime)/3600);

% Save results
save(pathResult,'gmm','hvclusters');
