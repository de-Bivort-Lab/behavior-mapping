function iMovieFrame=dataFrameToMovieFrame(iFirstValidMovieFrame,iDataFrame)
   
% iMovieFrame=dataFrameToMovieFrame(iFirstValidMovieFrame,iDataFrame)
% Convert the given data frame to a movie frame number
%
% Inputs:
% iFirstValidMovieFrame [double]: movie frame corresponding to the first frame of our data
% iDataFrame [double]: data frame index we want to convert to a movie frame number
%
% Outputs:
% iMovieFrame [double]: corresponding frame in the given fly's movie

[DataFrameRate,MovieFrameRate]=dataAndMovieFrameRates();

% Find the given data frame time in seconds
seconds=(iDataFrame-1)/DataFrameRate;

% Convert to movie frames
iMovieFrame=iFirstValidMovieFrame+round(seconds*MovieFrameRate);
