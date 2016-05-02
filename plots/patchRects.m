function hpatch=patchRects(X,Y,width,height,color)

% h=patchRects(X,Y,width,height,color)
% Draw a set of rectangles using patch, this is much faster than calling rectangle for each one individually
%
% Inputs:
% X [NPatches x 1 double]: x-coordinates of patches to create
% Y [NPatches x 1 double]: y-coordinates of patches to create
% width [double]: width of patches
% height [double]: height of patches
% color [color]: color of patches
%
% Outputs:
% hpatch [patch handle]: handle to set of patches

PatchX=[X(:)'; X(:)'+width; X(:)'+width; X(:)'];
PatchY=[Y(:)'; Y(:)'; Y(:)'+height; Y(:)'+height];

% Check for a single color or an array of colors
if size(color,1)==1
    hpatch=patch(PatchX,PatchY,color);
    set(hpatch,'EdgeColor','none');
else
    hpatch=patch(PatchX,PatchY,[0 0 0]);
    set(hpatch,'facevertexcdata',color,'facecolor','flat','edgecolor','none')
end
