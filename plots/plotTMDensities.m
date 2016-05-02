function plotTMDensities(jobTag)

% plotTMDensities(jobTag)
% Plot t-SNE mapping densities for the given results
%
% Inputs:
% jobTag [string]: folder where results of t-SNE mapping can be found

% Plot results for all of our flies
plotv=3; ploth=3;
flies=allFlies();
numFigures=ceil(length(flies)/(ploth*plotv));

for iFigure=1:numFigures
    figure;
    for iSubPlot=1:min(plotv*ploth,length(flies)-(iFigure-1)*plotv*ploth)
        subplot(plotv,ploth,iSubPlot);
        iFly=plotv*ploth*(iFigure-1) + iSubPlot;
        flyName=flies{iFly};
        
        % Compute t-SNE density and plot it
        vars=load(sprintf('~/results/%s/%s_tm_%s.mat',jobTag,jobTag,flyName));
        embeddingValues=vars.embeddingValues;
        [watersheds,numWatersheds,xx,density]=wshedProcess(embeddingValues);
        plotTMDensity(watersheds,xx,density);
        
        title(sprintf('%s %s t-SNE mapping density (%d watersheds)',jobTag,flyName,numWatersheds));
    end
end
