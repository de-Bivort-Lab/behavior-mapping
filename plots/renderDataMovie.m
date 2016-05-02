function renderDataMovie(jobTag,flyName,pathOutput,frames)

% renderDataMovie(jobTag,flyName,pathOutput,frames)
% Render movie of fly and t-SNE watershed density map with PCA20-GMM-SW overlay
%
% Inputs:
% jobTag [string]: folder where results of t-SNE mapping (plus other clustering algorithms using the same k) can be found
% flyName [string]: tag for fly we're processing
% pathOutput [string]: path where we write our output movie
% frames [NRenderFrames x 1 double]: frames of our data set we want to render, defaults to entire movie
%
% Movie M1:
% renderDataMovie('swRound1','f37_1','~/results/movies/f37_1_data_excerpt.mp4',6600:7900);

% Load the colormap used below for density maps
cmapValues=cmapStandard1();

% Load raw time-domain and wavelet data for plotting below. We use zeros for low variance wavelet data here
% (since there's no good way to plot it against normalized high-variance data - it's unclear what amplitude to use)
dataNorm=loadFlyData(flyName);
hvfnData=loadHighVarFNData(flyName);
[iHighVarFrames,iLowVarFrames]=loadVarThreshold(flyName);
NFrames=length(iHighVarFrames)+length(iLowVarFrames);
assert(size(hvfnData,1)==length(iHighVarFrames));
cfsData=zeros(NFrames,size(hvfnData,2));
cfsData(iHighVarFrames,:)=hvfnData;

% Load PCA20-GMM-SW cluster assignments, include low-variance frames
[allClusters,numClusters]=loadClustersSW(jobTag,flyName,true);
clustersPCA20GMMSW=allClusters.p20gsw;
hvclustersPCA20GMMSW=clustersPCA20GMMSW;
hvclustersPCA20GMMSW(hvclustersPCA20GMMSW==0)=[];

% Load t-SNE2 results and compute density map
vars=load(sprintf('~/results/%s/%s_tm2_%s.mat',jobTag,jobTag,flyName));
t2HVCoords=vars.embeddingValues;
[watersheds,numWatersheds,xx,density,~,sigma,numPoints,rangeVals]=wshedProcess(t2HVCoords,numClusters);
assert(numWatersheds==numClusters);

% Highlight the borders between watershed regions (pixels with watershed 0)
maxDensity=max(density(:));
densityWithBorders=density;
densityWithBorders(watersheds==0)=maxDensity*0.5;

% Expand embedded values to include low variance frames, use NaN/NaN as the coords of low-variance frames
t2Coords=nan(NFrames,2);
assert(length(iHighVarFrames)==size(t2HVCoords,1) && size(t2HVCoords,2)==2);
t2Coords(iHighVarFrames,:)=t2HVCoords;

% Take default frame indices if necessary
if ~exist('frames','var') || isempty(frames)
    frames=1:NFrames;
end

% Load input movie and its sync info
movieFilenames=allMovieFilenames();
pathMovie=sprintf('~/data/movies/%s',movieFilenames.(flyName));
videoIn=VideoReader(pathMovie);
inputMovieFrame=videoIn.readFrame();
iInputMovieFrame=1;

vars=load(sprintf('~/data/moviestarts/%s.mat',flyName));
iFirstValidMovieFrame=vars.iFirstValidMovieFrame;

% Open output movie, we use the lowest quality here
videoOut=VideoWriter(pathOutput,'MPEG-4');
videoOut.Quality=0;
videoOut.open();


