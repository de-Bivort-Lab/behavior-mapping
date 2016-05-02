function markovLLR=metricMarkovLLRatio(numClusters,clusters)

% markovLLR=metricMarkovLLRatio(numClusters,clusters)
% Compute Markov order 1-0 log-likelihood ratio on the given sequence of cluster assignments
%
% Inputs:
% numClusters [double]: number of high-variance clusters in the data
% clusters [NFrames x 1]: cluster assignments, -1 means indeterminate cluster, 0 means low variance frame,
%                         the rest of the frames have values 1:numClusters
%
% Outputs:
% markovLLR [double]: log-likelihood ratio under Markov 1st and 0th order models

% Compute our 0th and 1st order transition matrices, take log
[markov0,markov1]=markovTransitionMatrices(numClusters,clusters);
markov0Log=log(markov0);
markov1Log=log(markov1);


% Compute likelihood score (probability of seeing this data given our model), in log space
score0=0;
score1=0;
for i=1:length(clusters)-1
    j=i+1;
    % Skip this transition if i or j is -1 (indeterminate cluster)
    if clusters(i)~=-1 && clusters(j)~=-1
        ai=clusters(i)+1;
        aj=clusters(j)+1;
        score0=score0+markov0Log(ai);
        score1=score1+markov1Log(ai,aj);
    end
end

% Return log-likelihood ratio between 1st and 0th order likelihoods
markovLLR=score1-score0;
