function distCofit=plotCofit(jobTag,jobTagSW,k)

% plotCofit(jobTag)
% Plot cluster size distribution for each fly for PCA20-GMM-SW co-fit data
%
% Inputs:
% jobTag [string]: folder containing PCA20-GMM results
% jobTagSW [string]: folder containing PCA20-GMM-SW results
% k [double]: original (not mapped) value of k for co-fit data
%
% Outputs:
% distCofit [NFlies x NParentClusters+1]: cluster instance distribution for each fly in co-fit data
%
% Figure 8A: plotCofit('coRound2','swRound1',180)

% Load PCA20 GMM results for co-fit data
vars=load(sprintf('~/results/%s/%s_pca20gmm_all_%d.mat',jobTag,jobTag,k));
clusters_by_fly=vars.clusters_by_fly;
gmm=vars.gmm;

% Load sparse watershed results, build map from child to parent clusters
vars=load(sprintf('~/results/%s/%s_pca20gmmsw_all_%d.mat',jobTagSW,jobTagSW,k));
results=vars.results;
parentClusters=zeros(k,1);
for iCluster=1:k
    parentClusters(iCluster)=gmm.cluster(results(iCluster).x);
end

% Renumber our parent clusters 1:NParents
origParents=unique(parentClusters);
NParents=length(origParents);
consolidatedClusters=zeros(k,1);
for iParent=1:NParents
    childClusters=find(parentClusters==origParents(iParent));
    consolidatedClusters(childClusters)=iParent; %#ok<FNDSB>
end

% Now create our cofit cluster counts using parent clusters
flies=allFlies();
numClusters=NParents+1;  % include low-variance cluster
distCofit=zeros(length(flies),numClusters);

for iFly=1:length(flies)
    flyName=flies{iFly};
    
    hvclusters=clusters_by_fly(flyName);
    clusters=expandClusters(flyName,hvclusters,true);
    
    % Map to our consolidated clusters
    cClusters=zeros(length(clusters),1);
    nonzeroClusters=clusters(clusters>0);
    cClusters(clusters>0)=consolidatedClusters(nonzeroClusters);
    assert(max(cClusters)==NParents);
    
    % We can optionally exclude low-variance frames here
    %cClusters(cClusters==0)=[];
    
    % Take histogram
    edges=-.5:1:NParents+.5;
    n=histcounts(cClusters,edges)/length(cClusters);
    distCofit(iFly,:)=n;
end

figure;
imagesc(log10(distCofit));
set(gca,'YTick',1:length(flies));
set(gca,'YTickLabel',flies);
colormap(cmapStandard1());
colorbar;
title(sprintf('cofit pca20gmm initialK=%d numParentClusters=%d',k,NParents));

% Now cluster rows and colums and plot again
figure;
dist1=pdist(distCofit);
link1=linkage(dist1);
[~,~,PERM1]=dendrogram(link1);

dist2=pdist(distCofit');
link2=linkage(dist2);
[~,~,PERM2]=dendrogram(link2,0);

imagesc(log10(distCofit(PERM1,PERM2)));
set(gca,'YTick',1:length(flies));
set(gca,'YTickLabel',flies(PERM1));
colormap(cmapStandard1());
colorbar;
title(sprintf('cofit pca20gmm initialK=%d numParentClusters=%d rows/columns clustered',k,NParents));
