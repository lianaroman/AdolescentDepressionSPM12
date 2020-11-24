function check_analysis_dir(analysis_dir)

% function check_analysis_dir(analysis_dir)
%
% To be used within second level analysis scripts - check that the intended
% destination directory exists, and if not, creates it
%
% 25/08/2012

if(isempty(dir(analysis_dir)))
    % Doesn't exist yet - create
    [p, n, e] = fileparts(analysis_dir);
    s = mkdir(p, n);
end