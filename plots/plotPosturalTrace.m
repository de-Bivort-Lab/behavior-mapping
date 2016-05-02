function plotPosturalTrace(jobTag,flyName,frames)

% plotPosturalTrace(jobTag,flyName,frames)
% Plot our postural trace figure with the given fly using PCA20 GMM SW clusters
%
% Inputs:
% jobTag [string]: folder where results of t-SNE mapping (plus other clustering algorithms using the same k) can be found
% flyName [string]: tag for fly we're processing
% frames [NRenderFrames x 1 double]: frames of our data set we want to render
%
% Figure 7: plotPosturalTrace('swRound1','f37_1',5000:6000)

% Load the colormap used below for density maps
cmapValues=cmapStandard1();

% Load PCA20 GMM SW cluster assignments, include low-variance frames
[allClusters,numClusters]=loadClustersSW(jobTag,flyName,true);
clustersPCA20GMMSW=allClusters.p20gsw;

% Load t-SNE2 results and compute density map, match our PCA20 GMM SW cluster count
vars=load(sprintf('~/results/%s/%s_tm2_%s.mat',jobTag,jobTag,flyName));
t2HVCoords=vars.embeddingValues;
[watersheds,numWatersheds,xx,density]=wshedProcess(t2HVCoords,numClusters);
assert(numWatersheds==numClusters);

% Highlight the borders between watershed regions (pixels with watershed 0)
maxDensity=max(density(:));
densityWithBorders=density;
densityWithBorders(watersheds==0)=nan;


% Emulate imagesc here so we can set our nan color
maxval=max(densityWithBorders(:));
scaledImage=densityWithBorders./maxval./.8;
scaledImage(scaledImage>1)=1;
cmappedImage=floor(scaledImage*length(cmapValues));
rgbImage=ind2rgb(cmappedImage,cmapValues);
inds=find(isnan(densityWithBorders));
[x,y]=ind2sub(size(rgbImage),inds);
for i=1:length(x)
    rgbImage(x(i),y(i),:)=[.4 .4 .4];
end

% Expand embedded values to include low variance frames, use NaN/NaN as the coords of low-variance frames
[iHighVarFrames,iLowVarFrames]=loadVarThreshold(flyName);
NFrames=length(iHighVarFrames)+length(iLowVarFrames);
t2Coords=nan(NFrames,2);
assert(length(iHighVarFrames)==size(t2HVCoords,1) && size(t2HVCoords,2)==2);
t2Coords(iHighVarFrames,:)=t2HVCoords;


% Use a different color for each cluster
colors=colorcube(max(clustersPCA20GMMSW));

% Plot t-SNE2 watershed density map
figure;
imagesc(xx,xx,rgbImage);
axis('equal','tight','off','xy');
caxis([0 maxDensity*.8])
colormap(cmapValues)
colorbar();

% Draw our overlay for each frame
lastPos=[nan nan];
for iFrameIndex=1:length(frames)
    iFrame=frames(iFrameIndex);
    pos=t2Coords(iFrame,:);
    % Issue a warning and skip low-variance frames
    if isnan(pos(1))
        fprintf('Warning: frame %d is low-variance, skipping\n',iFrame);
        continue;
    end
    clusterPCA20GMMSW=clustersPCA20GMMSW(iFrame);
    assert(clusterPCA20GMMSW>0);
    color=colors(clusterPCA20GMMSW,:);
    
    % Draw a dot at the current pos
    R=3;
    dot=[pos(1)-R/2 pos(2)-R/2 R R];
    rectangle('Position',dot,'FaceColor',color,'EdgeColor','k','Curvature',[1 1]);

    % Draw a line from our previous pos to our current one
    if ~isnan(lastPos(1))
        % Try cycling colors here
        color=hsv2rgb([iFrameIndex/length(frames) 1 1]);
        line([lastPos(1) pos(1)],[lastPos(2) pos(2)],'LineWidth',3,'Color',color);
    end
    lastPos=pos;
end

title(sprintf('%s postural dynamics frames %d-%d',flyName,min(frames),max(frames)));
