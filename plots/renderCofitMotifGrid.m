function renderCofitMotifGrid(jobTag,k,plotClusters,plotFlies,pathOutput)

% renderCofitMotifGrid(jobTag,k,plotClusters)
% Render a movie with one major grid cell for each of the given motifs, and one minor grid cell for each of the given flies
%
% Inputs:
% jobTag [string]: folder where split movies can be found
% k [double]: number of mapped clusters in co-fit data set
% plotClusters [NPlotClusters x 1 double]: clusters which we plot in our movie
% pathOutput [string]: path where we write our output movie
%
% Movie M2:
% renderCofitMotifGrid('swRound1',40,[1 17 35 7 15 12 22 11 19 27 21 4],'~/results/movies/cofit_motif_grid_selected_clusters.mp4');


% Render 10 seconds worth of data
[~,MovieFrameRate]=dataAndMovieFrameRates();
NRenderFrames=MovieFrameRate*10;

% Make sure we have the right number of clusters and flies to plot given the below hard-coded grid sizes
plotMajorV=3;
plotMajorH=4;
assert(length(plotClusters)<=plotMajorV*plotMajorH);
NClusters=length(plotClusters);

plotMinorV=3;
plotMinorH=4;
assert(length(plotFlies)<=plotMinorV*plotMinorH);
NFlies=length(plotFlies);

movieFilenames=allMovieFilenames();
flies=fieldnames(movieFilenames);

% Open our output video and prepare our movie figure
videoOut=VideoWriter(pathOutput,'MPEG-4');
videoOut.Quality=30;
videoOut.open();
hfig=figure();
set(hfig,'Position',[0 50 1000 800]);

% Load all of our input movies
videoInsByClusterFly=cell(NClusters,NFlies,1);
for cluster=plotClusters
    for iFly=1:NFlies
        for iSeq=1:20
            pathMovie=sprintf('~/data/%s_%d_cofit_splits/%s_%d_%d.mp4',jobTag,k,flies{iFly},cluster,iSeq);
            if exist(pathMovie,'file'); break; end
        end
        if exist(pathMovie,'file')
            % Open the movie, reject it if it's less than .2 seconds long
            videoInsByClusterFly{cluster,iFly}=VideoReader(pathMovie); %#ok<TNMLP>
            if videoInsByClusterFly{cluster,iFly}.Duration < 0.2
                videoInsByClusterFly{cluster,iFly}=[];
            end
        else
            % Just leave this movie empty, we'll skip it below
            videoInsByClusterFly{cluster,iFly}=[];
        end
    end    
end

% Set up subplot layout, we want tighter spacing than the default subplot creates
ax=zeros(NClusters,1);
for iPlot=1:NClusters
    xWidth=1/plotMajorH;
    yHeight=1/plotMajorV;
    xAxis=mod(iPlot-1,plotMajorH)*xWidth;
    yAxis=floor((iPlot-1)/plotMajorH)*yHeight;
    xSpace=xWidth/20;
    yTop=yHeight/10;
    yBottom=0;%yHeight/8;
    ax(iPlot)=axes('position',[xSpace+xAxis,1-yAxis-yHeight+yBottom,xWidth-2*xSpace,yHeight-yTop-yBottom]);
    set(gca,'YDir','reverse');
    axis off;
end

% Process until we render all of our frames
for iRenderFrame=1:NRenderFrames
    if mod(iRenderFrame-1,10)==0
        fprintf('Rendering frame %d of %d...\n',iRenderFrame,NRenderFrames);
    end
    
    % Update each cluster
    for iCluster=1:NClusters
        cluster=plotClusters(iCluster);
        
        % Plot each fly for this cluster
        for iFly=1:NFlies
            % Grab our movie reader, seek to start if no frames are available
            videoIn=videoInsByClusterFly{cluster,iFly};
            if isempty(videoIn); continue; end
            if ~videoIn.hasFrame(); videoIn.CurrentTime=0; end

            % Read a frame from this movie and show it with a caption
            frame=videoIn.readFrame();
            xWidth=1/plotMinorH;
            yHeight=1/plotMinorV;
            xFly=mod(iFly-1,plotMinorH)*xWidth;
            yFly=floor((iFly-1)/plotMinorH)*yHeight;
            image('Parent',ax(iCluster),'XData',[xFly xFly+xWidth],'YData',[yFly yFly+yHeight*3/4],'CData',frame);
            text(xFly+xWidth/2,yFly+yHeight*3/4,flies{iFly},'Parent',ax(iCluster),...
                 'HorizontalAlignment','center','VerticalAlignment','top','Interpreter','none');
        end
        xlim(ax(iCluster),[0 1]);
        ylim(ax(iCluster),[0 1]);
        title(ax(iCluster),sprintf('cluster %d',cluster));
    end

    % Write to output video
    frameOutput=getframe(hfig);
    videoOut.writeVideo(frameOutput);

    % Clear our axes so the text objects we wrote will be deleted
    for iPlot=1:NClusters; cla(ax(iPlot)); end
end

% Close our output video, now we can close our movie figure as well
videoOut.close();
close(hfig);    
