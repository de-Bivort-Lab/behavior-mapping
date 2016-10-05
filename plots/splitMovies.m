function splitMovies(jobTag,k)

% splitMovies(jobTag,k)
% Split each fly's movie by cluster assignment
%
% Inputs:
% jobTag [string]: folder where results of t-SNE mapping (plus other clustering algorithms using the same k) can be found
% k [double]: number of mapped clusters in co-fit data set
%
% Example:
% splitMovies('swRound1',40)

% We only output the longest NMaxSequences sequences from each cluster
NMaxSequences=12;

% Load our PCA20-GM-SW co-fit cluster assignments for each fly
vars=load(sprintf('~/results/%s/%s_pca20gmmswmapped_all_%d.mat',jobTag,jobTag,k));
finalClustersByFly=vars.finalClustersByFly;
mappedClusterMeans=vars.mappedClusterMeans;
uniqueMappedClusterMeans=unique(mappedClusterMeans);

% Parse each fly for which we have movies
movieFilenames=allMovieFilenames();
flies=fieldnames(movieFilenames);
NFlies=length(flies);
for iFly=1:NFlies
    flyName=flies{iFly};
    
    fprintf('Processing %s (fly %d of %d)...\n',flyName,iFly,NFlies);
    
    % Load this fly's crop rect
    pathCropRect=sprintf('~/data/moviecroprects/%s.mat',flyName);
    vars=load(pathCropRect);
    cropRect=vars.cropRect;
    
    % Load PCA20-GMM-SW co-fit cluster assignments for this fly
    hvclusters=finalClustersByFly(flyName);
    clusters=expandClusters(flyName,hvclusters,true);

    % Load this fly's posteriors, this assumes swRound1 and 40 for now
    assert(strcmp(jobTag,'swRound1') && k==40);
    pathPost=sprintf('~/results/coRound2_post/coRound2_post_%s.mat',flyName);
    vars=load(pathPost);
    P=vars.P;
    
    % Load input movie and its sync info
    pathMovie=sprintf('~/data/movies/%s',movieFilenames.(flyName));
    videoIn=VideoReader(pathMovie); %#ok<TNMLP>
    vars=load(sprintf('~/data/moviestarts/%s.mat',flyName));
    iFirstValidMovieFrame=vars.iFirstValidMovieFrame;
    
    % Trim our cluster assignments to those for which we have movie frames, then compute sequence assignments
    [DataFrameRate,~]=dataAndMovieFrameRates();
    NDataFrames=ceil(DataFrameRate*videoIn.Duration) + 100;  % add extra frames here in case the duration isn't accurate
    clusters=clusters(1:NDataFrames);
    seqs=labelSequences(clusters);
    
    % Parse each input movie frame until we run out of frames
    iInputMovieFrame=0;
    outputCluster=nan; outputSeq=nan;
    videoOut=[]; iVideoOutMinFrame=nan; iVideoOutMaxFrame=nan;
    rangesByClusterSeq={};
    while iInputMovieFrame<1000000%videoIn.hasFrame()
        iInputMovieFrame=iInputMovieFrame+1;
        frame=[];%videoIn.readFrame();
        
        % Get data frames for this movie frame. If all frames have the same cluster assignment, write to that
        % cluster's movie, otherwise skip this frame
        dataFrames=movieFrameToDataFrames(iFirstValidMovieFrame,iInputMovieFrame);
        
        % Ignore data frames before the experiment start
        dataFrames(dataFrames<1)=[];
        if max(dataFrames)>length(clusters); break; end
        frameClusters=clusters(dataFrames);
        if length(unique(frameClusters))==1
            
            % Open this cluster/sequence's output video if necessary            
            cluster=frameClusters(1);
            seq=seqs(dataFrames(1));
            if outputCluster~=cluster || outputSeq~=seq
                if ~isempty(videoOut)
                    %videoOut.close();
                    videoOut=[];
                    rangesByClusterSeq{outputCluster+1,outputSeq}=iVideoOutMinFrame:iVideoOutMaxFrame;
                    iVideoOutMinFrame=inf; iVideoOutMaxFrame=-inf;
                end
                % Skip this sequence if it's not one of the NMaxSequences longest
                if seq<=NMaxSequences
                    pathOutput=sprintf('~/data/%s_%d_cofit_splits/%s_%d_%d.mp4',jobTag,k,flyName,cluster+1,seq);
                    videoOut=2;%VideoWriter(pathOutput,'MPEG-4'); %#ok<TNMLP>
                    %videoOut.Quality=100;
                    %videoOut.open();
                end
                outputCluster=cluster; outputSeq=seq;
            end
            
            % Write this frame if we have a writer
            if ~isempty(videoOut)
                iVideoOutMinFrame=min(iVideoOutMinFrame,min(dataFrames));
                iVideoOutMaxFrame=max(iVideoOutMaxFrame,max(dataFrames));
                % Crop this frame
                %frameCropped=frame(cropRect(2):cropRect(2)+cropRect(4)-1,cropRect(1):cropRect(1)+cropRect(3)-1,:);
                % Write our cropped frame
                %videoOut.writeVideo(frameCropped);
            end
        end
    end
    
    % Close our last output movie
    if ~isempty(videoOut);
        %videoOut.close();
        rangesByClusterSeq{outputCluster+1,outputSeq}=iVideoOutMinFrame:iVideoOutMaxFrame; %#ok<AGROW>
    end
    
    % Now compute average posterior probability for each cluster/seq's data frames. We use the parent cluster
    % here (we could use the child cluster as well - neither is perfect - but using the parent cluster facilitates
    % comparisons between sequences assigned to the same parent cluster)
    postsByClusterSeq=cell(size(rangesByClusterSeq));
    for iCluster=1:size(rangesByClusterSeq,1)
        for iSequence=1:size(rangesByClusterSeq,2)
            if ~isempty(rangesByClusterSeq{iCluster,iSequence})
                if iCluster==1
                    % Just use a posterior of 1.0 for the low-variance frames (cluster 0)
                    postsByClusterSeq{iCluster,iSequence}=1.0;
                else
                    parentCluster=uniqueMappedClusterMeans(iCluster-1);
                    % Grab our range of posterior probabilities for this cluster/seqs data frames and parent cluster
                    posts=P(rangesByClusterSeq{iCluster,iSequence},parentCluster);
                    postsByClusterSeq{iCluster,iSequence}=mean(posts);
                end
            end
        end
    end
    
    % Save this fly's posteriors by cluster/sequence
    pathPosts=sprintf('~/data/%s_%d_cofit_splits/%s_posts.mat',jobTag,k,flyName);
    save(pathPosts,'postsByClusterSeq');
end
