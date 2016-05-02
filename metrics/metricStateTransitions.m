function [xCount,shortCount,meanDwell]=metricStateTransitions(clusters)

% [xCount,shortCount,meanDwell]=metricStateTransitions(clusters)
% Count state transitions in the given cluster assignments
%
% Inputs:
% clusters [NFrames x 1]: cluster assignments, -1 means indeterminate cluster, 0 means low variance frame,
%                         the rest of the frames have values 1:numClusters
%
% Outputs:
% xCount [double]: number of state transitions in the given cluster assignments, not counting transitions to/from
%                  the indeterminate cluster
% shortCount[double]: number of state transitions lasting 2 frames or less, not counting transitions to/from
%                     the indeterminate cluster
% meanDwell [double]: mean dwell time in each state, in frames, not counting transitions to/from the indeterminate cluster

% We consider dwell times with this many or fewer frames to be "short"
NShortFrames=2;

% Find run lengths and the value of each run
clusters=clusters(:);
iChanges=find(diff(clusters));
allRunLengths=diff([0 iChanges' length(clusters)]);
allValues=clusters([iChanges' length(clusters)])';

% Discard runs of -1 and runs just before/after -1 (indeterminate cluster)
prevValues=[allValues(1) allValues(1:end-1)];
nextValues=[allValues(2:end) allValues(end)];
validRuns=prevValues~=-1 & nextValues~=-1 & allValues~=-1;

runLengths=allRunLengths(validRuns);
values=allValues(validRuns);

xCount=length(values);
shortCount=sum(runLengths<=NShortFrames);
meanDwell=mean(runLengths);
