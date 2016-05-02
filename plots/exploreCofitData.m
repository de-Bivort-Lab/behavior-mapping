function [dataNorm,cfsData,clusters]=exploreCofitData(jobTag,flyName,gmmk,frames,highlightTopCluster,highlightBottomCluster,dataNorm,cfsData,clusters)

% [dataNorm,cfsData,clusters]=exploreCofitData(jobTag,flyName,gmmk,frames,highlightCluster,dataNorm,cfsData,clusters)
% Plot the raw and prepped data for the given fly
%
% Inputs:
% jobTag [string]: folder where PCA20 GMM results are stored
% flyName [string]: tag for fly whose data we want to load
% gmmk [double]: PCA20-GMM-SW co-fit k value for which we plot cluster assignments
% frames [NPlotFrames x 1]: frames we want to plot, defaults to entire experiment
% highlightTopCluster [double]: we highlight instances of this cluster with our top highlight
% highlightBottomCluster [double]: we highlight instances of this cluster with our bottom highlight
% dataNorm,cfsData,clusters: if provided this will speed up the render
%
% Outputs:
% dataNorm,cfsData,clusters: returned so they can be provided to speed up subsequent calls

% Load the given fly's raw and frame-normalized high variance data, expand with zeros for low-variance frames
if ~exist('dataNorm','var')
    dataNorm=loadFlyData(flyName);
    NFrames=size(dataNorm,1);
    hvfnData=loadHighVarFNData(flyName);
    cfsData=zeros(NFrames,size(hvfnData,2));
    iHighVarFrames=loadVarThreshold(flyName);
    cfsData(iHighVarFrames,:)=hvfnData;
    
    % Load cluster assignments
    vars=load(sprintf('~/results/%s/%s_pca20gmmswmapped_all_%d.mat',jobTag,jobTag,gmmk));
    hvclusters=vars.finalClustersByFly(flyName);
    clusters=expandClusters(flyName,hvclusters,true);    
end

if ~exist('frames','var') || isempty(frames)
    frames=1:size(dataNorm,1);
end
iTopSelectedFrame=1;
iBottomSelectedFrame=2;

% Prepare color assignments for each cluster
if gmmk < 8
    idx_frames_colors=jet(gmmk);
else
    idx_frames_colors=colorcube(gmmk);
end

% Plot fly data
hfigure=figure;
ax=[];
ax(1)=axes();
plotFlyData(flyName,dataNorm,cfsData,frames,ax(1));
title(ax(1),sprintf('%s frames %d-%d',flyName,min(frames),max(frames)));

% Plot posteriors
ax(2)=axes();
title(sprintf('cluster %d (green), cluster %d (red)',highlightTopCluster,highlightBottomCluster));

% Plot cluster assignments
ax(3)=axes();
ylim([0 1]);
set(gca,'YTick',[]);
hassignments=0;
title(ax(3),sprintf('k=%d assignments',gmmk));

% Link axes, zoom horizontally only, do this before setting up highlights so we can override the zoom/pan callbacks
setFigureZoomMode(hfigure, 'h');
setIntegralXAxisLabels(ax);
linkaxes(ax,'x');

% Initialize our highlight, update on zoom/pan. Delete highlights before zoom/pan to avoid rendering them offscreen
hhighlights=[0 0];
updateHighlight(true);
updateHighlight(false);
set(zoom(hfigure), 'ActionPostCallback', @zoomPanPostCallback);
set(pan(hfigure), 'ActionPostCallback', @zoomPanPostCallback);

