function log_output(message, fid)

% Outputs a text message to both an already open log file referenced with
% fid, and the main screen. If fid is 0, it won't write to a log file.
%
% LR 30/07/2011

if(fid > 0)
    fprintf(fid, [message '\n']);    
end

disp(sprintf('%s\n', message));