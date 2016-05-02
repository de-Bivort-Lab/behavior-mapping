function iDataFrames=movieFrameToDataFrames(iFirstValidMovieFrame,iMovieFrame)
   
% iDataFrames=movieFrameToDataFrames(iFirstValidMovieFrame,iMovieFrame)
% Convert the given movie frame number into a range of analyzed data frames
%
% Inputs:
% iFirstValidMovieFrame [double]: movie frame corresponding to the first frame of our data
% iMovieFrame [double]: movie frame we want to convert
%
% Outputs:
% iDataFrames [double]: all data frames which overlap the given movie frame

[DataFrameRate,MovieFrameRate]=dataAndMovieFrameRates();

% Find the given movie frame start and end time in seconds
startSeconds=(iMovieFrame-iFirstValidMovieFrame)/MovieFrameRate;
endSeconds=(iMovieFrame-iFirstValidMovieFrame+1)/MovieFrameRate;

% Convert to data frames
iDataStartFrame=round(startSeconds*DataFrameRate);
iDataEndFrame=round(endSeconds*DataFrameRate);
iDataFrames=iDataStartFrame:iDataEndFrame;