% Update our axis layout on figure size changes
set(gcf,'ResizeFcn',@updateLayout);

	function deleteHighlights()
		% Delete all of our highlights
		hdeletes=[];
		for iHighlight=1:2
			if hhighlights(iHighlight) > 0
				hdeletes(end+1)=hhighlights(iHighlight); %#ok<AGROW>
				hhighlights(iHighlight)=0;
			end
		end
		if ~isempty(hdeletes)
			delete(hdeletes);
		end
    end

    function updateAssignments()
        % Remove old frames if we have them
        if hassignments > 0
            delete(hassignments);
            hassignments=0;
        end
    
        % Plot color bars for cluster assignments if we're sufficiently zoomed in
        xlims=xlim(ax(1));
        minFrame=max(floor(xlims(1)),min(frames));
        maxFrame=min(ceil(xlims(2)),max(frames));
        NVisibleFrames=length(minFrame:maxFrame);
        if NVisibleFrames < 100000
            xs=zeros(NVisibleFrames,1);
            ys=zeros(NVisibleFrames,1);
            colors=zeros(NVisibleFrames,3);
            ylims=ylim(ax(3));
            yBlock=(ylims(2)-ylims(1))/5;
            yMin=ylims(1) + yBlock;
            yHeight=yBlock*3;
            for iFrame=1:NVisibleFrames
                frame=minFrame+iFrame-1;
                xs(iFrame)=frame;
                ys(iFrame)=yMin;
                assignment=clusters(frame);
                if assignment==0
                    colors(iFrame,:)=[1 1 1];
                else
                    colors(iFrame,:)=idx_frames_colors(assignment,:);
                end
            end
            xWidth=0.8; % don't shade the entire frame so we can see frame boundaries
            axes(ax(3));
            hassignments=patchRects(xs,ys,xWidth,yHeight,colors);
        end
    end

	function updateLayout(~,~)
		% Make bottom axes smaller, be sure to line up bottom axes with top ones horizontally
		leftPercent=.80;
		bottomPercent1=.12;
		bottomPercent2=.12;
        bottomTotalPercent=bottomPercent1+bottomPercent2;

        set(ax(1),'OuterPosition',[0 bottomTotalPercent leftPercent 1-bottomTotalPercent]);
		ax1Pos=get(ax(1),'Position');

        set(ax(2),'OuterPosition',[0 bottomPercent1 leftPercent bottomPercent2]);
		ax2Pos=get(ax(2),'Position');
        if ax2Pos(4) > 0
			set(ax(2),'Position',[ax1Pos(1) ax2Pos(2) ax1Pos(3) ax2Pos(4)]);
        end
        
        set(ax(3),'OuterPosition',[0 0 leftPercent bottomPercent2]);
		ax3Pos=get(ax(3),'Position');
		if ax3Pos(4) > 0
			set(ax(3),'Position',[ax1Pos(1) ax3Pos(2) ax1Pos(3) ax3Pos(4)]);
		end
		
		% Update our plot to match the visible frames, also update axis labels
        updateAssignments();
		%updateHighlights();
		setIntegralXAxisLabels(hfigure, 'update');
    end

    function updateHighlights()
		% Update all of our highlights
		updateHighlight(true);
		updateHighlight(false);
	end

	function updateHighlight(isTop)
		% Update our highlight, called when the selected cluster changes

   		% Set new highlight, we only want to draw visible highlights or we get "texture data too large for graphics device" warnings
		xlims=xlim(ax(1));
		ylims=ylim(ax(2));
		yMin=ylims(1);
		yHeight=(ylims(2)-ylims(1))/5;
        if isTop
			clusterSelected=highlightTopCluster; %clusters(iTopSelectedFrame);
			yBottom=yMin + 4*yHeight;
			color=[.5 1 .5];
			iHighlight=1;
        else
			clusterSelected=highlightBottomCluster; %clusters(iBottomSelectedFrame);
			yBottom=yMin;
			color=[1 .5 .5];
			iHighlight=2;
        end

		% Remove old highlight if we have one
        if hhighlights(iHighlight) > 0
			delete(hhighlights(iHighlight));
			hhighlights(iHighlight)=0;
        end

        % Plot highlights
	    iSelectedFrames=find(clusters==clusterSelected);
	    iSelectedFrames(iSelectedFrames < xlims(1))=[];
	    iSelectedFrames(iSelectedFrames > xlims(2))=[];
	    if ~isempty(iSelectedFrames)            
            xs=zeros(length(iSelectedFrames),1);
            ys=zeros(length(iSelectedFrames),1);
            for iFrame=1:length(iSelectedFrames)
                xMin=iSelectedFrames(iFrame);
                xs(iFrame)=xMin;
                ys(iFrame)=yBottom;
            end % for frame
            xWidth=0.8; % don't shade the entire frame so we can see frame boundaries
            axes(ax(2));
            hhighlights(iHighlight)=patchRects(xs,ys,xWidth,yHeight,color);
        end
    end

	function zoomPanPostCallback(~,~)        
		deleteHighlights();
		% Update our patches and axis labels after zoom/pan
        updateAssignments();
		updateHighlights();
		setIntegralXAxisLabels(hfigure, 'update');
	end

% Initialize layout
updateLayout();

end
