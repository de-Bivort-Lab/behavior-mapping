function [dataStruct,viFieldNames,dataFieldNames]=prepErrorCheckData(dataInterp)

% dataStruct=mp_errorCheckData(mp)
% Takes interpolated data, checks for errors, produces raw data struct.
%
% Inputs:
% dataInterp [NFrames x 27]: raw data, filtered & interpolated to 100 Hz

% Outputs:
% dataStruct [NFrames x 1]: struct array with one field for each dim
% viFieldNames [27 x 1 string]: dimension names for each field in viData
% dataFieldNames [12 x 1 string]: dimension names for each field in dataStruct
%
% Here we check leg-position vectors for tracking errors. Errors are defined as
% instances in which the frame-to-frame position changes by more than 5 x the
% standard deviation of the frame-to-frame motion across the entire vector. Subsequent
% frames are considered to be errors until the leg position is within 5-sigma of the
% previous non-error position, or within one sigma of the overall median position.

% We apply filtering to each leg x/y dim in our data
dataClean=dataInterp;
for iDim=1:12	
	% Grab data for the dim of interest
	data=dataInterp(:,iDim);

	% Cutoff for frame-to-frame motion: 5 sigma
	deltaCutoff=5*std(diff(data));
	
	% Our baseline value is the median, our cutoff for data returning to its normal range
	% is +/- 1 sigma around this baseline value
	baselineValue=median(data);
	medianCutoff=1*std(data-baselineValue);
	
	bError=false;		% true while we're processing an interval of error frames
	iErrorStart=NaN;	% starting index for current error interval, NaN if no error
	
	% Now process each frame in this dim, skip the first so we can look at the previous frame below
	for iFrame=2:size(dataInterp,1)
		
		% Check whether we're looking at error frames
		if ~bError
			% We transition to the error state if this jump is too large, surpassing our motion cutoff
			if abs(data(iFrame)-data(iFrame-1)) > deltaCutoff
				bError=true;
				iErrorStart=iFrame;
			end % if starting error
			
		else
			% Check for a transition back to the non-error state. If we're back within the motion cutoff
			% of the last non-error frame, or within the global normal range, we transition back
			if abs(data(iFrame)-data(iErrorStart-1)) < deltaCutoff || abs(data(iFrame)-baselineValue) < medianCutoff
                
				% Grab good data before/after the error interval
				iErrorEnd=iFrame-1;
				valueStart=data(iErrorStart-1);
				valueEnd=data(iErrorEnd+1);
				
				% Replace the sequence of error frames with linearly interpolated surrounding data
				data(iErrorStart:iErrorEnd)=interp1([iErrorStart-1 iErrorEnd+1], [valueStart valueEnd], iErrorStart:iErrorEnd);
				
				% Clear our error interval state
				bError=false;
				iErrorStart=NaN;
			end % if ending error
		end % else within error interval
		
	end % for frame
	
	% Grab this vector of clean data
	dataClean(:,iDim)=data;
end % for dim to check

% Pack our data into a struct and return it
viFieldNames={'X1','X2','X3','X4','X5','X6','Y1','Y2','Y3','Y4','Y5','Y6', ...
			  'R1','R2','R3','T1','T2','T3','R4','R5','R6','T4','T5','T6', ...
			  'I','J','K'};
for iField=1:length(viFieldNames)
	dataStruct.(viFieldNames{iField})=dataClean(:,iField);
end

% Reorder the fields to our canonical order here, discard polar coords since we don't use them
dataStruct=rmfield(dataStruct,{'R1','R2','R3','R4','R5','R6','T1','T2','T3','T4','T5','T6'});
dataFieldNames=standardDimNames();
dataStruct=orderfields(dataStruct,dataFieldNames);
