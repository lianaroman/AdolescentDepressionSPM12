% function logFiles = find_logfiles(directory, id)
%
% Looks for all presentation .log files with the task identifier id in directory directory
%
% Liana 25/06/2010

function logFiles = find_logfiles(directory, id)

W = dir(directory);

count = 1;

for i = 1:length(W)
	if(~isempty(strfind(W(i).name, 'log')) && ~isempty(strfind(W(i).name, id)))
		% We've found a log file for the requested experiment
		logFiles{count} = W(i).name;
		count = count + 1;
	end
end