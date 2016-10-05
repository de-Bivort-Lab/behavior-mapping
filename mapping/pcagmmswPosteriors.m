function pcagmmswPosteriors(jobTag,k,allTrainingData)

% pcagmmswPosteriors()
% Compute posterior probabilities for PC20-GMM-SW results
%
% Inputs:
% jobTag [string]: the results we use here
% k [double]: number of unmapped clusters in co-fit data set
%
% Example:
% pcagmmswPosteriors('swRound1')

% Gather training data
%allTrainingData=pcagmmAllFlies(sprintf('%s_%d',jobTag,k));
allTrainingDataMean=mean(allTrainingData,1);

% Load the GMM and PCA coefficients used to cluster our data
vars=load(sprintf('~/results/%s/%s_pca20gmm_all_%d.mat',jobTag,jobTag,k));
gmm=vars.gmm;
numPCs=gmm.NumVariables;
coeff=vars.coeff;
clear vars

% Our movies are 10 mins long so we only keep 10 mins of data below
[DataFrameRate,~]=dataAndMovieFrameRates();
NFrames=(60 * 10 + 1) * DataFrameRate;

% We only extract posteriors for flies for which we have movies
movieFilenames=allMovieFilenames();
flies=fieldnames(movieFilenames);
NFlies=length(flies);
for iFly=1:NFlies
    flyName=flies{iFly}

    % Load this fly's data, mean-center (see pcagmmAllFlies for details) and apply PCA transform, keep relevant PCs
    hvfnData=loadHighVarFNData(flyName);
    hvfnData=hvfnData(1:NFrames,:);
    
    allScores=(hvfnData-repmat(allTrainingDataMean,size(hvfnData,1),1))*coeff;
    scores=allScores(:,1:numPCs);
    clear allScores  % clear this to save memory since the variable is quite large

    % Now compute posteriors for data points covered by our movie
    P=gmm.posterior(scores); %#ok<NASGU>
    pathPost=sprintf('~/results/%s_post/%s_post_%s.mat',jobTag,jobTag,flyName);
    save(pathPost,'P');
end
