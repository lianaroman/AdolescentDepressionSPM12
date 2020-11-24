function files = dir_files(dir_folder)

% function files = parse_dir_files(dir_contents)
% Lists all the files in dir_folder as a cell array of strings 'files'
%
% LR 09/09/2011

orig_contents = dir(dir_folder);
files = [];
for i = 1:length(orig_contents);
    files{i} = orig_contents(i).name;
end
