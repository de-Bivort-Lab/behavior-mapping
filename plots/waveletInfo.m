function [scales,freqs]=waveletInfo()

% waveletInfo()
% Gather wavelet scales and their corresponding frequencies used in our wavelet transforms
%
% Outputs:
% scales [1 x 25 double]: wavelet scales used in our wavelet transform
% freqs [1 x 25 double]: frequencies corresponding to each wavelet scale

parameters=tsneSetParameters();
parameters.pcaModes=1;
[~,freqs,scales]=findWavelets([1 .4 .5 .2 0],parameters.pcaModes,parameters);

