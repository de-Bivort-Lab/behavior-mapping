function describeVarThresholds()

% describeVarThresholds()
% Print the number of high/low variance frames for each of our flies

for flyNameCell=allFlies()
    flyName=flyNameCell{1};
    
    % Load variance data and display it
    [iHighVarFrames,iLowVarFrames]=loadVarThreshold(flyName);
    fprintf('%s: %d high-variance + %d low-variance = %d total frames\n',flyName,length(iHighVarFrames),length(iLowVarFrames),length(iHighVarFrames)+length(iLowVarFrames));
end
