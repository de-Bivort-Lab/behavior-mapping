function meanClusterDist=metricMeanClusterDist(numClusters,hvclusters,hvfnData)

% meanClusterDist=metricMeanClusterDist(numClusters,hvclusters,cfsdata)
% Measure mean distance to cluster mean in each high-variance cluster, return mean across all clusters
%
% Inputs:
% numClusters [double]: number of high-variance clusters in the data
% hvclusters [NHighVarFrames x 1]: high-variance cluster assignments, -1 means indeterminate cluster,
%                                  the rest of the frames have values 1:numClusters
% hvfnData [NHighVarFrames x NDims*NScales]: high-variance frame-normalized wavelet data, each row sums to 1
%
% Outputs:
% meanClusterDist [double]: mean across clusters of mean distance to cluster mean

% Compute a distance for each cluster
clusterDists=[];
for iCluster=1:numClusters
    % Find frames assigned to this cluster, note that we don't look at the indeterminate cluster here. Skip empty clusters
    clusterFrames=find(hvclusters==iCluster);
    if isempty(clusterFrames); continue; end
    
    % Grab wavelet data for each frame, compute the mean across frames
    clusterData=hvfnData(clusterFrames,:);
    clusterMean=mean(clusterData,1);
    
    % Compute distances to the cluster mean, then take the mean distance
    diffs=clusterData-repmat(clusterMean,size(clusterFrames,1),1);
    dists=sqrt(sum(diffs.*diffs,2));
    meanDist=mean(dists);
    clusterDists(end+1)=meanDist; %#ok<AGROW>
end

% Return the mean across all clusters
meanClusterDist=mean(clusterDists);
