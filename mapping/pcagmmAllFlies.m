function allTrainingData=pcagmmAllFlies(jobTag)

% pcagmmAllFlies(jobTag)
% Run PCA20 GMM clustering on all of our flies simultaneously
%
% Inputs:
% jobTag [string]: folder where we store results, we extract k from the end of the jobTag
%                  e.g. tmRound1_104 becomes tmRound1 with k=104
%
% Outputs:
% allTrainingData [NTrainingFrames x NPrincipalComponents]: if given, we return our training data gathered across all flies
%                                                           and do not run PCA or GMM
%
% Results:
% gmm [gmdistribution]: Gaussian Mixture Model fit to PCA-compressed high-variance frame-normalized wavelet data
% clusters_by_fly [string -> NHighVarFrames x 1]: cluster assignment (1:k) for each high-variance frame, map keyed by fly name

% Based on the analysis in pcaShuffles we hard-code 20 PCs here across all flies
numPCs=20;

% Parse k from the given job tag
tokens=regexp(jobTag,'^(.*)_(\d+)$','tokens');
jobTag=tokens{1}{1};
k=str2double(tokens{1}{2});
pathResult=sprintf('~/results/%s/%s_pca20gmm_all_%d.mat',jobTag,jobTag,k);

% We set the training frames to the largest value for which we have computational resources
flies=allFlies();
NTrainingFrames=2000000;
NTrainingFramesPerFly=round(NTrainingFrames/length(flies));

% Load data for each fly, add to the training set. Note that we load high-dimensional data here so that we can take a single
% PCA across all flies below (we don't want to combine independent PCA results here)
allTrainingData=[];
for flyNameCell=flies
    flyName=flyNameCell{1};
    
    hvfnData=loadHighVarFNData(flyName);
    skipLength=round(size(hvfnData,1)/NTrainingFramesPerFly);
    trainingData=hvfnData(skipLength:skipLength:end,:);
    allTrainingData=[allTrainingData;trainingData]; %#ok<AGROW>
end

% Just return if we're providing our training data
if nargout==1
    return;
end

% Now take a PCA from our training data and save PCs, note that PCA mean-centers the data so we
% do the same here
[coeff,~,latent]=pca(allTrainingData);
allTrainingDataMean=mean(allTrainingData,1);
score=(allTrainingData-repmat(allTrainingDataMean,size(allTrainingData,1),1))*coeff;
cfspcData=score(:,1:numPCs);
    
% Print how much variance is explained by the PCs we're keeping
explaineds=latent/sum(latent);
explained=sum(explaineds(1:numPCs));
fprintf('%s: %0.1f%% of variance kept\n',jobTag,explained*100);

% Run GMM on the training data, note that we need a smaller regularization value than suggested in the documentation
% here (determined empirically)
fprintf('Running GMM on all flies, k=%d...\n',k);
startTime=clock();
gmm=fitgmdist(cfspcData,k,'RegularizationValue',1e-5,'Options',statset('MaxIter',1000,'Display','iter'));
fprintf('...ran GMM on all flies, k=%d, in %0.2f hours\n',k,etime(clock(),startTime)/3600);

% Now clear unneeded variables to save memory and to avoid referencing them below
clear hvfnData skipLength trainingData allTrainingData score cfspcData

% Now produce clusters using our mixture model
clusters_by_fly=containers.Map();
for flyNameCell=flies
    flyName=flyNameCell{1};
    % Load this fly's data and project it into our PCA space, note that we use the same mean-centering
    % adjustment (i.e. subtract the mean from all of the training data) here that we do above, so every fly's
    % data is embedded into the same PCA space
    hvfnFlyData=loadHighVarFNData(flyName);
    scoreFly=(hvfnFlyData-repmat(allTrainingDataMean,size(hvfnFlyData,1),1))*coeff;
    cfspcFlyData=scoreFly(:,1:numPCs);
    
    fprintf('GMM clustering on %s, k=%d...\n',flyName,k);
    startTime=clock();
    clusters_by_fly(flyName)=gmm.cluster(cfspcFlyData);
    fprintf('...finished GMM clustering %s - %d in %0.2f hours\n',flyName,k,etime(clock(),startTime)/3600);
end

% Save results
save(pathResult,'coeff','gmm','clusters_by_fly');
