function prepCFSData()
   
% prepCFSData()
% Prepare and save wavelet data for all flies. We do this (as opposed to computing the CFS data from
% the raw data when we need it) because the wavelet transform was not producing exactly the same results
% on all platforms for us, and we want the option of running fully deterministic analyses.

% Set t-SNE mapping params
parameters=tsneSetParameters();

flies=allFlies();
for iFly=1:length(flies)
    flyName=flies{iFly};
    fprintf('Processing %s (%d of %d)...\n',flyName,iFly,length(flies));
    
    % Load data, take CWT and save results. We convert to single-precision here to save space on disk
    % and improve loading times
    dataNorm=loadFlyData(flyName);
    cfsdata=single(findWavelets(dataNorm,parameters.pcaModes,parameters)); %#ok<NASGU>
    save(sprintf('~/data/cfs/cfsdata_%s.mat',flyName),'cfsdata','-v7.3');
end
