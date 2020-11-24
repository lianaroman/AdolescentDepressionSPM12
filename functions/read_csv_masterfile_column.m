function [col_data] = read_csv_masterfile_column(csv_master, column, fid)

% function [studyID, Date, Time, CRICID, task] = read_csv_masterfile_WGH(csv_master, fid)
% Extracts a single specified column from a masterfile. Inputs:
% - csv_master  : string describing full path to study's csv masterfile,
%                 which should conform to the WGH csv template. The first
%                 four columns contain crucial info for locating data; then
%                 there are 8 ignorable columns providing variables not
%                 crucial to fMRI preprocessing; then the next few (number 
%                 can vary) state the name of each series acquisition, the 
%                 last of which must be 'T1', which informs this script to 
%                 stop looking for more series.
% - column      : Index of the column to be extracted
% - fid         : File ID [returned by fopen()] of an open log file for
%                 this procedure
%
% Outputs:
% - col_data    : Cell array of strings containing the corresponding 
%                   columns of the csv file, including column headers. 
%                   NOTE: to accomodate this header, the output variables 
%                   must be indexed with a +1 shift
%
% LR 20/04/2012

try
    format_string = [repmat('%*s ', 1, column - 1) '%s %*[^\n]'];
    [col_data] = textread(csv_master, format_string, 'delimiter', ',', 'headerlines', 1, 'emptyvalue', NaN);
    
    log_output('csv masterfile loaded', fid);
catch
    l = lasterror;
    log_output(sprintf('Could not load csv %s', csv_master), fid);
    fprintf(fid, '%s\n', l.message);
end