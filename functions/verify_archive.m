function verified = verify_archive(orig_files, archive_files)

%% function verified = verify_archive(orig_files, archive_files)
% Looks for each of the files specified in orig_files within the archive 
% file listing provided in archive_files, returning 1 if they're all there
%
% LR 09/09/2011

file_found = zeros(1,length(orig_files));

for i = 1:length(orig_files)
    looking = cell2mat(strfind(archive_files, orig_files{i}));
    
    if(~isempty(looking))
        file_found(i) = 1;
    end    
end % i

if(sum(file_found) == length(orig_files))
    verified = 1;
else
    verified = 0;
end
