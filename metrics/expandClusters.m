function clusters=expandClusters(flyName,hvclusters,includeLVFrames)

% clusters=expandClusters(flyName,hvclusters)
% Take the given high-variance clusters and produce cluster assignments for selected frames:
% -1 is an indeterminate cluster (when watershed returns a 0, indicating a point in the density map spans
% more than one watershed)
% 0 is the fixed cluster assignment for all low-variance frames
% 1:k we use these cluster labels for high-variance frames
%
% Inputs:
% flyName [string]: tag for fly whose clusters we're expanding
% hvclusters [NHighVarFrames x 1]: cluster assignments 1:k for high-variance frames
% includeLVFrames [bool]: whether we should expand our clusters to include all frames or just return high-variance cluster assignments

% Outputs:
% clusters [NSelectedFrames x 1]: cluster assignments -1:k for all frames


% Replace watershed indeterminate clusters with -1
hvclusters(hvclusters==0)=-1;

% Check whether we're expanding to include low-variance frames
if includeLVFrames
    % Load the given fly's high and low variance indices
    [iHighVarFrames,iLowVarFrames]=loadVarThreshold(flyName);

    % Use zeroes for low-variance frames
    NFrames=length(iHighVarFrames)+length(iLowVarFrames);
    clusters=zeros(NFrames,1);
    assert(length(iHighVarFrames)==length(hvclusters));
    clusters(iHighVarFrames)=hvclusters;
else
    % Just return high-variance frames
    clusters=hvclusters;
end

