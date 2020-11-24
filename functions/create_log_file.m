function fid = create_log_file(exp_dir, name)

% function fid = create_log_file(exp_dir, name)
% 
% Creates a log file in the directory 'exp_dir/name_logs' with the file ID fid
% - exp_dir : String providing a full path to the main experimental folder,
%             eg '/sdata/images/projects/EESS/1'
% - name    : String of an appropriate name for this log, eg 'recon'
%
% LR 30/07/2011

time = fix(clock);
log_folder = sprintf('%s_logs', name);
s = mkdir(exp_dir, log_folder);

% Change the permissions of this folder for universal access - stops some
% 'Invalid file identifier' bugs if several people are analysing the same
% dataset
unix(sprintf('chmod -R 777 %s', fullfile(exp_dir, log_folder)));

% Check for time entries that have fewer than 2 digits
for i = [2:5]
    if(time(i) < 10)
        new_time{i} = sprintf('0%d', time(i));
    else
        new_time{i} = sprintf('%d', time(i));
    end
end % i

new_time{1} = sprintf('%4d', time(1));    

logfile = fullfile(exp_dir, log_folder, sprintf('log_%s_%s%s%s_%s%s.txt', name, new_time{3}, new_time{2}, new_time{1}, new_time{4}, new_time{5}));
fid = fopen(logfile, 'w');