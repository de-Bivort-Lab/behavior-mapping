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
% renderCofitFlyGrid('swRound1',40,15,'~/results/cofit_fly_grid_cluster_15.mp4');
% Movie M4:
% renderCofitFlyGrid('swRound1',40,7,'~/results/cofit_fly_grid_cluster_7.mp4');
% Movie M5:
% renderCofitFlyGrid('swRound1',40,17,'~/results/cofit_fly_grid_cluster_17.mp4');


% Render 10 seconds worth of data
[~,MovieFrameRate]=dataAndMovieFrameRates();
NRenderFrames=MovieFrameRate*10;

% Include each fly for which we have movies except for f42 so that we end up with 12 flies filling a 4x3 grid
movieFilenames=allMovieFilenames();
flies=fieldnames(movieFilenames);
flies(strcmp(flies,'f42'))=[];
NFlies=length(flies);
plotMajorV=3;
plotMajorH=4;
assert(NFlies==plotMajorV*plotMajorH);

% We plot this many sequences for each fly
NSequences=12;
plotMinorV=3;
plotMinorH=4;
assert(NSequences==plotMinorV*plotMinorH);

% Open our output video and prepare our movie figure
videoOut=VideoWriter(pathOutput,'MPEG-4');
videoOut.Quality=30;
videoOut.open();
hfig=figure();
set(hfig,'Position',[0 50 1000 800]);

% Load all of our input movies, take the NSequences longest sequences for each fly
videoInsByFlySequence=cell(NFlies,NSequences,1);
for iFly=1:NFlies
    iSequence=1;
    for iSearch=1:20
        pathMovie=sprintf('~/data/%s_%d_cofit_splits/%s_%d_%d.mp4',jobTag,k,flies{iFly},cluster,iSearch);
        if exist(pathMovie,'file')
            % Open the movie, reject it if it's less than .2 seconds long
            hmovie=VideoReader(pathMovie); %#ok<TNMLP>
            if hmovie.Duration >= 0.2
                videoInsByFlySequence{iFly,iSequence}=hmovie;
                iSequence=iSequence+1;
                if iSequence>NSequences
                    break
                end
            end
        end
    end
end    

% Set up subplot layout, we want tighter spacing than the default subplot creates
ax=zeros(NFlies,1);
for iPlot=1:NFlies
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
    
    % Update each fly
    for iFly=1:NFlies
        % Load posteriors
        pathPosts=sprintf('~/data/%s_%d_cofit_splits/%s_posts.mat',jobTag,k,flies{iFly});
        vars=load(pathPosts);
        postsByClusterSeq=vars.postsByClusterSeq;
        
        % Plot each sequence for this fly
        for iSequence=1:NSequences
            % Grab our movie reader, seek to start if no frames are available
            videoIn=videoInsByFlySequence{iFly,iSequence};
            if isempty(videoIn); continue; end
            if ~videoIn.hasFrame(); videoIn.CurrentTime=0; end
            
            strPost=sprintf('%0.1f',log10(postsByClusterSeq{cluster,iSequence}));
            
            % Read a frame from this movie and show it
            frame=videoIn.readFrame();
            xWidth=1/plotMinorH;
            yHeight=1/plotMinorV;
            xSeq=mod(iSequence-1,plotMinorH)*xWidth;
            ySeq=floor((iSequence-1)/plotMinorH)*yHeight;
            image('Parent',ax(iFly),'XData',[xSeq xSeq+xWidth],'YData',[ySeq ySeq+yHeight*3/4],'CData',frame);
            text(xSeq+xWidth/2,ySeq+yHeight*3/4,strPost,'Parent',ax(iFly),...
                 'HorizontalAlignment','center','VerticalAlignment','top');
        end
        xlim(ax(iFly),[0 1]);
        ylim(ax(iFly),[0 1]);
        title(ax(iFly),sprintf('cluster %d (%s)',cluster,flies{iFly}));
    end

    % Write to output video
    frameOutput=getframe(hfig);
    videoOut.writeVideo(frameOutput);

    % Clear our axes so the text objects we wrote will be deleted
    for iPlot=1:NFlies; cla(ax(iPlot)); end
end

% Close our output video, now we can close our movie figure as well
videoOut.close();
close(hfig);    
