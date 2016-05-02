function [hvfnData,cfsAmps,cfsData,iHighVarFrames,iLowVarFrames]=loadHighVarFNData(flyName)

% hvfn=loadHighVarData(flyName)
% Load high-variance frame-normalized wavelet data for the given fly
%
% Inputs:
% flyName [string]: tag for fly whose data we want to load
%
% Outputs:
% hvfnData [NHighVarFrames x NDims*NScales]: frame-normalized wavelet data, each row sums to 1, includes
%                                            only high-variance frames
% cfsAmps [NFrames x 1]: total wavelet amplitude (summed across dims) for each frame of data
% cfsData [NFrames x NDims*NScales]: unnormalized wavelet data, includes all frames
% iHighVarFrames [NHighVarFrames x 1]: indices of frames with high variance
% iLowVarFrames [NLowVarFrames x 1]: indices of frames with low variance

% Load CFS data, convert from single back to double, and frame-normalize it
vars=load(sprintf('~/data/cfs/cfsdata_%s.mat',flyName));
cfsData=double(vars.cfsdata);

allAmps=sum(cfsData,2);
fnData=bsxfun(@rdivide,cfsData,allAmps);

% Load our high-variance indices, return only high-variance data
[iHighVarFrames,iLowVarFrames]=loadVarThreshold(flyName);
hvfnData=fnData(iHighVarFrames,:);
cfsAmps=allAmps(iHighVarFrames);
