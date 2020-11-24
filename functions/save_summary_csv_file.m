% function save_summary_csv_file(directory, column_heads, data)
%
% Save data to a spreadsheet-importable .csv file, with data appended to filename, 
% complete with column_heads, within directory
%
% By Liana 25/06/2010

function success = save_summary_csv_file(directory, column_heads, data, filestem)

try
	[Y,MO,D,H,MI,S] = datevec(now);
	write_filename = fullfile(directory, sprintf('%s_results_%d-%d-%d_%d-%d.txt', filestem, D, MO, Y, H, MI))
	fid = fopen(write_filename, 'w');
	fprintf(fid, '%s\n', column_heads);
	dlmwrite(write_filename, data, 'delimiter', ',', '-append');
	success = 1;
catch
	success = 0;
end