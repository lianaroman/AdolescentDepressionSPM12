function subdir = find_subfolder(parent, stem)

this_contents = dir(parent);
temp = regexp({this_contents.name}, stem);
index = find(~cellfun(@isempty, temp));
if(isempty(index))
    subdir = [];
elseif(length(index) == 1)
    %subdir = fullfile(parent, this_contents(~cellfun(@isempty, temp)).name);    
    subdir = {fullfile(parent, this_contents(index).name)};
elseif(length(index) > 1)
    for s = 1:length(index)
        subdir{s} = fullfile(parent, this_contents(index(s)).name);
    %subdir = [repmat([parent '/'], length(index), 1) cell2mat({this_contents(index).name}')];
    end
end