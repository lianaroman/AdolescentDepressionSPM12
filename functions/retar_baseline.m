function retar_baseline(exp_dir, csv_master, subjects, experiment)

% For when I've accidentally compressed things with the full
% /sdata/images/... structure - uncompress, render it locally, and
% recompress.
%
% LR 05/10/2012

mypwd = pwd;

% Read the csv masterfile
[studyID, Date, Time, CRICID, Group, task, T1_sess] = read_csv_masterfile_cric(csv_master, 0);

for exp = 1:length(experiment)
    % Determine the number of sessions for this experiment
    no_of_sessions = length(experiment(exp).session);
    
    for sub = 1:length(subjects)
        this_subject = subjects(sub) + 1; % +1 to account for csv header
        subject_dir = fullfile(exp_dir, studyID{this_subject});
        date_dir = fullfile(subject_dir, sprintf('%s_%s', Date{this_subject}, Time{this_subject}));
        
        % Tidy up the data and its intermediate files
        for sess = 1:no_of_sessions
            log_output(sprintf('Tidying data for session %d', sess), 0);
            this_sess = experiment(exp).session(sess);
            series_dir = fullfile(exp_dir, studyID{this_subject}, sprintf('%s_%s', Date{this_subject}, Time{this_subject}), sprintf('%s_%s', task{this_sess}{this_subject}, task{this_sess}{1}));
             
            cd(series_dir)
            [s, r] = unix('tar -tf baseline.tar');
            
            % Check if it needs doing
            if(strfind(r(1:5), 'sdata'))
                [s, r] = unix('tar -xf baseline.tar');
                [s, r] = unix(sprintf('mv %s/baseline .', series_dir(2:end)));
                
                % Check it worked
                if(~isempty(dir('baseline')))
                    [s, r] = unix(sprintf('rm -rf %s/sdata', series_dir));
                    [s, r] = unix('tar -cf baseline.tar baseline/');
                    
                    % Check it worked
                    if(~isempty(dir('baseline.tar')))
                        [s, r] = unix('rm -rf baseline');
                    end
                end
            end
        end % sess
    end % sub
end % exp