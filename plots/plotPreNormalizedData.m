function plotPreNormalizedData(dimNames,flyNames)

% plotPreNormalizedData(dimNames,flyNames)
% Plot data after resampling and error correction but before normalization
%
% Inputs:
% dimNames [1 x NPlotDims string]: Names of each dim we want to plot
% flyNames [1 x NFlies string]: Names of flies we want to plot

% Load data for each fly
NDims=length(dimNames);
NFlies=length(flyNames);
dataByFly=cell(NFlies,1);
for iFly=1:NFlies
    flyName=flyNames{iFly};
    
    % Load data from this fly, find dims
    [~,~,~,dataFieldNames,dataPreNorm]=loadFlyData(flyName);
    iDims=zeros(NDims,1);
    for iDimIndex=1:NDims
        iDims(iDimIndex)=find(strcmp(dataFieldNames,dimNames{iDimIndex}));
    end
    data=double(dataPreNorm(:,iDims));
    dataByFly{iFly}=data;
end

figure;
[~,nanFlies]=allFlies();
ax=zeros(NDims,1);
for iDim=1:NDims
    
    ax(iDim)=subplot(NDims,1,iDim);
    hold on;
    
    for iFly=1:NFlies
        flyName=flyNames{iFly};
        
        % WT/NAN determines color
        if any(strcmp(flyName,nanFlies))
            color='r';
        else
            color='b';
        end
        plot(dataByFly{iFly}(:,iDim),color);
    end
    
    title(dimNames{iDim});
end

linkaxes(ax,'x');
setFigureZoomMode(gcf,'h');
