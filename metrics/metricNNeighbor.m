function methodScores=metricNNeighbor(jobTag,flyName,showFigures)

% metricNNeighbor(jobTag,flyName)
% Compute P(ij in same clusters | j is l'th nearest neighbor of i) for the given job/fly. We only
% analyze high-variance frames when computing this since low-variance frames aren't submitted to the
% clustering methods
%
% Inputs:
% jobTag [string]: folder where results of t-SNE mapping (plus other clustering algorithms using the same k) can be found
% flyName [string]: tag for fly we're processing
% showFigures [bool]: if set we show figures as we compute values, this is useful for tuning NRandomPoints below
%
% Outputs:
% methodScores [struct -> [NRandomPoints x L]]: struct with fieldnames as abbreviations for methods, values are scores for
%                                               randomly sampled points

% This is the number of points we sample from each cluster, found empirically (increase until results converge)
NSamplesPerCluster=100;
% We return the first L nearest neighbors, we set this higher than we need to plot
L=10000;

% Load cluster assignments for the given fly, don't include low-variance frames. Also load high-variance data
allClusters=loadClusters(jobTag,flyName,false);
hvfnData=loadHighVarFNData(flyName);
NFrames=size(hvfnData,1);

% Process each mapping method
methods=fieldnames(allClusters);
methodScores=struct();

if showFigures
    plotv=round(sqrt(length(methods)));
    ploth=ceil(length(methods)/plotv);
    figure;
end

for iMethod=1:length(methods)    
    % Grab clusters for this mapping method
    clusters=allClusters.(methods{iMethod});
    assert(length(clusters)==NFrames);
    
    % Discard clusters with less than NSamplesPerCluster points
    edges=.5:1:max(clusters)+.5;
    n=histcounts(clusters,edges);
    iValidClusters=find(n>=NSamplesPerCluster);
    NValidClusters=length(iValidClusters);
    fprintf('Mapping method %s (%d of %d): %d valid clusters\n',methods{iMethod},iMethod,length(methods),NValidClusters);
    
    % Sample NRandomPoints random points
    scores=zeros(L,1);
    
    if showFigures
        for iValidClusterIndex=1:NValidClusters
            fprintf('Processing %d of %d...\n',iValidClusterIndex,NValidClusters);
            iValidCluster=iValidClusters(iValidClusterIndex);
            scores=scores+computeScores(NSamplesPerCluster,L,hvfnData,clusters,iValidCluster);

            % Plot results so far
            subplot(plotv,ploth,iMethod);
            plot(0:L-1,scores/(iValidClusterIndex*NSamplesPerCluster));
            title(sprintf('%s %s %s: P(ij same | L''th nn) vs L (sampling %d of %d clusters)',jobTag,flyName,methods{iMethod},iValidClusterIndex,NValidClusters));
            xlabel('L');
            ylabel('P(ij same | L''th nn)');
            drawnow;
        end
    else
        % Use a parfor since we're not plotting figures
        parfor iValidClusterIndex=1:NValidClusters
            iValidCluster=iValidClusters(iValidClusterIndex);
            scores=scores+computeScores(NSamplesPerCluster,L,hvfnData,clusters,iValidCluster);
        end
    end
    
    % Average over iterations to convert to a probability, save scores for this method
    methodScores.(methods{iMethod})=scores/(NValidClusters*NSamplesPerCluster);
end
end

function clusterScores=computeScores(NSamplesPerCluster,L,hvfnData,clusters,iCluster)
    % Compute pairwise distances between the given cluster and all other points, then count instances
    % where the l'th nearest neighbor is in the same cluster

    clusterMembers=find(clusters==iCluster);
    sampleFrames=datasample(clusterMembers,NSamplesPerCluster,'Replace',false);
    
    clusterScores=zeros(L,1);
    dists=pdist2(hvfnData(sampleFrames,:),hvfnData);
    
    for iSampleFrame=1:length(sampleFrames)
        [~,inds]=sort(dists(iSampleFrame,:));
        neighborClusters=clusters(inds(1:L));
        clusterScores=clusterScores+(neighborClusters==clusters(sampleFrames(iSampleFrame)));
    end
end
