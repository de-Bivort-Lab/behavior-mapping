function [iHighVarFrames,iLowVarFrames,varThreshold]=loadVarThreshold(flyName)

% [iHighVarFrames,iLowVarFrames,varThreshold]=loadVarThreshold(flyName)
% Load high/low-variance indices and the variance threshold for the given fly
%
% Inputs:
% flyName [string]: tag for fly whose data we want to load
%
% Outputs:
% iHighVarFrames [NHighVarFrames x 1]: indices of frames with high variance
% iLowVarFrames [NLowVarFrames x 1]: indices of frames with low variance
% varThreshold [double]: variance threshold for the given fly

vars=load(sprintf('~/data/varthresholds/varthreshold_%s.mat',flyName));
iHighVarFrames=vars.iHighVarFrames;
iLowVarFrames=vars.iLowVarFrames;
varThreshold=vars.varThreshold;
