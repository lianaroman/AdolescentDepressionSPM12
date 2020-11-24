function check_script_path(scriptpath, fid)

% function check_script_path(scriptpath, fid)
% Checks if the path that contains the scripts necessary for this procedure
% are currently on the matlab path, given a specified scriptpath. If not,
% add it.
% - scriptpath : String providing a full path to where the scripts are
%                stored
% - fid        : File ID for logging purposes
%
% LR 30/07/2011

if(~isempty(strfind(path, scriptpath)))
    log_output('Script directory on path', fid);
else
    addpath(genpath(scriptpath));
    log_output('Adding script directory to path', fid);
end