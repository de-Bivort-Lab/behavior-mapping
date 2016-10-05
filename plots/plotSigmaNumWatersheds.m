function plotSigmaNumWatersheds(jobTag,flyNames)

% plotSigmaNumWatersheds(jobTag,flyName)
% Plot num watersheds vs sigma for the given job and fly
%
% Inputs:
% jobTag [string]: folder where we store results, previous PCA20 GMM sparse watershed results must be stored here
% flyName [string]: fly whose num watersheds vs sigma we want to plot
%
% Figure S5: plotSigmaNumWatersheds('tmRound1',allFlies())

% We plot for these values of sigma
sigmaDenoms=linspace(5,100,15);

plotV=ceil(sqrt(length(flyNames)));
plotH=ceil(length(flyNames)/plotV);
figure;
hold on;
for iFigure=1:length(flyNames)
    % Load this fly's t-SNE mapping results
    flyName=flyNames{iFigure};
    vars=load(sprintf('~/results/%s/%s_tm2_%s.mat',jobTag,jobTag,flyName));
    embeddingValues=vars.embeddingValues;
    
    % Run mapping with our values of sigma
    numWatersheds=zeros(length(sigmaDenoms),1);
    for iSigma=1:length(sigmaDenoms)
        [~,watersheds]=wshedProcess(embeddingValues,[],sigmaDenoms(iSigma));
        numWatersheds(iSigma)=watersheds;
    end

    %subplot(plotV,plotH,iFigure);
    plot(sigmaDenoms,numWatersheds);
end
title('num watersheds vs 1/sigma');
