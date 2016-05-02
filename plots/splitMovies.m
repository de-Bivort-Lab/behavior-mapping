function splitMovies(jobTag,k,showTitles)

% splitMovies(jobTag,k)
% Split each fly's movie by cluster assignment
%
% Inputs:
% jobTag [string]: folder where results of t-SNE mapping (plus other clustering algorithms using the same k) can be found
% k [double]: number of mapped clusters in co-fit data set
% showTitles [bool]: if set, we render figures with descriptive titles for each frame, otherwise we just render frames
%
% Example:
% splitMovies('swRound1',40,0)

% In between clusters we write this many frames
NClusterBreakFrames=10;
frameClusterBreak=uint8(ones(240,320,3)*128);

% Load our PCA20-GM-SW co-fit cluster assignments for each fly
vars=load(sprintf('~/results/%s/%s_pca20gmmswmapped_all_%d.mat',jobTag,jobTag,k));
finalClustersByFly=vars.finalClustersByFly;

if showTitles
    hfig=figure();
    set(hfig,'Position',[0 50 400 300]);
    haxis=axes();
end

% Parse each fly for which we have movies
movieFilenames=allMovieFilenames();
flies=fieldnames(movieFilenames);
NFlies=length(flies);
for iFly=1:NFlies
    flyName=flies{iFly};
    
    fprintf('Processing %s (%d of %d)...\n',flyName,iFly,NFlies);

    % Load PCA20-GMM-SW co-fit cluster assignments for this fly
    hvclusters=finalClustersByFly(flyName);
    clusters=expandClusters(flyName,hvclusters,true);
    NClusters=max(clusters)+1;
    
    % Load input movie and its sync info
    pathMovie=sprintf('~/data/movies/%s',movieFilenames.(flyName));
    videoIn=VideoReader(pathMovie); %#ok<TNMLP>
    vars=load(sprintf('~/data/moviestarts/%s.mat',flyName));
    iFirstValidMovieFrame=vars.iFirstValidMovieFrame;
    
    % Open each of our output movies, one per cluster, we use maximum quality since we're transcoding
    outputMoviesByCluster=cell(NClusters,1);
    lastMovieFrameIndexByCluster=cell(NClusters,1);
    lastMovieFrameByCluster=cell(NClusters,1);
    for iCluster=1:NClusters
        cluster=iCluster-1;
        if showTitles
            pathOutput=sprintf('~/data/%s_%d_cofit_splits/graytitles_%s_%d.mp4',jobTag,k,flyName,cluster+1);
        else
            pathOutput=sprintf('~/data/%s_%d_cofit_splits/graynotitles_%s_%d.mp4',jobTag,k,flyName,cluster+1);
        end
        videoOut=VideoWriter(pathOutput,'MPEG-4'); %#ok<TNMLP>
        videoOut.Quality=100;
        videoOut.open();
        outputMoviesByCluster{iCluster}=videoOut;
    end
    
    % Parse each input movie frame until we run out of frames
    iInputMovieFrame=0;
    while videoIn.hasFrame()
        iInputMovieFrame=iInputMovieFrame+1;
        frame=videoIn.readFrame();
        
        % Get data frames for this movie frame. If all frames have the same cluster assignment, write to that
        % cluster's movie, otherwise skip this frame
        dataFrames=movieFrameToDataFrames(iFirstValidMovieFrame,iInputMovieFrame);
        % Ignore data frames before the experiment start
        dataFrames(dataFrames<1)=[];
        frameClusters=clusters(dataFrames);
        if length(unique(frameClusters))==1
            iCluster=frameClusters(1)+1;
            % If we're moving to a new sequence for this cluster, write NClusterBreakFrames
            if ~isempty(lastMovieFrameIndexByCluster{iCluster}) && lastMovieFrameIndexByCluster{iCluster}~=iInputMovieFrame-1
                frameFaded=imfuse(lastMovieFrameByCluster{iCluster},frameClusterBreak,'blend','Scaling','none');
                for iClusterBreakFrame=1:NClusterBreakFrames
                    if showTitles
                        imshow(frameClusterBreak,'Parent',haxis,'InitialMagnification','fit');
                        title(sprintf('%s: break between movie frame %d and %d',flyName,lastMovieFrameByCluster{iCluster},iInputMovieFrame));
                        frameOutput=getframe(hfig);
                        outputMoviesByCluster{iCluster}.writeVideo(frameOutput);
                        cla(haxis,'reset');
                    else
                        outputMoviesByCluster{iCluster}.writeVideo(frameFaded);
                    end
                end
            end
            if showTitles
                imshow(frame,'Parent',haxis,'InitialMagnification','fit');
                title(sprintf('%s: cluster %d, data frames %d-%d',flyName,frameClusters(1),min(dataFrames),max(dataFrames)));
                frameOutput=getframe(hfig);
                outputMoviesByCluster{iCluster}.writeVideo(frameOutput);
                cla(haxis,'reset');
            else
                outputMoviesByCluster{iCluster}.writeVideo(frame);
            end
            lastMovieFrameIndexByCluster{iCluster}=iInputMovieFrame;
            lastMovieFrameByCluster{iCluster}=frame;
        end
                
    end

    % Add a faded sequence to the end of each movie with more than one valid frame. This makes it easier to
    % combine movies from different flies in sequence later
    for iCluster=1:NClusters
        if ~isempty(lastMovieFrameIndexByCluster{iCluster})
            frameFaded=imfuse(lastMovieFrameByCluster{iCluster},frameClusterBreak,'blend','Scaling','none');
            for iClusterBreakFrame=1:NClusterBreakFrames
                if showTitles
                    imshow(frameClusterBreak,'Parent',haxis,'InitialMagnification','fit');
                    title(sprintf('%s: final break',flyName));
                    frameOutput=getframe(hfig);
                    outputMoviesByCluster{iCluster}.writeVideo(frameOutput);
                    cla(haxis,'reset');
                else
                    outputMoviesByCluster{iCluster}.writeVideo(frameFaded);
                end
            end
        end
    end
    
    % Close all of our output movies
    for iCluster=1:NClusters
        outputMoviesByCluster{iCluster}.close();
    end
end
