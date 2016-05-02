function pca2gmmSingleFly(flyName,k,pathResult)

% pca2gmmSingleFly(flyName,k,pathResult)
% Run PCA2 GMM clustering on a single fly
%
% Inputs:
% flyName [string]: tag for fly we're processing
% k [double]: number of clusters to produce
% pathResult [string]: path to file where we save cluster assignments
%
% Results:
% clusters [NHighVarFrames x 1]: cluster assignment (1:k) for each high-variance frame

% Load our high-variance frame-normalized wavelet data
hvfnData=loadHighVarFNData(flyName);

% PCA to 2 dims
numPCs=2;
[~,score,latent]=pca(hvfnData);
explaineds=latent/sum(latent);
explained=sum(explaineds(1:numPCs));
fprintf('%s: %d PCs, %0.1f%% of variance explained\n',flyName,numPCs,explained*100);
scores=score(:,1:numPCs);

% Run GMM, note that we need a smaller regularization value than suggested in the documentation here (determined
% empirically)
fprintf('Running GMM on %s, k=%d...\n',flyName,k);
startTime=clock();
gmm=fitgmdist(scores,k,'RegularizationValue',1e-5,'Options',statset('MaxIter',1000,'Display','iter'));
fprintf('...ran GMM on %s, k=%d, in %0.2f hours\n',flyName,k,etime(clock(),startTime)/3600);

% Now produce clusters using our mixture model
fprintf('GMM clustering on %s, k=%d...\n',flyName,k);
startTime=clock();
clusters=gmm.cluster(scores); %#ok<NASGU>
fprintf('...finished GMM clustering %s - %d in %0.2f hours\n',flyName,k,etime(clock(),startTime)/3600);

% Save results
save(pathResult,'gmm','clusters');
