function exitStates=metricExitStates(numClusters,clusters)

% exitStates=metricExitStates(clusters)
% Determine the mean number of exit states per cluster in the first-order Markov transition matrix
%
% Inputs:
% numClusters [double]: number of high-variance clusters in the data
% clusters [NFrames x 1]: cluster assignments, -1 means indeterminate cluster, 0 means low variance frame,
%                         the rest of the frames have values 1:numClusters
%
% Outputs:
% exitStates [double]: rank-weighted exit state count average across cluster, based on first-order Markov transition matrix

% Compute our 1st order transition matrix
[~,markov1]=markovTransitionMatrices(numClusters,clusters);

% Look at off-diagonal elements, sort them
weights=markov1+diag(inf(numClusters+1,1));
weights=sort(weights,2,'descend');
weights=weights(:,2:end);  % discard diagonal elements

% Take rank-weighted mean
rankWeighted=weights.*repmat(1:numClusters,numClusters+1,1);
means=sum(rankWeighted,2)./sum(weights,2);

% Return mean across clusters, ignore nans since some transitions have zero probability so we end up with nans in our transition matrix
exitStates=nanmean(means);