% Set up our movie figure
hfig=figure();
set(hfig,'Position',[0 50 1000 700]);
haxesData=axes('Position',[.05 .05 .4 .6]);
haxesMovie=axes('Position',[.05 .7 .35 .25]);
haxesT2W=axes('Position',[.5 .52 .4 .44]);
haxesP20GSW=axes('Position',[.5 .04 .4 .44]);
iFrame=frames(1);
while true
    % Plot this frame of data
    NDataFrames=600;
    dataStart=iFrame-round(NDataFrames/2);
    dataEnd=iFrame+round(NDataFrames/2);
    if dataStart<1
        dataStart=1;
        dataEnd=NDataFrames+1;
    end
    plotFlyData(flyName,dataNorm,cfsData,dataStart:dataEnd,haxesData,iFrame,true);
    setIntegralXAxisLabels(haxesData,'update');

    title(haxesData,'Raw data and wavelet data');
    % Plot t-SNE2 watershed density map
    imagesc(xx,xx,densityWithBorders,'Parent',haxesT2W);
    axis(haxesT2W,'equal','tight','off','xy');
    caxis(haxesT2W,[0 maxDensity*.8])
    colormap(haxesT2W,cmapValues)
    colorbar('peer',haxesT2W);
    
    % Draw circle at current coords, use red rect if no coords available (i.e. low variance frame)
    t2Coord=t2Coords(iFrame,:);
    if ~isnan(t2Coord(1))
        R=8;
        pos=[t2Coord(1)-R/2 t2Coord(2)-R/2 R R];
        rectangle('Parent',haxesT2W,'Position',pos,'FaceColor','w','Curvature',[1 1]);
        title(haxesT2W,sprintf('t-SNE_2 watershed [%d watersheds] (%0.2f,%0.2f)',numWatersheds,t2Coord(1),t2Coord(2)));
    else
        xlims=xlim(haxesT2W);
        ylims=ylim(haxesT2W);
        rectangle('Parent',haxesT2W,'Position',[xlims(1),ylims(1),xlims(2)-xlims(1),ylims(2)-ylims(1)],'EdgeColor','r','LineWidth',4);
        title(haxesT2W,sprintf('t-SNE_2 watershed [%d watersheds] (low variance)',numWatersheds));
    end

    % Plot PCA20 GMM data
    currentP20GSWCluster=clustersPCA20GMMSW(iFrame);
    if currentP20GSWCluster > 0
        % Find frames matching the given cluster
        matchingT2Coords=t2HVCoords(hvclustersPCA20GMMSW==currentP20GSWCluster,:);
        
        % Form a density just as we do above for the embedded points, use the watershed boundaries from T2W for reference here
        [~,clusterDensity]=findPointDensity(matchingT2Coords,sigma,numPoints,rangeVals);

        maxClusterDensity=max(clusterDensity(:));
        clusterDensityWithBorders=clusterDensity;
        clusterDensityWithBorders(watersheds==0)=maxClusterDensity*0.5;

        imagesc(xx,xx,clusterDensityWithBorders,'Parent',haxesP20GSW);
        axis(haxesP20GSW,'equal','tight','off','xy');
        caxis(haxesP20GSW,[0 maxClusterDensity*.8])
        colormap(haxesP20GSW,cmapValues)
        colorbar('peer',haxesP20GSW);

        R=8;
        pos=[t2Coord(1)-R/2 t2Coord(2)-R/2 R R];
        rectangle('Parent',haxesP20GSW,'Position',pos,'FaceColor','w','Curvature',[1 1]);

        title(haxesP20GSW,sprintf('PCA_2_0-GMM-SW [k=%d] cluster %d (%d matching frames)',numClusters,currentP20GSWCluster+1,size(matchingT2Coords,1)));
    else
        % Low-variance cluster, just highlight border in red
        xlims=xlim;
        ylims=ylim;
        rectangle('Parent',haxesP20GSW,'Position',[xlims(1),ylims(1),xlims(2)-xlims(1),ylims(2)-ylims(1)],'EdgeColor','r','LineWidth',4);
        title(haxesP20GSW,sprintf('PCA_2_0-GMM-SW [k=%d] low-variance cluster',numClusters));
    end
    

    % Draw corresponding movie frame, stop our loop if we ran out of input movie frames
    iTargetInputMovieFrame=dataFrameToMovieFrame(iFirstValidMovieFrame,iFrame);
    while iInputMovieFrame<iTargetInputMovieFrame && videoIn.hasFrame()
        iInputMovieFrame=iInputMovieFrame+1;
        inputMovieFrame=videoIn.readFrame();
    end
    if ~videoIn.hasFrame()
        break
    end
    if iFrame>frames(end)
        break
    end
    imshow(inputMovieFrame,'Parent',haxesMovie);
    title(haxesMovie,sprintf('%s: frame %d',flyName,iFrame));

    % Write to output video
    frameOutput=getframe(hfig);
    videoOut.writeVideo(frameOutput);
    
    % Clean up the objects we created so we can create them again next frame
    cla(haxesData,'reset');
    cla(haxesMovie,'reset');
    cla(haxesT2W,'reset');
    cla(haxesP20GSW,'reset');

     % Move to the next frame
    iFrame=iFrame+1;
end

% Close our output video, now we can close our movie figure as well
videoOut.close();
close(hfig);
