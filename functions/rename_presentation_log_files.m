function rename_presentation_log_files

% This script will attempt to identify log files by date and time, and
% create an appropriately-renamed copy, with preserved date attributes, and
% the format:
% studyID_taskName_date_time.log
%
% LR 07/08/2011

exp_dir = '/home/images6/liana/Borderline';
logfile_dir = '/home/images6/liana/Borderline/Logs';
csv_file = '/home/images6/liana/Borderline/scripts_and_databases/borderline_csvmaster.csv';
subjects = [1:2];

log_stem = 'cyberball';

mypwd = pwd;

% TO CHANGE - directory where these scripts will live
scriptpath = '/home/images6/liana/ScriptDev';

% Create a log file for this process
fid = create_log_file(exp_dir, 'presentation_rename');

% Check if the first level script directory is on the path; if not - add
check_script_path(scriptpath, fid);

% Read the csv masterfile
[studyID, Date, Time, CRICID, task, T1_sess] = read_csv_masterfile_cric(csv_master, fid);

% Create a subdirectory within the logfile directory for these new files
make_directory(logfile_dir, 'named_logs'), fid;

for sub = 1:length(subjects)
    this_subject = subjects(sub) + 1; % +1 to account for csv header
    
    logfile = find_presentation_log_file(logfile_dir, log_stem, studyID{this_subject}, Date{this_subject}, Time{this_subject});
    
    if(~isempty(logfile))
        % Something was found. Create a new sensible name for this log
        new_name = sprintf('%s_%s_%s_%s.log', studyID{this_subject}, log_stem, Date{this_subject}, Time{this_subject});
        
        [s] = unix(sprintf('cp -p %s %s', fullfile(logfile_dir, 'named_logs', log_file), new_name));        
    else
        % Nothing had a matching time
        disp(sprintf('Could not find a date-matched log for subject %d: %s', sub, studyID{this_subject}))               
    end
end % sub
    