function [dataNorm,cfsData,clusters]=plotClusterData(jobTag,flyName,gmmk,cluster,targetNumSlices,dataNorm,cfsData,clusters)

% [dataNorm,cfsData,clusters]=plotClusterData(jobTag,flyName,gmmk,cluster,targetNumSlices,dataNorm,cfsData,clusters)
% Plot time-domain and wavelet data with the given cluster assignments
%
% Inputs:
% jobTag [string]: folder where PCA20 GMM results are stored
% flyName [string]: tag for fly whose data we want to load
% gmmk [double]: PCA20 GMM k value for which we plot posteriors and cluster assignments
% cluster [double]: cluster assignment whose data we plot
% targetNumSlices [double]: we take up to this many slices of data, longest slices first
% dataNorm,cfsData,clusters: if provided this will speed up the render
%
% Outputs:
% dataNorm,cfsData,clusters: returned so they can be provided to speed up subsequent calls
%
% Figure 6D: plotClusterData('swRound1','f37_1',72,59,10,dataNorm,cfsData,clusters);
% Figure 6E: plotClusterData('swRound1','f37_1',72,39,10,dataNorm,cfsData,clusters);
% Figure 6F: plotClusterData('swRound1','f37_1',72,34,10,dataNorm,cfsData,clusters);

% Load the given fly's raw and frame-normalized high variance data, expand with zeros for low-variance frames
if ~exist('dataNorm','var')
    dataNorm=loadFlyData(flyName);
    NFrames=size(dataNorm,1);
    hvfnData=loadHighVarFNData(flyName);
    cfsData=zeros(NFrames,size(hvfnData,2));
    iHighVarFrames=loadVarThreshold(flyName);
    cfsData(iHighVarFrames,:)=hvfnData;

    vars=load(sprintf('~/results/%s/%s_pca20gmmswmapped_%s_%d.mat',jobTag,jobTag,flyName,gmmk));
    hvclusters=vars.finalClusters;
    clusters=expandClusters(flyName,hvclusters,true);
end

% Gather data for the given cluster, exclude runs less than minRunFrames
allMatchingFrames=find(clusters==cluster);
runStarts=[1 find(diff(allMatchingFrames)>1)'+1];
runEnds=[find(diff(allMatchingFrames)>1)' length(allMatchingFrames)];
runLengths=runEnds-runStarts+1;
[~,iAllRuns]=sort(runLengths,'descend');
iValidRuns=iAllRuns(1:min(length(iAllRuns),targetNumSlices));

clusterFrames=[];
for iValidRun=iValidRuns
    clusterFrames=[clusterFrames ; allMatchingFrames(runStarts(iValidRun):runEnds(iValidRun))]; %#ok<AGROW>
end
clusterDataNorm=dataNorm(clusterFrames,:);
clusterCFSData=cfsData(clusterFrames,:);

% Plot the given data
figure;
ax=axes();
plotFlyData(flyName,clusterDataNorm,clusterCFSData,[],ax);
title(sprintf('%s PCA_2_0 GMM SW k=%d cluster %d data',flyName,gmmk,cluster));
setFigureZoomMode(gcf,'h');

% Mark discontinuities in the data with a black line
markFrames=find(diff(clusterFrames)~=1);
X=[markFrames';markFrames'];
ylims=ylim;
Y=repmat([ylims(1);ylims(2)],1,length(markFrames));
line(X,Y,'LineWidth',1,'Color','k');
