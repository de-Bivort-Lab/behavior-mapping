function pcawshedRunSingleFlies(jobTag)

% pcawshedRunSingleFlies(jobTag)
% Run PCA-watershed clustering on all of our flies
%
% Inputs:
% jobTag [string]: folder where we store results

flies=allFlies();
parfor iFly=1:length(flies)
    flyName=flies{iFly};
    
    % Create our results path and process this fly
    pathResult=sprintf('~/results/%s/%s_pcawshed_%s.mat',jobTag,jobTag,flyName);
    pcawshedSingleFly(flyName,pathResult);
end
