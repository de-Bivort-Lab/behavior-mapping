function entropy=metricEntropy(clusters)

% entropy=metricEntropy(clusters)
% Measure entropy in state distributions for the given sequence of cluster assignments
%
% Inputs:
% clusters [NFrames x 1]: cluster assignments, -1 means indeterminate cluster, 0 means low variance frame,
%                         the rest of the frames have values 1:numClusters
%
% Outputs:
% entropy [double]: entropy, in bits, of distribution of sample frequencies

% Just remove -1s (indeterminate cluster assignment)
clusters(clusters==-1)=[];

% Gather observed cluster assignments, calculate sample frequencies
symbols=unique(clusters);
freqs=zeros(size(symbols));
for iSymbol=1:length(symbols)
    freqs(iSymbol)=sum(clusters==symbols(iSymbol));
end

% Normalize
P=freqs/sum(freqs);

% Calculate entropy in bits
entropy=-sum(P.*log2(P));
