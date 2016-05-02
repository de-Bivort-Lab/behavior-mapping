function parameters=tsneSetParameters()

% parameters=tsneSetParameters()
% Set our standard t-SNE mapping parameters
%
% Outputs:
% parameters [t-SNE mapping params]: parameters which can be passed to t-SNE mapping functions

parameters=struct();
parameters.basisImagePath='~/motifs/MotionMapper/segmentation_alignment/basisImage.tiff';
parameters.trainingSetSize=30000;
parameters.pcaModes=15;
parameters=setRunParameters(parameters);
