function extractPairwiseClusterMeanDists(jobTag,k)

% extractPairwiseClusterMeanDists(jobTag,k)
% Extract pairwise distances between co-fit cluster means for fitting in Figure 5A
%
% Inputs:
% jobTag [string]: the results we use here
% k [double]: number of unmapped clusters in co-fit data set
%
% Figure 5A: extractPairwiseClusterMeanDists('coRound2',180)

vars=load(sprintf('~/results/%s/%s_pca20gmm_all_%d.mat',jobTag,jobTag,k));
gmm=vars.gmm;
dists=squareform(pdist(gmm.mu)); %#ok<NASGU>

save('~/results/fig5a_dists.mat','gmm','dists');
