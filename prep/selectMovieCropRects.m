function selectMovieCropRects()
   
% selectMovieCropRects()
% Prompt the user for the crop rect for each movie

movieFilenames=allMovieFilenames();
for flyNameCell=fieldnames(movieFilenames)'
    flyName=flyNameCell{1};

    % Load our existing crop rect, if any
    pathCropRect=sprintf('~/data/moviecroprects/%s.mat',flyName);
    if exist(pathCropRect,'file')
        vars=load(pathCropRect);
        cropRect=vars.cropRect;
    else
        cropRect=[100 1 120 100];
    end

    % Load the first frame of the movie and show it
    pathMovie=sprintf('~/data/movies/%s',movieFilenames.(flyName));
    videoIn=VideoReader(pathMovie); %#ok<TNMLP>
    frame=videoIn.readFrame();
    origWidth=size(frame,2);
    origHeight=size(frame,1);
    
    hfig=figure;
    haxes=gca;
    set(hfig,'WindowKeyPressFcn',@onKeyPress);
    drawCropRect();
    uiwait(hfig);
end

    function drawCropRect()
        % Draw a new image and our current crop rect
        cla(haxes);
        imshow(frame,'InitialMagnification',100,'Parent',haxes);
        rectangle('Position',[cropRect(1)-1 cropRect(2)-1 cropRect(3)+2 cropRect(4)+2],'EdgeColor','r');        
        rectangle('Position',[cropRect(1)-2 cropRect(2)-2 cropRect(3)+4 cropRect(4)+4],'EdgeColor','r');        
    end

    function onKeyPress(~,callbackdata)
        % Move the crop rect or save it
        if strcmp(callbackdata.Key,'leftarrow')
            if cropRect(1)>1
                cropRect(1)=cropRect(1)-1;
            end
            drawCropRect();
        elseif strcmp(callbackdata.Key,'rightarrow')
            if cropRect(1)<origWidth
                cropRect(1)=cropRect(1)+1;
            end
            drawCropRect();
        elseif strcmp(callbackdata.Key,'uparrow')
            if cropRect(2)>1
                cropRect(2)=cropRect(2)-1;
            end
            drawCropRect();
        elseif strcmp(callbackdata.Key,'downarrow')
            if cropRect(2)<origHeight
                cropRect(2)=cropRect(2)+1;
            end
            drawCropRect();
        elseif strcmp(callbackdata.Key,'s')
            save(pathCropRect,'cropRect');
            close(hfig);
        end
    end

end
