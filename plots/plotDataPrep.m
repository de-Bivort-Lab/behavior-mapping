function plotDataPrep(flyName,dimNames,frames)

% plotDataPrep(flyName,frames)
% Plot our data preparation figure for the given fly
%
% Inputs:
% flyName [string]: tag for fly whose data we want to load
% dimNames [NPlotDims x 1 string]: names for the dimensions we want to plot
% frames [NPlotFrames x 1]: frames we want to plot, defaults to entire experiment
%
% Figure 1B: plotDataPrep('f37_1',{'Y3','Y6'},17000:19000)

% Load the given fly's raw data, we also look at viData directly here to plot the data before error correction
[dataNorm,viData,viFieldNames,dataFieldNames]=loadFlyData(flyName);
NFrames=size(dataNorm,1);
if ~exist('frames','var') || isempty(frames)
    frames=1:NFrames;
end

% Convert the given dim names into VI and dataNorm indices
viDimIndices=[1 zeros(1,length(dimNames))];
dataNormDimIndices=zeros(1,length(dimNames));
for iDim=1:length(dimNames)
    viDimIndices(iDim+1)=1+find(strcmp(viFieldNames,dimNames{iDim}));
    dataNormDimIndices(iDim)=find(strcmp(dataFieldNames,dimNames{iDim}));
end

% Discard frame index, subtract our first timestamp so timestamps are relative to zero. Then load raw data for
% the given frames
data=viData(:,2:end);
data(:,1)=data(:,1)-data(1,1);
framesMillis=[min(frames)*10 max(frames)*10];
rawData=data(data(:,1)>=framesMillis(1) & data(:,1)<=framesMillis(2),viDimIndices);

% Panel 1: raw data (before error correction)
figure;
for iDim=1:length(dimNames)
    subplot(length(dimNames),1,iDim);
    plot(rawData(:,1),rawData(:,iDim+1));
    xlabel('ms');
    title(sprintf('Dim %s: raw data (before error correction)',dimNames{iDim}));
    setIntegralXAxisLabels(gca);
end
setFigureZoomMode(gcf,'h');

% Panel 2: raw data (after error correction)
figure;
for iDim=1:length(dimNames)
    subplot(length(dimNames),1,iDim);
    plot(frames,dataNorm(frames,dataNormDimIndices(iDim)));
    xlabel('frame numbers');
    title(sprintf('Dim %s: raw data (after error correction)',dimNames{iDim}));
    setIntegralXAxisLabels(gca);
end
setFigureZoomMode(gcf,'h');

% Load our normalized and unnormalized wavelet data, expand our normalized data with zeros for low variance frames
[hvfnData,~,cfsUnnormalizedData,iHighVarFrames,iLowVarFrames]=loadHighVarFNData(flyName);
cfsData=zeros(NFrames,size(hvfnData,2));
cfsData(iHighVarFrames,:)=hvfnData;
NDims=15;
NScales=size(cfsData,2)/NDims;

% Panel 3: unnormalized wavelet data
figure;
for iDim=1:length(dimNames)
    subplot(length(dimNames),1,iDim);
    dim=dataNormDimIndices(iDim);
    dimRows=1+(dim-1)*NScales:dim*NScales;
    cfsFlipped=fliplr(cfsUnnormalizedData(frames,dimRows));
    imagesc(cfsFlipped');
    xlabel('frame numbers');
    ylabel('wavelet scales (low freqs on bottom high freqs on top)');
    title(sprintf('Dim %s: unnormalized wavelet data',dimNames{iDim}));
    setIntegralXAxisLabels(gca);
end

% Panel 4: unnormalized wavelet data low-variance frames shaded
figure;
iShadeFrames=iLowVarFrames(iLowVarFrames>=min(frames) & iLowVarFrames<=max(frames));
for iDim=1:length(dimNames)
    subplot(length(dimNames),1,iDim);
    dim=dataNormDimIndices(iDim);
    dimRows=1+(dim-1)*NScales:dim*NScales;
    cfsFlipped=fliplr(cfsUnnormalizedData(frames,dimRows));
    imagesc(cfsFlipped');
    ylims=ylim;
    % Shade low-variance frames
    for iShade=1:length(iShadeFrames)
        rectangle('Position',[iShadeFrames(iShade)-min(frames)+1 ylims(1) 1 ylims(2)-ylims(1)],'FaceColor','r','EdgeColor','none');
    end
    xlabel('frame numbers');
    ylabel('wavelet scales (low freqs on bottom high freqs on top)');
    title(sprintf('Dim %s: unnormalized wavelet data (low-variance frames shaded)',dimNames{iDim}));
    setIntegralXAxisLabels(gca);
end


% Panel 5: frame-normalized wavelet data
figure;
for iDim=1:length(dimNames)
    subplot(length(dimNames),1,iDim);
    dim=dataNormDimIndices(iDim);
    dimRows=1+(dim-1)*NScales:dim*NScales;
    cfsFlipped=fliplr(cfsData(frames,dimRows));
    imagesc(cfsFlipped');
    xlabel('frame numbers');
    ylabel('wavelet scales (low freqs on bottom high freqs on top)');
    title(sprintf('Dim %s: frame-normalized wavelet data',dimNames{iDim}));
    setIntegralXAxisLabels(gca);
end
