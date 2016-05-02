function prepCFSPCData()
   
% prepCFSPCData()
% Prepare and save PCA-compressed high-variance frame-normalized wavelet data for all flies. We do this
% (as opposed to computing the PCA-compressed data from the HVFN data when we need it) in case PCA isn't
% fully deterministic across platforms (this wasn't observed)

% Based on the analysis in pcaShuffles we hard-code 20 PCs here across all flies
numPCs=20;

for flyNameCell=allFlies()
    flyName=flyNameCell{1};
    
    % Load HVFN data, take PCA and save PCs. We convert to single-precision here to save space on disk
    % and improve loading times
    hvfnData=loadHighVarFNData(flyName);
    [~,score,latent]=pca(hvfnData);
    cfspcData=single(score(:,1:numPCs)); %#ok<NASGU>
    save(sprintf('~/data/cfspc/cfspcdata_%s.mat',flyName),'cfspcData','-v7.3');
    
    % Print how much variance is explained by the PCs we're keeping
    explaineds=latent/sum(latent);
    explained=sum(explaineds(1:numPCs));
    fprintf('%s: %0.1f%% of variance kept\n',flyName,explained*100);
end
