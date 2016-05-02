function plotGMMPosteriorsCofit(jobTag,k)

% plotGMMPosteriorsCofit()
% Figure showing distribution of GMM posterior probability ratios for co-fit data
%
% Inputs:
% jobTag [string]: the results we use here
%
% Figure 4C: plotGMMPosteriorsCofit('coRound2',180)

% We hard-code 20 PCs here
numPCs=20;

% Gather data across all of our flies
pathCache=sprintf('~/results/%s/pmax_%d.mat',jobTag,k);
if exist(pathCache,'file')
    vars=load(pathCache);
    allPMax=vars.allPMax;
else
    % Gather training data
    allTrainingData=pcagmmAllFlies(sprintf('%s_%d',jobTag,k));
    allTrainingDataMean=mean(allTrainingData,1);

    % Load PCA coefficients used to cluster our data, re-apply PCA here. PCA mean-centers the data so
    % we do as well, see pcagmmAllFlies for details
    vars=load(sprintf('~/results/%s/%s_pca20gmm_all_%d.mat',jobTag,jobTag,k));
    gmm=vars.gmm;
    coeff=vars.coeff;
    allScores=(allTrainingData-repmat(allTrainingDataMean,size(allTrainingData,1),1))*coeff;
    clear allTrainingData  % clear this to save memory since the variable is quite large
    scores=allScores(:,1:numPCs);
    clear allScores  % clear this to save memory since the variable is quite large

    % Now compute posteriors for these data points which we clustered
    P=gmm.posterior(scores);
    allPMax=max(P,[],2);
    save(pathCache,'allPMax');
end

% Plot the distribution of maximum posterior probabilities
figure;
[n,x]=hist(allPMax,20);
bar(x,n/sum(n));
xlabel('max posterior');
ylabel('fraction of frames with max posterior < x');
title(sprintf('%s/k=%d GMM posterior probabilities for co-fit data',jobTag,k));

% Plot the cumulative distribution of maximum posterior probabilities
figure;
[n,x]=hist(allPMax,20);
bar(x,cumsum(n/sum(n)));
xlabel('max posterior');
ylabel('fraction of frames with max posterior < x');
title(sprintf('%s/k=%d GMM posterior probabilities (cumulative) for co-fit data',jobTag,k));
