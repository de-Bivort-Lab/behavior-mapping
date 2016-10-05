function [watersheds,numWatersheds,xx,density,hvclusters,sigma,numPoints,rangeVals]=wshedProcess(embeddingValues,desiredK,sigmaDenom)

% [watersheds,numWatersheds,xx,density]=wshedProcess(embeddingValues)
% Return watersheds, 2-D density map and high-variance cluster assignments for the given embedded data points
%
% Inputs:
% embeddingValues [NFrames x 2]: x,y coords for each data point in the t-SNE space
% desiredK [double]: optional, if given then we search by varying sigma to attempt to yield the desired number of clusters
%
% Outputs:
% watersheds [501 x 501]: watershed assignments for each point in quantized t-SNE space, 0 for pixels
%                         spanning more than one watershed basin
% numWatersheds [double]: num watersheds (i.e. num clusters) found
% xx [1 x 501]: coordinate boundaries, used to plot quantized t-SNE space
% density [501 x 501]: density map, used to visualize quantized t-SNE space
% hvclusters [NHighVarFrames x 1]: cluster assignments for high-variance frames, 0 means high-variance frame spans more than
%                                  one watershed region, fully determined cluster assignments are 1:numWatersheds
% sigma [double]: kernel size for Gaussian blur
% numPoints [double]: number of pixels in x and y dimensions for our density map
% rangeVals [1 x 2 double]: min and max values in our density map

% Find the range of values in the t-SNE space, code taken from MotionMapper codebase
maxVal=max(abs(embeddingValues(:)));
maxVal=round(maxVal*1.1);

% We take this default value for sigma's denominator from the MotionMapper codebase
sigmaDenomDefault=40;

% Check whether we're searching for a desired K
if ~exist('desiredK','var') || isempty(desiredK)
    % Just run with the given or default value of sigma's denominator
    if ~exist('sigmaDenom','var')
        sigmaDenom=sigmaDenomDefault;
    end
    [watersheds,numWatersheds,xx,density,sigma,numPoints,rangeVals]=process(sigmaDenom);
else
    % Find the optimal value for sigma's denominator
    sigmaDenom=fzero(@adjNumWatersheds,sigmaDenomDefault);
    [watersheds,numWatersheds,xx,density,sigma,numPoints,rangeVals]=process(sigmaDenom);
end


% Place points on our density map to find our clusters
[~,~,xbins]=histcounts(embeddingValues(:,1),xx);
[~,~,ybins]=histcounts(embeddingValues(:,2),xx);
indices=sub2ind(size(watersheds),xbins,ybins);
hvclusters=watersheds(indices);

    function adjWatersheds=adjNumWatersheds(sigmaDenom)
        % Return the number of watersheds found for a given value of sigma's denominator, adjusted so desired K returns zero
        [~,numWatersheds]=process(sigmaDenom);
        adjWatersheds=numWatersheds-desiredK;
    end

    function [watersheds,numWatersheds,xx,density,sigma,numPoints,rangeVals]=process(sigmaDenom)
        % Run our watershed transform with the given sigma denominator
        sigma=maxVal/sigmaDenom;
        numPoints=501;
        rangeVals=[-maxVal maxVal];

        [xx,density]=findPointDensity(embeddingValues,sigma,numPoints,rangeVals);

        % Watershed to find cluster boundaries
        watersheds=double(watershed(-density,8));
        numWatersheds=max(max(watersheds));
    end

end
