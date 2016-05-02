function plotFlyData(flyName,dataNorm,cfsData,frames,haxes,currentFrame,fullDataNormalization)

% plotFlyData(flyName,dataNorm,cfsData,frames,haxes,currentFrame)
% Plot time-domain and wavelet data for the given fly, we plot the given frames, defaults to all frames
%
% Inputs:
% flyName [string]: tag for fly we're processing
% dataNorm [NFrames x NDims]: prepped time-domain data for the given fly
% cfsData [NFrames x NDims*NScales]: wavelet data with frame-normalization applied to high-variance frames
% frames [NPlotFrames x 1]: frames we want to plot, defaults to all frames
% haxes [axes]: axes where we plot, defaults to creating a new figure
% currentFrame [double]: if given, we draw a green line indicating the current frame
% fullDataNormalization [bool]: if given, we normalize our data using all frames, not just the visible frames (defaults to false)

% Prep our data, we need to separate wavelet data for each dimension below
NDims=15;
NScales=size(cfsData,2)/NDims;
DimNames=standardDimNames();
% Load the colormap used below for density maps
cmapValues=parula;

NFrames=size(dataNorm,1);
if ~exist('frames','var') || isempty(frames)
    frames=1:NFrames;
end

% Create our figure if we're not plotting into given axes
if ~exist('haxes','var')
    hfig=figure();
    haxes=axes();
    createdFigure=true;
else
    createdFigure=false;
end

% Plot CFS data in the background, flip each dim's scales so low frequencies (instead of low scales) are on the bottom
cfsDataFrames=cfsData(frames,:);
for iDim=1:NDims
    dimRows=1+(iDim-1)*NScales:iDim*NScales;
    cfsDataFrames(:,dimRows)=fliplr(cfsDataFrames(:,dimRows));
end
if exist('fullDataNormalization','var') && fullDataNormalization
    maxCFSData=max(cfsData(:));
else
    maxCFSData=max(cfsDataFrames(:));
end
cfsDataScaled=cfsDataFrames/maxCFSData*size(cmapValues,1)+1;
image(cfsDataScaled','Parent',haxes,'XData',[frames(1) frames(end)],'YData',[1 size(cfsData,2)]);
colormap(haxes,cmapValues);
colorbar('peer',haxes);

% Find our normalization factor for time-domain data. We want to use one factor for I/J/K and one for the leg dims
if exist('fullDataNormalization','var') && fullDataNormalization
    ranges=range(dataNorm(:,:));
else
    ranges=range(dataNorm(frames,:));
end
if max(ranges(1:3))>0
    scaleFactorBall=1/max(ranges(1:3));
else
    scaleFactorBall=1;
end
if max(ranges(4:end))>0
    scaleFactorLegs=1/max(ranges(4:end));
else
    scaleFactorLegs=1;
end


% Overlay each dim
hold(haxes,'on');
yTicks=[];
yTickLabels={};
for iDim=1:NDims
    if iDim<=3; scaleFactor=scaleFactorBall; else scaleFactor=scaleFactorLegs; end
    
    % Grab this dim's data, normalize
    rawdata=dataNorm(frames,iDim);
    dimdata=(rawdata-mean(rawdata))*scaleFactor;
    
    % Find the range of cfs pixels corresponding to this dim
    yFirst=1 + (iDim-1)*NScales;
    yHeight=NScales;
    yCenter=yFirst + yHeight/2;
    yTicks(end+1)=yCenter; %#ok<AGROW>
    yTickLabels{end+1}=DimNames{iDim}; %#ok<AGROW>

    % Offset and plot this dim's data
    offsetdata=yCenter + dimdata*yHeight;
    plot(haxes,frames,offsetdata,'w','LineWidth',1);
end

% TEMP, the plot width seems to change depending on the outer xtick label positions, couldn't find
% a way to control this other than to remove last xtick label for now! only do this if full normalization
% is on (i.e. we're called repeatedly from renderDataMovie())
if exist('fullDataNormalization','var') && fullDataNormalization
    xticks=get(haxes,'XTick');
    set(haxes,'XTick',xticks(1:end-1));
end

% Draw a line indicating our current frame if necessary
if exist('currentFrame','var')
    line([currentFrame currentFrame],[1 size(cfsData,2)],'Color','g','Parent',haxes);
end

% Set y-axis labels
set(haxes,'YTick',yTicks);
set(haxes,'YTickLabel',yTickLabels);

if createdFigure
    setFigureZoomMode(hfig, 'h');
    title(haxes,sprintf('%s - cfs & time series',flyName));
end
setIntegralXAxisLabels(haxes);
