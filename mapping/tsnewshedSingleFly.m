function tsnewshedSingleFly(embeddingValues,pathResult,desiredK)

% tsnewshedSingleFly(embeddingValues,pathResult)
% Run t-SNE watershed clustering on a single fly
%
% Inputs:
% embeddingValues [NHighVarFrames x 2]: coords of high-variance frame-normalized data in t-SNE space
% pathResult [string]: path to file where we save cluster assignments
% desiredK [double]: optional, if given then we search by varying sigma to attempt to yield the desired number of clusters
%
% Results:
% numWatersheds [double]: num watersheds (i.e. num clusters) found
% hvclusters [NHighVarFrames x 1]: cluster assignments for high-variance frames, 0 means high-variance frame spans more than
%                                  one watershed region, fully determined cluster assignments are 1:numWatersheds

% Run our watershed transform
if exist('desiredK','var')
    [~,numWatersheds,~,~,hvclusters]=wshedProcess(embeddingValues,desiredK); %#ok<ASGLU>
else
    [~,numWatersheds,~,~,hvclusters]=wshedProcess(embeddingValues); %#ok<ASGLU>
end


% Save results
save(pathResult,'numWatersheds','hvclusters');
