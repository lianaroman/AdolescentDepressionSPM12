function answer = check_dir_exists(parent, folder, action)

% function answer = check_dir_exists(parent, folder, action)
% 
% - If action is [], checks for the regexp expression 'folder' within parent,
%   and returns 1 if it exists.
% - If action is 'create', it will create 'folder' - which in this case
%   needs to be more well-defined than a regexp expression - inside parent
% - If action is a string other than 'create', will rename anything
%   matching 'folder' within parent to action
%
% LR 2/5/15

% First check the parent exists
if(isempty(dir(parent)))
    answer = 0;
    display(sprintf('The parent %s does not exist', parent))
else
    w = dir(parent);
    %w = dir(fullfile(parent, folder));
    
    temp = regexp({w(:).name}, folder, 'match');
    
    if(isempty(cell2mat([temp{:}])))
    %if(isempty(w))
        % The folder doesn't exist
        answer = 0;
        
        if(strcmp(action, 'create'))
            % Create a subfolder            
            o = unix(sprintf('mkdir %s/%s', parent, folder));
            display(sprintf('Created %s/%s', parent, folder));
        end
    else
        % The folder exists
        answer = 1;
        display(sprintf('%s/%s already exists', parent, folder));
        
        if(~isempty(action) & ~strcmp(action, 'create'))
            % Rename the found folder as specified
            temp = cell2mat([temp{:}]);
            display(sprintf('Renaming %s/%s to %s', parent, temp, action));
            o = unix(sprintf('mv %s/%s %s/%s', parent, temp, parent, action));
        end
    end
end