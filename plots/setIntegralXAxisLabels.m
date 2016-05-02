function setIntegralXAxisLabels(haxes,update)

% setIntegralXAxisLabels(haxes,update)
% Sets the x axis labels on the given axis (or set of axes) to integers, prevents MATLAB from using scientific notation.
% Note that axis labels will be incorrect during a zoom/pan operation! They'll correct themselves after
% mouse button is released (not sure how to fix this - is there a callback that gets called continously
% during zoom/pan operations?)
%
% Inputs:
% haxes [NAxes x 1 haxis]: axis handles we want to update
% update [string]: if given as 'update' we don't set integral labels but simply update the given axes, this is useful
%                  if we install a zoom/pan callback outside of this function and need to update the axis labels when
%                  it's called

% If update is given, haxes is a figure that needs updating
if exist('update','var') && strcmp(update,'update')
	updateFigure(haxes);
	return;
end

% We need to update all axes at once in case they are linked together. Add these to the list of marked
% axes
for haxis=haxes
	hfigure=get(haxis,'Parent');
	if isappdata(hfigure, 'IntegralTickLabelAxes')
		updateAxesList=getappdata(hfigure, 'IntegralTickLabelAxes');
	else
		updateAxesList=[];
	end
	updateAxesList(end+1)=haxis; %#ok<AGROW>
	setappdata(hfigure, 'IntegralTickLabelAxes', updateAxesList);

	% Update the axes now, then register update callbacks on zoom/pan and figure resize
	updateAxes(haxis);
	set(zoom(hfigure), 'ActionPostCallback', @zoomPanCallback);
	set(pan(hfigure), 'ActionPostCallback', @zoomPanCallback);
end
	
	function updateAxes(haxis)
		% function updateAxes(haxis)
		% Set integral tick labels on the given axes
		set(haxis, 'XTickLabel', num2str(get(haxis, 'XTick')'));
	end
	
	function updateFigure(hfigure)
		% Update all axes registered in the given figure
		updateList=getappdata(hfigure, 'IntegralTickLabelAxes');
		for iAxis=1:length(updateList)
			updateAxes(updateList(iAxis));
		end
	end

	function zoomPanCallback(~, evd)
		% Called on zoom/pan, update the given figure
		hfigure=get(evd.Axes,'Parent');
		updateFigure(hfigure);
	end

end
