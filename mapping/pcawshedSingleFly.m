function pcawshedSingleFly(flyName,pathResult,desiredK)

% pcawshedSingleFly(flyName,pathResult,desiredK)
% Run PCA-watershed clustering on a single fly
%
% Inputs:
% flyName [string]: tag for fly we're processing
% pathResult [string]: path to file where we save cluster assignments
% desiredK [double]: optional, if given then we search by varying sigma to attempt to yield the desired number of clusters
%
% Results:
% clusters [NHighVarFrames x 1]: cluster assignment (1:k) for each high-variance frame

% Load our high-variance frame-normalized wavelet data
hvfnData=loadHighVarFNData(flyName);

% PCA to 2 dims, this is our embedding
numPCs=2;
[~,score,latent]=pca(hvfnData);
explaineds=latent/sum(latent);
explained=sum(explaineds(1:numPCs));
fprintf('%s: %d PCs, %0.1f%% of variance explained\n',flyName,numPCs,explained*100);
scores=score(:,1:numPCs);
% Map to a max amplitude of 120 for consistency with our t-SNE mapping embedded values
embeddingValues=120*scores/max(scores(:));

% Find cluster assignments for these embedded values
if exist('desiredK','var')
    [~,~,~,~,clusters]=wshedProcess(embeddingValues,desiredK); %#ok<ASGLU>
else
    [~,~,~,~,clusters]=wshedProcess(embeddingValues); %#ok<ASGLU>
end

% Save results
save(pathResult,'clusters');
