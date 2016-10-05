function seqs=labelSequences(clusters)

% seqs=labelSequences(clusters)
% Split the given cluster assignments into a set of sequence assignments. A sequence is a group of consecutive frames with the
% same cluster assignment. For each cluster we identify all sequences, and then assign numbers to sequences longest-to-shortest.
% This way we can render movies with the longest sequences from each cluster by taking the first N sequences from each cluster
%
% Inputs:
% clusters [NFrames x 1]: expanded cluster assignments (0:k) for each frame
%
% Outputs:
% seqs [NFrames x 1]: sequence assignment for each frame

% Gather sequences for all clusters
clusters=clusters(:);
iChanges=find(diff(clusters));
allRunLengths=diff([0 iChanges' length(clusters)]);
allValues=clusters([iChanges' length(clusters)])';
allRunEnds=[iChanges' length(clusters)];
allRunStarts=allRunEnds-(allRunLengths-1);

% Process each cluster assignment separately
seqs=nan(length(clusters),1);
for cluster=unique(clusters)'
    % Grab sequences for this cluster
    iClusterSequences=find(allValues==cluster);
    runLengths=allRunLengths(iClusterSequences);
    runStarts=allRunStarts(iClusterSequences);
    runEnds=allRunEnds(iClusterSequences);
    
    % Label each sequence from longest to shortest
    [~,iRuns]=sort(runLengths,2,'descend');
    iSeq=1;
    for iRun=iRuns
        seqs(runStarts(iRun):runEnds(iRun))=iSeq;
        iSeq=iSeq+1;
    end
end

% We should have assigned every frame to a sequence
assert(all(isfinite(seqs)));
