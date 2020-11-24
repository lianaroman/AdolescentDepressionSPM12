function motion_param_check(motion_file, vols)

[this_path, name, ext] = fileparts(motion_file);

temp = dlmread(motion_file);
difference = size(temp,1) - vols;

if(difference > 0)
    temp(1:difference, :) = [];
end

dlmwrite(motion_file, temp, 'delimiter', '\t', 'precision', 8);