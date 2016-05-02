function clusterDimEnergy=plotFrameEnergies(jobTag,flyName,k)

% clusterDimEnergy=plotFrameEnergies(jobTag,k,flyNames)
% Plot cluster energies by dimension for PCA20-GMM-SW on the given fly
%
% Inputs:
% jobTag [string]: folder where results can be found
% flyName [string]: tag for fly whose data we load
% k [double]: number of parent clusters in results to plot
%
% Outputs:
% clusterDimEnergy [k x NDims]: average energy per dimension for each cluster
%
% Figure 6B: plotFrameEnergies('swRound1','f37_1',72)

% Load clusterings for the given fly
vars=load(sprintf('~/results/%s/%s_pca20gmmswmapped_%s_%d.mat',jobTag,jobTag,flyName,k));
clusters=vars.finalClusters;

NDims=15;
clusterDimEnergy=zeros(k,NDims);

% Load this fly's high-variance frame-normalized wavelet data
hvfnData=loadHighVarFNData(flyName);
NScales=size(hvfnData,2)/NDims;

% Process each cluster
assert(length(clusters)==size(hvfnData,1));
for iCluster=1:k
   clusterData=hvfnData(clusters==iCluster,:);
   % Process each dim
   for iDim=1:NDims
       % Take CFS coefficients for this dim, sum across scales and take the mean across frames
       iFirst=1 + (iDim-1)*NScales;
       iLast=iFirst+NScales-1;
       dimData=clusterData(:,iFirst:iLast);
       assert(all(isfinite(dimData(:))));
       dimEnergy=mean(sum(dimData,2));
       clusterDimEnergy(iCluster,iDim)=dimEnergy;
   end       
end

figure;
DimNames=standardDimNames();
imagesc(clusterDimEnergy);
title(sprintf('%s PCA_2_0-GMM-SW: Energy by cluster and dim',flyName));
set(gca,'XTick',1:length(DimNames));
set(gca,'XTickLabels',DimNames);
ylabel('cluster number');
