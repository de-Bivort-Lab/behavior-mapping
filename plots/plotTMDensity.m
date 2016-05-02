function plotTMDensity(watersheds,xx,density)

% plotTMDensity(watersheds,xx,density)
% Plot the given density map, shows t-SNE quantized space
%
% Inputs:
% watersheds [501 x 501]: watershed assignments for each point in quantized t-SNE space
% xx [1 x 501]: coordinate boundaries in t-SNE space
% density [501 x 501]: density map of t-SNE quantized space

% Highlight the borders between watershed regions (pixels with watershed 0)
maxDensity=max(density(:));
densityWithBorders=density;
densityWithBorders(watersheds==0)=maxDensity*0.5;

% Plot image, code taken from MotionMapper
imagesc(xx,xx,densityWithBorders);
axis equal tight off xy;
caxis([0 maxDensity*.8]);
colormap(jet);
colorbar;
