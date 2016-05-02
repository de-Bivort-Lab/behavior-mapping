function randomSingleFly(flyName,k,pathResult)

% randomSingleFly(flyName,k,pathResult)
% Run random clustering on a single fly (each frame gets a random cluster assignment)
%
% Inputs:
% flyName [string]: tag for fly we're processing
% k [double]: number of clusters to produce
% pathResult [string]: path to file where we save cluster assignments
%
% Results:
% clusters [NHighVarFrames x 1]: cluster assignment (1:k) for each high-variance frame

% Load our high-variance indices so we can determine how many high-variance frames we have
vars=load(sprintf('~/data/varthresholds/varthreshold_%s.mat',flyName));
NHighVarFrames=length(vars.iHighVarFrames);

% Generate random clusters 1:k
clusters=randi(k,NHighVarFrames,1); %#ok<NASGU>

% Save results
save(pathResult,'clusters');
