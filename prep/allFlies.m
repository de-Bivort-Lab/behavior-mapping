function [flies,nanFlies,wtFlies,flyPrefixes]=allFlies()

% flies=allFlies()
% Return a cell array with flies for which we have data
%
% Outputs:
% flies [1 x 27 string]: fly names for which we have data
% nanFlies [1 x 5 string]: NAN flies for which we have data
% wtFlies [1 x 22 string]: wild-type flies for which we have data
% flyPrefixes [1 x 17 string]: fly names prefixes for which we have data, these correspond to unique individuals

% These are flies with long experiments and bimodal variance data (so we can filter out low-variance data), omitting:
% Short experiments: f12, f13, f14, f19, f24
% Non bi-modal variance distributions: f130522, f130616, f130617
%
% flies starting with 'f130' are NAN mutants, the others are WT
flies={'f37_1', 'f37_2', 'f37_3', 'f38_1', 'f38_2', 'f39_1',...
       'f39_2', 'f40', 'f42', 'f43_1', 'f43_2', 'f44_1', 'f44_2', 'f53_1', 'f53_2', 'f53_3',...
       'f55', 'f59', 'f62_1', 'f62_2', 'f63_1', 'f63_3', ...
       'f130520', 'f130615', 'f130621', 'f130626', 'f130627'};
nanFlies=flies;
nanFlies(~strncmp('f130',nanFlies,4))=[];
wtFlies=flies;
wtFlies(strncmp('f130',wtFlies,4))=[];

% Gather fly name prefixes
flyPrefixes={};
for flyCell=flies
    tokens=strsplit(flyCell{1},'_');
    flyPrefix=tokens{1};
    if ~any(strcmp(flyPrefixes,flyPrefix))
        flyPrefixes{end+1}=flyPrefix; %#ok<AGROW>
    end
end
