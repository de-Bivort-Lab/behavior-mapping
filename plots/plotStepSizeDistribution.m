function plotStepSizeDistribution(flyNames)

% plotStepSizeDistribution(flyNames)
% Plot the step size distribution in PCA20 space for the given fly
%
% Inputs:
% flyName [string]: tag for fly we're processing
%
% Figure S2: plotStepSizeDistribution(allFlies())

plotV=ceil(sqrt(length(flyNames)));
plotH=ceil(length(flyNames)/plotV);
figure;
for iFigure=1:length(flyNames)
    % Load this fly's PCA20 data
    flyName=flyNames{iFigure};
    cfspcData=loadCFSPCData(flyName);
    
    % Plot step size histogram, use log-log
    subplot(plotV,plotH,iFigure);
    diffs=diff(cfspcData);
    dists=sqrt(sum(diffs.*diffs,2));
    [n,x]=hist(log(dists),100);
    bar(x,log(n));
    xlim([-10 0]);
    title(flyName);
end
