function plotClusterRunLengths(jobTag,flyName,gmmk,plotClusters)

% plotClusterRunLengths(jobTag,flyName,gmmk,plotClusters)
% Plot distribution of run lengths for the given clusters
%
% Inputs:
% jobTag [string]: folder where PCA20 GMM results are stored
% flyName [string]: tag for fly whose data we want to load
% gmmk [double]: PCA20 GMM k value for which we plot posteriors and cluster assignments
% plotClusters [NPlotClusters x 1 double]: cluster assignments whose data we plot, empty means plot all clusters
%
% Figure S4: plotClusterRunLengths('swRound1','f37_1',72,[]);


% Load the given fly's raw and frame-normalized high variance data, expand with zeros for low-variance frames
if ~exist('dataNorm','var')
    vars=load(sprintf('~/results/%s/%s_pca20gmmswmapped_%s_%d.mat',jobTag,jobTag,flyName,gmmk));
    hvclusters=vars.finalClusters;
    clusters=expandClusters(flyName,hvclusters,true);
end

% Gather data for the given clusters
if isempty(plotClusters)
    plotClusters=1:max(clusters);
end
NPlotClusters=length(plotClusters);
runLengthsByCluster=cell(NPlotClusters,1);
clusterNums=zeros(NPlotClusters,1);
minLength=inf;
maxLength=-inf;
for iPlotCluster=1:NPlotClusters
    cluster=plotClusters(iPlotCluster);
    allMatchingFrames=find(clusters==cluster);
    runStarts=[1 find(diff(allMatchingFrames)>1)'+1];
    runEnds=[find(diff(allMatchingFrames)>1)' length(allMatchingFrames)];
    runLengths=runEnds-runStarts+1;
    runLengthsByCluster{iPlotCluster}=runLengths;
    clusterNums(iPlotCluster)=cluster;
    minLength=min([minLength runLengths]);
    maxLength=max([maxLength runLengths]);
end

% Plot run length distributions
edges=[linspace(.5,200.5,20) 210:50:maxLength+.5];
x=mean([edges(1:end-1);edges(2:end)],1);
figure;
hold on;
for iPlotCluster=1:NPlotClusters
    n=histcounts(runLengthsByCluster{iPlotCluster},edges);
    if clusterNums(iPlotCluster)==59
        plot(x,n,'Color','r','LineWidth',3);
    elseif clusterNums(iPlotCluster)==39
        plot(x,n,'Color','g','LineWidth',3);
    elseif clusterNums(iPlotCluster)==34
        plot(x,n,'Color','b','LineWidth',3);
    else
        plot(x,n,'Color',[.5 .5 .5]);
    end        
end
