function out = cellarray2str2mat(this_cellArray)

% function out = cellarray2str2mat(this_cellArray)
%
% Takes a cell array of strings of numericals, converts it to a character
% array, with zero padding (up to 10 characters), then converts this to a
% double matrix
%
% LR 27/10/2016

D = cellfun(@(x)sprintf('%010s',x),this_cellArray,'uni',false);
out = str2num(cell2mat(D));    