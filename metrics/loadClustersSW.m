function [allClusters,numClusters]=loadClustersSW(jobTag,flyName,includeLVFrames)

% allClusters=loadClustersSW(jobTag,flyName)
% Load cluster data for the given job/fly, uses our sparse watershed mapping results
%
% Inputs:
% jobTag [string]: folder where results can be found
% flyName [string]: tag for fly we're processing
% includeLVFrames [bool]: whether we should expand our clusters to include all frames or just return high-variance cluster assignments

% Outputs:
% allClusters [struct -> [NSelectedFrames x 1 double]]: Struct with mapping method abbreviations (e.g. t2w for t-SNE20 watershed) as
%                                                       field names and cluster assignments as values
% numClusters [double]: Number of clusters in our PCA20 GMM sparse watershed result, used as basis for k in other methods

% Load this fly's sparse watershed mapping results, use its mapped k for our k
files=dir(sprintf('~/results/%s/%s_pca20gmmswmapped_%s_*.mat',jobTag,jobTag,flyName));
assert(length(files)==1);
tokens=regexp(files(1).name,sprintf('^%s_pca20gmmswmapped_%s_(\\d+)\\.mat$',jobTag,flyName),'tokens');
numClusters=str2double(tokens{1}{1});
assert(numClusters>0);

% Load high-variance clusters from each of our clustering algorithms, adjust them to form cluster
% assignments for all frames
vars=load(sprintf('~/results/%s/%s_pca20gmmswmapped_%s_%d.mat',jobTag,jobTag,flyName,numClusters));
hvclustersP20GSW=vars.finalClusters;
clustersP20GSW=expandClusters(flyName,hvclustersP20GSW,includeLVFrames);

vars=load(sprintf('~/results/%s/%s_tsne2wshed_%s_%d.mat',jobTag,jobTag,flyName,numClusters));
hvclustersT2W=vars.hvclusters;
clustersT2W=expandClusters(flyName,hvclustersT2W,includeLVFrames);

vars=load(sprintf('~/results/%s/%s_pca20gmm_%s_%d.mat',jobTag,jobTag,flyName,numClusters));
hvclustersP20G=vars.clusters;
clustersP20G=expandClusters(flyName,hvclustersP20G,includeLVFrames);

vars=load(sprintf('~/results/%s/%s_tsne2gmm_%s_%d.mat',jobTag,jobTag,flyName,numClusters));
hvclustersT2G=vars.hvclusters;
clustersT2G=expandClusters(flyName,hvclustersT2G,includeLVFrames);

vars=load(sprintf('~/results/%s/%s_pca2wshed_%s_%d.mat',jobTag,jobTag,flyName,numClusters));
hvclustersP2W=vars.clusters;
clustersP2W=expandClusters(flyName,hvclustersP2W,includeLVFrames);

vars=load(sprintf('~/results/%s/%s_pca2gmm_%s_%d.mat',jobTag,jobTag,flyName,numClusters));
hvclustersP2G=vars.clusters;
clustersP2G=expandClusters(flyName,hvclustersP2G,includeLVFrames);

vars=load(sprintf('~/results/%s/%s_random_%s_%d.mat',jobTag,jobTag,flyName,numClusters));
hvclustersRandom=vars.clusters;
clustersRandom=expandClusters(flyName,hvclustersRandom,includeLVFrames);

allClusters=struct('p20gsw',clustersP20GSW,'t2w',clustersT2W,'p20g',clustersP20G,'t2g',clustersT2G,'p2w',clustersP2W,'p2g',clustersP2G,'r',clustersRandom);
