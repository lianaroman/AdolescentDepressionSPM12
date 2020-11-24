function logfile = find_presentation_log_file_cric(logfile_dir, log_stem, subjectID, date, time)

% Presentation may or may not have given the logfile a subject-specific
% name. If not, this script will search by date and time.
%
% LR 07/08/2011

% Extract full date information
year = date(1:4);
month = date(5:6);
day = date(7:8);
hour = time(1:2);
minute = time(3:4);

time_of_day = (60 * hour) + minute;

% Look up the text month
text_month(1) = {'Jan'};
text_month(2) = {'Feb'};
text_month(3) = {'Mar'};
text_month(4) = {'Apr'};
text_month(5) = {'May'};
text_month(6) = {'Jun'};
text_month(7) = {'Jul'};
text_month(8) = {'Aug'};
text_month(9) = {'Sep'};
text_month(10) = {'Oct'};
text_month(11) = {'Nov'};
text_month(12) = {'Dec'};

month = text_month{str2num(month)};

logs = dir(logfile_dir);

% Ditch the '.' and '..' entries
logs(1:2) = [];

for i = 1:length(logs)
    % Check if this is the correct kind of log file
    if(~isempty(strfind(logs(i).name, log_stem)) && ~isempty(strfind(logs(i).name, '.log')))
        % Extract the date/time for this log
        this_year = logs(i).date(8:11);
        this_month = logs(i).date(4:6);
        this_day = logs(i).date(1:2);
        this_hour = logs(i).date(13:14);
        this_minute = logs(i).date(16:17);
        this_time_of_day = (60 * this_hour) + this_minute;

        if(strcmp(year, this_year))
            if(strcmp(month, this_month))
                if(strcmp(day, this_day))
                    % Within an hour of each other
                    if(abs(this_time_of_day - time_of_day) < 60)
                        % We've found a likely culprit for the log file
                        logfile = fullfile(logfile_dir, logs(i).name);
                        break
                    end
                end
            end
        end
    end
    
    if(i==length(logs))
        % Reached the end, no joy
        disp('Error: no presentation log file had a matching time')
        logfile = [];
    end
end % i