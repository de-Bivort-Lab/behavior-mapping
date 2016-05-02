function renderCofitMotifGrid(jobTag,k,plotClusters,pathOutput)

% renderCofitMotifGrid(jobTag,k,plotClusters)
% Render a movie with one grid cell for each of the given motifs, we cycle through flies and then repeat until
% a fixed output movie frame count is reached
%
% Inputs:
% jobTag [string]: folder where split movies can be found
% k [double]: number of mapped clusters in co-fit data set
% plotClusters [NPlotClusters x 1 double]: clusters which we plot in our movie
% pathOutput [string]: path where we write our output movie
%
% Movie M2:
% renderCofitMotifGrid('swRound1',40,[1 17 35 7 15 12 22 11 19 27 21 4],'~/results/movies/cofit_motif_grid_selected_clusters.mp4');


% Render 1 minute worth of data
[~,MovieFrameRate]=dataAndMovieFrameRates();
NRenderFrames=MovieFrameRate*60;

% Make sure we have the right number of clusters to plot given the below hard-coded grid size
plotv=3;
ploth=4;
assert(length(plotClusters)<=plotv*ploth);
NClusters=length(plotClusters);

movieFilenames=allMovieFilenames();
flies=fieldnames(movieFilenames);
NFlies=length(flies);

% Open our output video and prepare our movie figure
videoOut=VideoWriter(pathOutput,'MPEG-4');
videoOut.Quality=0;
videoOut.open();
hfig=figure();
set(hfig,'Position',[0 50 800 500]);

% Keep state on which fly we're reading from for which cluster
currentFlyIndexByCluster=zeros(NClusters,1);
videoInsByCluster=cell(NClusters,1);

% Process until we render all of our frames
for iRenderFrame=1:NRenderFrames
    if mod(iRenderFrame-1,10)==0
        fprintf('Rendering frame %d of %d...\n',iRenderFrame,NRenderFrames);
    end
    
    % Update each cluster
    for iCluster=1:NClusters
        cluster=plotClusters(iCluster);
        subplot(plotv,ploth,iCluster);
        
        % Advance to the next movie if necessary
        iFly=currentFlyIndexByCluster(iCluster);
        if iFly>0; flyName=flies{iFly}; end
        videoIn=videoInsByCluster{iCluster};
        if isempty(videoIn) || ~videoIn.hasFrame()        
            for iNext=1:NFlies
                iFly=mod(iFly,NFlies-1)+1;
                flyName=flies{iFly};
                pathMovie=sprintf('~/data/movies/%s_%d_cofit_splits/graynotitles_%s_%d.mp4',jobTag,k,flyName,cluster);
                if exist(pathMovie,'file')
                    videoIn=VideoReader(pathMovie); %#ok<TNMLP>
                end
                if ~isempty(videoIn) && videoIn.hasFrame()
                    break
                end
            end
        end
        if isempty(videoIn) || ~videoIn.hasFrame()
            error('No examples available for cluster %d',cluster);
        end
        
        % Read a frame from this movie and update our title
        frame=videoIn.readFrame();
        imshow(frame);
        title(sprintf('cluster %d (%s)',cluster,flyName));
        
        % Update our state for next time
        currentFlyIndexByCluster(iCluster)=iFly;
        videoInsByCluster{iCluster}=videoIn;        
    end

    % Write to output video
    frameOutput=getframe(hfig);
    videoOut.writeVideo(frameOutput);
end

% Close our output video, now we can close our movie figure as well
videoOut.close();
close(hfig);    
