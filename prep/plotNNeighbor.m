function plotNNeighbor(jobTag)

% plotNNeighbor(jobTag)
% Plot nearest neighbor metrics for the given job, metrics must first be computed by runMetricNNeighbors()
%
% Inputs:
% jobTag [string]: folder where results t-SNE mapping (plus other clustering algorithms using the same k) can be found

% Load metrics for the given job
vars=load(sprintf('~/results/%s/nneighbors.mat',jobTag));
methodScoresByFly=vars.methodScoresByFly;
flies=methodScoresByFly.keys();
NFlies=length(flies);

% Show one sub-plot for each fly
plotv=2;
ploth=3;
NFigures=ceil(NFlies/(plotv*ploth));
for iFigure=1:NFigures
    figure;
    for iSubPlot=1:min(plotv*ploth,NFlies-(iFigure-1)*plotv*ploth)
        subplot(plotv,ploth,iSubPlot);
        iFly=plotv*ploth*(iFigure-1) + iSubPlot;
        flyName=flies{iFly};

        % Grab scores and plot them
        scores=methodScoresByFly(flyName);
        hold on;
        L=20; % length(scores.t2w)
        x=0:L-1;
        plot(x,scores.t2w(1:L));
        plot(x,scores.p20g(1:L));
        plot(x,scores.p20ga(1:L));
        plot(x,scores.t2g(1:L));
        plot(x,scores.p2w(1:L));
        plot(x,scores.r(1:L));
        legend('t-SNE2 watershed','PCA20 GMM','PCA20 GMM (co-fit)','t-SNE2 GMM','PCA2 watershed','Random');
        title(sprintf('%s P(nearest neighbor)',flyName));
    end
end
