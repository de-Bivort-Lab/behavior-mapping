function runMetricNNeighbors(jobTag,showFigures)

% runMetricNNeighbors(jobTag,flyName)
% Compute nearest neighbor metric for all flies in the given job
%
% Inputs:
% jobTag [string]: folder where results of t-SNE mapping (plus other clustering algorithms using the same k) can be found
% showFigures [bool]: if set we show figures as we compute values
%
% Results:
% methodScoresByFly [flyName -> (struct -> [NRandomPoints x L])]: struct with fieldnames as abbreviations for methods, values are scores for
%                                                                 randomly sampled points, stored by fly name

% Process each fly
tic;
flies=allFlies();

methodScoresByFly=containers.Map();
for iFly=1:length(flies)
    flyName=flies{iFly};
    fprintf('Fly %s (%d of %d)... (%0.0f seconds elapsed so far)\n',flyName,iFly,length(flies),toc);
    
    methodScores=metricNNeighbor(jobTag,flyName,showFigures);
    methodScoresByFly(flyName)=methodScores;
end

pathResult=sprintf('~/results/%s/nneighbors.mat',jobTag);
save(pathResult,'methodScoresByFly');
