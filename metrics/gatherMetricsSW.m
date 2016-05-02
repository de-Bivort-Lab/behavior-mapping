function gatherMetricsSW(jobTag)

% gatherMetricsSW(jobTag)
% Gather metrics comparing results from various clustering algorithms, use results from our sparse watershed mapping methods
%
% Inputs:
% jobTag [string]: folder where results can be found
%
% Results (saved in jobTag folder as metrics.mat):
% metricsByFly [Map]: map from flyName to metrics struct

% Gather infos about all of the dataset/fly/k combinations we want to analyze below
metricsByFly=containers.Map();
flies=allFlies();
for iFly=1:length(flies)
    flyName=flies{iFly};
    fprintf('Processing %s (%d of %d)...\n',flyName,iFly,length(flies));
    
    % Load our high-variance frame-normalized wavelet data
    hvfnData=loadHighVarFNData(flyName);
    
    % Load high-variance clusters from each of our clustering algorithms, adjust them to form cluster
    % assignments for all frames (so we include low-variance frames here)
    [allClusters,numClusters]=loadClustersSW(jobTag,flyName,true);
    allHVClusters=loadClustersSW(jobTag,flyName,false);
    
    % Compute each of our metrics
    xCounts=struct();
    shortCounts=struct();
    meanDwells=struct();
    meanClusterDists=struct();
    markovLLRs=struct();
    entropies=struct();
    exitStates=struct();
    
    for methodCell=fieldnames(allClusters)'
        method=methodCell{1};
        clusters=allClusters.(method);
        hvclusters=allHVClusters.(method);
        methodClusters=numClusters;
        
        [xCounts.(method),shortCounts.(method),meanDwells.(method)]=metricStateTransitions(clusters);
        meanClusterDists.(method)=metricMeanClusterDist(methodClusters,hvclusters,hvfnData);
        markovLLRs.(method)=metricMarkovLLRatio(methodClusters,clusters);
        entropies.(method)=metricEntropy(clusters);
        exitStates.(method)=metricExitStates(methodClusters,clusters);
    end
    
    % Store our metrics
    metrics=struct('xCounts',xCounts,'shortCounts',shortCounts,'meanDwells',meanDwells,'meanClusterDists',meanClusterDists,'markovLLRs',markovLLRs,'entropies',entropies,'exitStates',exitStates);
    metricsByFly(flyName)=metrics;
end

% Save results
pathResult=sprintf('~/results/%s/metrics.mat',jobTag);
save(pathResult,'metricsByFly');
