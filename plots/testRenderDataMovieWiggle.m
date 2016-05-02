function testRenderDataMovieWiggle()

% The movies produced by renderDataMovie() had their axes change width as tick labels entered from the right,
% this is the best workaround we've found so far

hfig=figure();
set(hfig,'Position',[0 50 1000 700]);
haxesData=axes('Position',[.05 .05 .4 .6]);
haxesMovie=axes('Position',[.05 .7 .35 .25]);
haxesT2W=axes('Position',[.5 .52 .4 .44]);
haxesP20GSW=axes('Position',[.5 .04 .4 .44]);

for i=1:100
    frames=i:i+100-1;
    cla(haxesData,'reset');
    image(zeros(50,50),'Parent',haxesData,'XData',[frames(1) frames(end)],'YData',[1 50]);
    colorbar('peer',haxesData);
    hold(haxesData,'on');
    plot(haxesData,frames,zeros(length(frames),1));
    xticks=get(haxesData,'XTick');
    set(haxesData,'XTick',xticks(2:end-1));
    drawnow;
    %get(haxesData,'Position')
    %get(haxesData,'OuterPosition')
    %xlim
    %get(haxesData)
    pause(.3);
end
