function [allClusters,numClusters,numP2WClusters]=loadClusters(jobTag,flyName,includeLVFrames)

% allClusters=loadClusters(jobTag,flyName)
% Load cluster data for the given job/fly
%
% Inputs:
% jobTag [string]: folder where results of t-SNE mapping (plus other clustering algorithms using the same k) can be found
% flyName [string]: tag for fly we're processing
% includeLVFrames [bool]: whether we should expand our clusters to include all frames or just return high-variance cluster assignments

% Outputs:
% allClusters [struct -> [NSelectedFrames x 1 double]]: Struct with mapping method abbreviations (e.g. t2w for t-SNE20 watershed) as
%                                                       field names and cluster assignments as values
% numClusters [double]: Number of clusters in our t-SNE2 watershed result, used as basis for k in other methods
% numP2WClusters [double]: Number of clusters in our PCA2 watershed result

% Load high-variance clusters from each of our clustering algorithms, adjust them to form cluster
% assignments for all frames
vars=load(sprintf('~/results/%s/%s_tsne2wshed_%s.mat',jobTag,jobTag,flyName));
numClusters=vars.numWatersheds;
hvclustersT2W=vars.hvclusters;
clustersT2W=expandClusters(flyName,hvclustersT2W,includeLVFrames);

vars=load(sprintf('~/results/%s/%s_pca20gmm_%s_%d.mat',jobTag,jobTag,flyName,numClusters));
hvclustersP20G=vars.clusters;
clustersP20G=expandClusters(flyName,hvclustersP20G,includeLVFrames);

vars=load(sprintf('~/results/%s/%s_tsne2gmm_%s_%d.mat',jobTag,jobTag,flyName,numClusters));
hvclustersT2G=vars.hvclusters;
clustersT2G=expandClusters(flyName,hvclustersT2G,includeLVFrames);

vars=load(sprintf('~/results/%s/%s_pca2wshed_%s.mat',jobTag,jobTag,flyName));
hvclustersP2W=vars.clusters;
numP2WClusters=max(vars.clusters);
clustersP2W=expandClusters(flyName,hvclustersP2W,includeLVFrames);

vars=load(sprintf('~/results/%s/%s_pca2gmm_%s_%d.mat',jobTag,jobTag,flyName,numClusters));
hvclustersP2G=vars.clusters;
clustersP2G=expandClusters(flyName,hvclustersP2G,includeLVFrames);

vars=load(sprintf('~/results/%s/%s_random_%s_%d.mat',jobTag,jobTag,flyName,numClusters));
hvclustersRandom=vars.clusters;
clustersRandom=expandClusters(flyName,hvclustersRandom,includeLVFrames);

allClusters=struct('t2w',clustersT2W,'p20g',clustersP20G,'t2g',clustersT2G,'p2w',clustersP2W,'p2g',clustersP2G,'r',clustersRandom);
