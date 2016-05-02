function [markov0,markov1]=markovTransitionMatrices(numClusters,clusters)

% [markov0,markov1]=markovTransitionMatrices(numClusters,clusters)
% Compute 0th and 1st order Markov transition matrices
%
% Inputs:
% numClusters [double]: number of high-variance clusters in the data
% clusters [NFrames x 1]: cluster assignments, -1 means indeterminate cluster, 0 means low variance frame,
%                         the rest of the frames have values 1:numClusters
%
% Outputs:
% markov0 [NClusters+1 x 1 double]: 0th order transition probabilities, sums to 1
% markov1 [NClusters+1 x NClusters+1]: 1st order transition probabilities, element i,j is probability of transitioning
%                                      from cluster i-1 to j-1, rows sum to 1

% Sanity-check our cluster values
assert(all(clusters==round(clusters)));
assert(sum(clusters<-1)==0 && sum(clusters>numClusters)==0);
NValidFrames=sum(clusters~=-1);

% Compute 0th order probabilities
markov0Counts=zeros(numClusters+1,1);
for i=1:length(clusters)
    % Skip cluster assignment -1 (indeterminate cluster)
    if clusters(i)~=-1
        ai=clusters(i)+1;
        markov0Counts(ai)=markov0Counts(ai)+1;
    end
end

% Normalize 0th order probabilities
markov0=markov0Counts/NValidFrames;

% Compute 1st order probabilities (transitions from i to j)
counts=zeros(numClusters+1,numClusters+1);
for i=1:length(clusters)-1
    j=i+1;
    % Skip this transition if i or j is -1 (indeterminate cluster)
    if clusters(i) ~= -1 && clusters(j) ~= -1
        ai=clusters(i)+1;
        aj=clusters(j)+1;
        counts(ai,aj)=counts(ai,aj)+1;
    end
end

% Normalize each row to compute transition probabilities
rowSums=sum(counts,2);
markov1=counts./repmat(rowSums,1,numClusters+1);
