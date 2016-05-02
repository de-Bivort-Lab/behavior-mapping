function dataInterp=prepFilterAndInterpData(viData)

% dataInterp=prepFilterAndInterpData(viData)
% Takes data from VI, interpolates and filters it, produces raw data struct.
%
% Inputs:
% viData [NFrames x 29]: frame index, timestamp (ms), leg X 1-6, leg Y 1-6, leg R1-3, leg Theta1-3, leg R4-6, leg Theta4-6, ball i/j/k
%
% Outputs:
% dataInterp [NFrames x 27]: same as viData without frame index or timestamp columns, filtered & interpolated to 100 Hz

% We use a 3-point median filter to reject isolated outliers in our data
medianFilterLen=3;

% Discard frame index, subtract our first timestamp so timestamps are relative to zero
data=viData(:,2:end);
data(:,1)=data(:,1)-data(1,1);

% Now run our median filter on each dim
data(:,2:end)=medfilt1(data(:,2:end),medianFilterLen);

% Interpolate to 100Hz, discard timestamp
dataInterp=interp1(data(:,1),data(:,2:end),0:10:data(end,1));

% Convert to single to save memory, since we've discarded the timestamp we don't need 64-bit precision anymore
dataInterp=single(dataInterp);
