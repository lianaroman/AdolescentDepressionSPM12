function [data_exists, data_in_baseline] = check_for_data(prefix, series_dir)

%% function [data_exists, data_in_baseline] = check_for_data(prefix)
% Given a prefix...
% - a : slice_corrected
% - r : realigned
% - w : normalised
% - s : smoothed
% ...will determine whether or not the data exists, and if so, whether it
% still lives in the /baseline folder, or if its already been moved to its
% appropriate subfolder% 
%
% LR 06/09/2011

%% Identify data/folder to search for
switch prefix
    
    case 'S'
        folder_name = 'baseline';
    
    case 'a'         
        folder_name = 'slice_corrected';
    
    case 'r'
        folder_name = 'realigned';
        
    case 'w'
        folder_name = 'normalised';
        
    case 's'
        folder_name = 'smoothed';
        
    otherwise
        disp('Not a valid data prefix')
end

%% Check for the data in /baseline
baseline_contents = dir(fullfile(series_dir, 'baseline'));

% Remove 1st 2 guffy entries
baseline_contents(1:2) = [];

baseline_file_found = zeros(1,length(baseline_contents));

for file = 1:length(baseline_contents)
    if(~isempty(strfind(baseline_contents(file).name, prefix)))
        if(strfind(baseline_contents(file).name, prefix) == 1)
            % If its at the beginning, ie actually a prefix
            baseline_file_found(file) = 1;
        end
    end
end % file

%% Check whether a subfolder for this data already exists
series_contents = dir(series_dir);
folder_found = 0;

for file = 1:length(series_contents)    
    if(~isempty(strfind(series_contents(file).name, folder_name)))
        folder_found = 1;
    end
end % file

%% Check whether this subfolder contains any data
folder_data_found = 0;
if(folder_found)    
    folder_contents = dir(fullfile(series_dir, folder_name));
    
    if(length(folder_contents) > 3)
        % This folder contains data
        folder_data_found = 1;
    end
end

%% Determine the state of play
if(folder_data_found || sum(baseline_file_found) > 1)
    data_exists = 1;
else
    data_exists = 0;
end

if(sum(baseline_file_found) > 1)
    data_in_baseline = 1;
else
    data_in_baseline = 0;
end