function this_date = check_date_time(in_date, in_time)

% Check if the Date and Time have been separated
if(isempty(in_time))
    % Remove any slashes if present
    this_date = strrep(in_date, '/', '');
else
    this_date = sprintf('%s_%s', in_date, in_time);
end