function [studyID, Chi, Subfolder, Exam, IFIS, task, T1_sess, behFolder] = read_csv_masterfile_WGH(csv_master, fid)

% function [studyID, Date, Time, CRICID, task] = read_csv_masterfile_WGH(csv_master, fid)
%
% Custom version for MotorInhib2
% Extracts the crucial information for a csv masterfile formatted for WGH
% scans. Inputs:
% - csv_master  : string describing full path to study's csv masterfile,
%                 which should conform to the WGH csv template. The first
%                 four columns contain crucial info for locating data; then
%                 there are 8 ignorable columns providing variables not
%                 crucial to fMRI preprocessing; then the next few (number 
%                 can vary) state the name of each series acquisition, the 
%                 last of which must be 'T1', which informs this script to 
%                 stop looking for more series.
% - fid         : File ID [returned by fopen()] of an open log file for
%                 this procedure
%
% Outputs:
% - studyID, Chi, Subfolder, Exam, task : Cell arrays of strings containing the 
%                                       corresponding columns of the csv
%                                       file, including column headers.
%                                       NOTE: to accomodate this header,
%                                       the output variables must be
%                                       indexed with a +1 shift
% - T1_sess : integer stating which column the T1 series no appears in
% - behFolder : Initials of the participant, which identifies their IFIS
% data folder 
% LR 05/08/2013

try
    [studyID Chi Subfolder Exam IFIS Group task{1} task{2} task{3} task{4} task{5} task{6} task{7} task{8} task{9} task{10} ...
        task{11} task{12} task{13} task{14} task{15} task{16} task{17} task{18} task{19} task{20} task{21} task{22}] = textread(csv_master, '%s %s %s %s %s %s %*s %*s %*s %*s %*s %*s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %*[^\n]', 'delimiter', ',', 'emptyvalue', NaN);
    
    log_output('csv masterfile loaded', fid);
catch
    l = lasterror;
    log_output(sprintf('Could not load csv %s', csv_master), fid);
    fprintf(fid, '%s\n', l.message);
end

% Establish how many series' there are, and what to call them
task_names = '';
for t = 1:length(task)    
    % Remove extra spaces from series names, if present
    task{t}{1} = strrep(task{t}{1}, ' ', '');
    task_names = [task_names '_' task{t}{1}];
    
    % Stop when T1 is found
    if(strcmp(task{t}{1}, 'T1'))
        T1_sess = t;
        
        log_output(sprintf('%d series found: %s', T1_sess, task_names), fid);
        break
    end      
end % t

behFolder = task(T1_sess + 1);

% Ditch the rest of the csv file columns
task = task(1:T1_sess);