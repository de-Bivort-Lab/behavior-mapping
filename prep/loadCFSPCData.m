function cfspcData=loadCFSPCData(flyName)

% cfspcData=loadCFSPCData(flyName)
% Load PCA-compressed high-variance frame-normalized wavelet data for the given fly
%
% Inputs:
% flyName [string]: tag for fly whose data we want to load
%
% Outputs:
% cfspcData [NHighVarFrames x NPrincipalComponents]: PCA-compressed frame-normalized wavelet data, includes
%                                                    only high-variance frames

% Load PCA-compressed data, convert from single back to double
vars=load(sprintf('~/data/cfspc/cfspcdata_%s.mat',flyName));
cfspcData=double(vars.cfspcData);
