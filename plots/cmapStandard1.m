function cmapValues=cmapStandard1()

% cmapValues=cmapStandard1()
% Return our standard colormap for plots and movies
%
% Outputs:
% cmapValues [colormap]: Colormap values suitable for passing to cmap()

cmapValues=interp1([1 51 102 153 204 256],[0 0 0; 0 0 .75; .5 0 .8; 1 .1 0; 1 .9 0; 1 1 1],1:256);
