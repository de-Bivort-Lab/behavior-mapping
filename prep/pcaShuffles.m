function pcaShuffles()

% pcaShuffles()
% Compute number of PCs to keep from each fly's high-var frame-normalized wavelet data. We use
% the shuffling procedure described in the t-SNE mapping paper

for flyNameCell=allFlies()
    flyName=flyNameCell{1};
    
    hvfnData=loadHighVarFNData(flyName);
    NDims=size(hvfnData,2);

    % Compute PCA on the original data
    [~,~,latent]=pca(hvfnData);

    % Now shuffle each column independently and run PCA again
    shufdata=hvfnData;

    for dim=1:NDims
        orig=shufdata(:,dim);
        shufdata(:,dim)=orig(randperm(length(orig)));
    end
    [~,~,latentShuffled]=pca(shufdata);

    % Compute num PCs to keep, this is the number of eigenvalues greater than the greatest shuffled eigenvalue
    numPCs=find(latent>latentShuffled(1),1,'last');
    explaineds=latent/sum(latent);
    explained=sum(explaineds(1:numPCs));
    fprintf('%s: %d PCs, %0.1f%% of variance explained\n',flyName,numPCs,explained*100);

    save(sprintf('~/data/pca_shuffles/pca_shuffles_%s.mat',flyName),'latent','latentShuffled','numPCs','explained');
end
