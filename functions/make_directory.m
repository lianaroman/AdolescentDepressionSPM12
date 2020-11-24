function make_directory(parent_dir, child_str, fid)

% function make_directory(parent_dir, child_str, fid)
% Creates a folder in a parent directory, with full logging, given inputs:
% - parent_dir  : String providing a full path to the directory within
%                 which the new folder will be created
% - child_str   : String providing the name of the new folder
% - fid         : File ID returned by fopen() of an open log file
%
% LR 30/07/2011

try
    s = mkdir(parent_dir, child_str);
    new_dir = fullfile(parent_dir, child_str);
    
    if(s)
        log_output(sprintf('Folder %s created in %s', child_str, parent_dir), fid);
    else
        log_output(sprintf('Folder %s failed to be made in %s', child_str, parent_dir), fid);
    end
catch
    l = lasterror;
    log_output('Folder creation failed', fid);
    fprintf(fid, '%s\n', l.message);
end