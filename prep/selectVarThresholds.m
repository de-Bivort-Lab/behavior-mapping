function selectVarThresholds()
   
% selectVarThresholds()
% Prompt the user for the variance threshold for each fly, save results

for flyNameCell=allFlies()
    flyName=flyNameCell{1};
    
    % Load wavelet data for this fly, plot variances
    vars=load(sprintf('~/data/cfs/cfsdata_%s.mat',flyName));
    cfsdata=double(vars.cfsdata);
    variances=var(cfsdata,[],2);
    figure;
    hist(log(variances),1000);
    title(sprintf('%s - %d frames',flyName,size(cfsdata,1)));
    
    % Show old variance if we have one
    oldVariancePath=sprintf('~/data/varthresholds/%s.mat',flyName);
    if exist(oldVariancePath,'file')
        vars=load(oldVariancePath);
        ylims=ylim();
        line([log(vars.varThreshold) log(vars.varThreshold)], ylims, 'Color','r');
    end
    
    % Get new variance from the user
    [x,~]=ginput(1);
    varThreshold=exp(x);
    close;
       
    % Find low-variance and high-variance indices
    iHighVarFrames=find(variances>varThreshold);   
    iLowVarFrames=find(variances<=varThreshold);
    assert(length(iHighVarFrames)+length(iLowVarFrames)==size(cfsdata,1));
    
    % Save results
    save(sprintf('~/data/new_varthresholds/varthreshold_%s.mat',flyName),'varThreshold','iHighVarFrames','iLowVarFrames');
end
