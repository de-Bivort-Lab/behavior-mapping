function runAllPostTM(jobTag)

% runAllPostTM(jobTag)
% Run all of our mappings once we have our initial t-SNE mapping results
%
% Inputs:
% jobTag [string]: folder where we store results, previous t-SNE mapping results must be stored here

tsnewshedRunSingleFlies(jobTag);
pcagmmMatchTMFlies(jobTag);
pcawshedRunSingleFlies(jobTag);
tsnegmmMatchTMFlies(jobTag);
randomMatchTMFlies(jobTag);
