function [m0ByFly,m1ByFly,m1All]=gatherMarkovCofit(jobTag,k)

% gatherMarkovCofit(jobTag,method)
% Gather Markov transition matrices for each of our flies PCA20-GMM-SW co-fit data
%
% Inputs:
% jobTag [string]: folder where results can be found
% k [double]: number of parent clusters in co-fit data to load
%
% Outputs:
% m0ByFly [NClusters+1 x NFlies double]: Zeroth-order Markov transition matrix (i.e. state occupancy histogram)
% m1ByFly [NClusters+1 x NClusters+1 x NFlies double]: First-order Markov transition matrix
% m1All [NClusters+1 x NClusters+1 double]: First-order Markov transition matrix averaged across all flies, then row-normalized again
%
% Figure 8E: [m0ByFly,m1ByFly,m1All]=gatherMarkovCotift('swRound1',40)

% Load our final clusters by fly
vars=load(sprintf('~/results/%s/%s_pca20gmmswmapped_all_%d.mat',jobTag,jobTag,k));
finalClustersByFly=vars.finalClustersByFly;

% Process each fly
flies=allFlies();
NFlies=length(flies);
m0ByFly=zeros(k+1,NFlies);
m1ByFly=zeros(k+1,k+1,NFlies);

for iFly=1:NFlies
    flyName=flies{iFly};
    fprintf('Processing %s (%d of %d)...\n',flyName,iFly,NFlies);
    
    % Compute Markov matrices for this fly
    hvclusters=finalClustersByFly(flyName);
    clusters=expandClusters(flyName,hvclusters,true);
    [m0,m1]=markovTransitionMatrices(k,clusters);
    assert(size(m0,1)==k+1 && size(m0,2)==1 && size(m1,1)==k+1 && size(m1,2)==k+1);
    
    m0ByFly(:,iFly)=m0;
    m1ByFly(:,:,iFly)=m1;
end

% Take average transition matrix, then row-normalize it again. Ignore nans here since flies may not have
% all states represented thus yielding nans in the transition matrices
m1All=squeeze(nanmean(m1ByFly,3));
rowSums=sum(m1All,2);
m1All=m1All./repmat(rowSums,1,k+1);
