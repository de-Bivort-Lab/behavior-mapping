function [dataNorm,viData,viFieldNames,dataFieldNames,dataPreNorm]=loadFlyData(flyName)

% dataNorm=loadFlyData(flyName)
% Load the given fly's raw data and preprocess it, return NFramesx15 data matrix
%
% Inputs:
% flyName [string]: tag for fly whose data we want to load
%
% Outputs:
% dataNorm [NFrames x NDims]: prepped data, z-scored along each dim independently, NaNs cleared
% viData [NFrames x 29]: frame index, timestamp (ms), leg X 1-6, leg Y 1-6, leg R1-3, leg Theta1-3, leg R4-6, leg Theta4-6, ball i/j/k
% viFieldNames [27 x 1 string]: dimension names for each field in viData
% dataFieldNames [12 x 1 string]: dimension names for each field in dataStruct
% dataPreNorm [NFrames x NDims]: dataNorm prior to z-scoring, NaNs not cleared

% Example:
% dataNorm=loadFlyData('f37_1')

% Load VI data from .txt file or all data .mat file
if strcmp(flyName(1:min(4,length(flyName))),'f130')
    viData=importdata(sprintf('~/data/raw/%s.txt',flyName));
else
    rawDataStruct=load('~/data/raw/legTrackerAllRawData.mat',flyName);
    viData=rawDataStruct.(flyName);
end

% Discard instrument data using the offsets in data/datastarts
vars=load(sprintf('~/data/datastarts/%s.mat',flyName));
iFirstValidDataFrame=vars.iFirstValidDataFrame;
viData=viData(ceil(iFirstValidDataFrame):end,:);

% Filter and interpolate to 100 Hz, perform error correction
dataInterp=prepFilterAndInterpData(viData);
[dataStruct,viFieldNames,dataFieldNames]=prepErrorCheckData(dataInterp);

% Pack the fields of our data struct into a matrix and z-score each dim (ignoring NaNs) so that dims can be compared
% to each other. After this, clear NaNs
dataPreNorm=struct2array(dataStruct);
dataNorm=dataPreNorm;
for iDim=1:size(dataNorm,2)
	dataNorm(:,iDim)=(dataNorm(:,iDim) - nanmean(dataNorm(:,iDim))) / nanstd(dataNorm(:,iDim));
end
dataNorm(isnan(dataNorm))=0;
