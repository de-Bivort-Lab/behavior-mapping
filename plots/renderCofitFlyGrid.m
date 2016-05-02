function renderCofitFlyGrid(jobTag,k,cluster,pathOutput)

% renderCofitFlyGrid(jobTag,k,cluster,pathOutput)
% Render a movie with a single cluster and one grid cell for each fly, we cycle through sequences and then repeat until
% a fixed output movie frame count is reached
%
% Inputs:
% jobTag [string]: folder where split movies can be found
% k [double]: number of mapped clusters in co-fit data set
% cluster [double]: single cluster for all of the frames we plot in our movie
% pathOutput [string]: path where we write our output movie
%
% Movie M3:
% renderCofitFlyGrid('swRound1',40,17,'~/results/movies/cofit_fly_grid_cluster_17.mp4');
% Movie M4:
% renderCofitFlyGrid('swRound1',40,15,'~/results/movies/cofit_fly_grid_cluster_15.mp4');
% Movie M5:
% renderCofitFlyGrid('swRound1',40,4,'~/results/movies/cofit_fly_grid_cluster_4.mp4');


% Render 1 minute worth of data
[~,MovieFrameRate]=dataAndMovieFrameRates();
NRenderFrames=MovieFrameRate*60;

% Include each fly for which we have movies except for f42 so that we end up with 12 flies filling a 4x3 grid
movieFilenames=allMovieFilenames();
flies=fieldnames(movieFilenames);
flies(strcmp(flies,'f42'))=[];
NFlies=length(flies);
plotv=3;
ploth=4;
assert(NFlies==plotv*ploth);

% Open our output video and prepare our movie figure
videoOut=VideoWriter(pathOutput,'MPEG-4');
videoOut.Quality=0;
videoOut.open();
hfig=figure();
set(hfig,'Position',[0 50 800 500]);

videoInsByFly=cell(NFlies,1);

% Process until we render all of our frames
for iRenderFrame=1:NRenderFrames
    if mod(iRenderFrame-1,10)==0
        fprintf('Rendering frame %d of %d...\n',iRenderFrame,NRenderFrames);
    end
    
    % Update each fly
    for iFly=1:NFlies
        flyName=flies{iFly};
        subplot(plotv,ploth,iFly);
        axis off;
        
        % Reload the movie if necessary
        videoIn=videoInsByFly{iFly};
        if isempty(videoIn) || ~videoIn.hasFrame()        
            pathMovie=sprintf('~/data/movies/%s_%d_cofit_splits/graynotitles_%s_%d.mp4',jobTag,k,flyName,cluster);
            if exist(pathMovie,'file')
                videoIn=VideoReader(pathMovie); %#ok<TNMLP>
            end
        end
        if ~isempty(videoIn) && videoIn.hasFrame()
            % Read a frame from this movie and draw it
            frame=videoIn.readFrame();
            imshow(frame);
        end
        title(sprintf('cluster %d (%s)',cluster,flyName));
                
        % Update our state for next time
        videoInsByFly{iFly}=videoIn;        
    end

    % Write to output video
    frameOutput=getframe(hfig);
    videoOut.writeVideo(frameOutput);
end

% Close our output video, now we can close our movie figure as well
videoOut.close();
close(hfig);    
