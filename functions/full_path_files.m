function files = full_path_files(parent_dir, prefix)

% function files = full_path_files(parent_dir, prefix)
% Lists all the files with the specified regexp prefix in parent_dir, 
% complete with full paths, in a format that SPM expects when specifying 
% big lists of scans. A prefix of '.*' returns all files.
%
% LR 07/08/2011

temp = [];
temp = spm_select('List', parent_dir, prefix);
%files = cellstr([repmat([parent_dir '/'], size(temp, 1), 1), temp, repmat(',1', size(temp,1), 1)])

if(~isempty(strfind(computer, 'WIN')))
    files = cellstr([repmat([parent_dir '\'], size(temp, 1), 1), temp]);
else
    files = cellstr([repmat([parent_dir '/'], size(temp, 1), 1), temp]);
end