function tsneProcess(flyName,numEmbeddedDims,pathResult,outputPrefix)

% tsneProcess(flyName,pathResult,outputPrefix)
% Run t-SNE mapping on a single fly
%
% Inputs:
% flyName [string]: tag for fly we're processing
% numEmbeddedDims [double]: number of dimensions in the t-SNE embedded space
% pathResult [string]: path to file where we save training and embedding data from t-SNE mapping
% outputPrefix [string]: prefix added to all progress output, helps disambiguate from other jobs running in parallel
%
% Results:
% trainingEmbedding [NTrainingFrames x 2]: x,y coords for each training data point in the t-SNE space
% betas [NTrainingFrames x 1]: local region size for each training data point (see MotionMapper for details)
% P [NTrainingFrames x NTrainingFrames]: transition matrix for training set (see MotionMapper for details)
% errors [NIterations x 1]: errors as a function of t-SNE iteration (see MotionMapper for details)
% embeddingValues [NFrames x 2]: x,y coords for each data point in the t-SNE space
% outputStatistics [struct]: describes embedding outputs (see MotionMapper for details)

% Set t-SNE mapping params
parameters=tsneSetParameters();
parameters.num_tsne_dim=numEmbeddedDims;

% Load our high-variance frame-normalized wavelet data
[hvfnData,cfsAmps]=loadHighVarFNData(flyName);

% Prepare training set, label points by their wavelet amplitude
skipLength=round(size(hvfnData,1)/parameters.trainingSetSize);

trainingSetData=hvfnData(skipLength:skipLength:end,:);
trainingAmps=cfsAmps(skipLength:skipLength:end);
parameters.signalLabels=log10(trainingAmps);

% Run our t-SNE training
fprintf('%sFinding t-SNE embedding for %s training set...\n',outputPrefix,flyName);
startTime=clock();
[trainingEmbedding,betas,P,errors]=run_tSne(trainingSetData,parameters); %#ok<ASGLU>
fprintf('%s...found t-SNE embedding for %s training set in %0.2f hours\n',outputPrefix,flyName,etime(clock(),startTime)/3600);

% Run our t-SNE embedding
fprintf('%sFinding t-SNE embedding for %s data set...\n',outputPrefix,flyName);
startTime=clock();
[embeddingValues,outputStatistics]=findEmbeddings(hvfnData,trainingSetData,trainingEmbedding,parameters); %#ok<ASGLU>
fprintf('%s...found t-SNE embedding for %s data set in %0.2f hours\n',outputPrefix,flyName,etime(clock(),startTime)/3600);

% Save results
save(pathResult,'trainingEmbedding','betas','P','errors','embeddingValues','outputStatistics');
