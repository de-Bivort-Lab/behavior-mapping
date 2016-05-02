function setFigureZoomMode(hfig, mode)

% setFigureZoomMode(hfig, mode)
% Sets the zoom mode for the given figure, also updates pan mode
%
% Inputs:
% hfig [figure handle]: figure whose zoom mode we're setting, defaults to current figure
% mode [string]: 'h' or 'v' for horizontal-only or vertical-only zooming, defaults to horizontal

% Argument defaults
if ~exist('hfig','var'); hfig=gcf(); end
if ~exist('mode','var'); mode='h'; end

% Enable either horizontal or vertical zoom
if strcmp(mode,'h')
	set(pan(hfig),'Motion','horizontal','Enable','on');
	set(zoom(hfig),'Motion','horizontal','Enable','on');
else
	set(pan(hfig),'Motion','vertical','Enable','on');
	set(zoom(hfig),'Motion','vertical','Enable','on');
end
