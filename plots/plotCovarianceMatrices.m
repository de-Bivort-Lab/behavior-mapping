function plotCovarianceMatrices(jobTag,flyName,k)

% plotCovarianceMatrices(jobTag,flyName)
% Figure showing shape of covariance matrices for the given fly's PCA20 GMM results
%
% Inputs:
% jobTag [string]: folder where results can be found
% flyName [string]: tag for fly we're processing
% method [string]: mapping method to load, taken from p20gsw, t2w, p20g, t2g, p2w, p2g, r
%
% Figure 4A-B: plotCovarianceMatrices('tmRound1','f37_1',104)

% Load the given fly's PCA20 GMM results
vars=load(sprintf('~/results/%s/%s_pca20gmm_%s_%d.mat',jobTag,jobTag,flyName,k));
gmm=vars.gmm;

% Compute eigenvalues of each covariance matrix
NumDims=gmm.NumVariables;
EProds=zeros(k,1);
ENorms=zeros(k,NumDims);
for iCluster=1:k
    sigma=squeeze(gmm.Sigma(:,:,iCluster));
    E=eig(sigma);
    EProds(iCluster)=prod(E);
    ENorms(iCluster,:)=sort(E/sum(E),'descend');
end

figure;
subplot(121);
hist(log10(EProds),20);
xlabel('log10("volume")');
ylabel('count');
title(sprintf('%s/%s/k=%d: Distribution of cluster "volumes"',jobTag,flyName,k));

subplot(122);
plot(1:NumDims,ENorms);
hold on;
plot(1:NumDims,mean(ENorms,1),'r','LineWidth',2);
xlabel('dimension (sorted)');
ylabel('normalized std dev');
title(sprintf('%s/%s/k=%d: Normalized sorted std devs for all clusters',jobTag,flyName,k));
