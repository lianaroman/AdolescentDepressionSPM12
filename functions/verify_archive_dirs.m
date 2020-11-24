function verified = verify_archive_dirs(orig_dir, archive_file)

% function verified = verify_archive_dirs(orig_dir, archive file)
% 
% Unlike verify_archive (which takes complete file lists), this version 
% takes an original uncompressed directory, and an archive file, and checks 
% that they contain the same thing.
%
% LR 18/04/2013

orig_files = dir(orig_dir);
if(isempty(orig_files))
    verified = 0;
else
    orig_files(1:2) = [];
    found_files = zeros(1, length(orig_files));
    
    [s, compr_files] = unix(sprintf('tar -tf %s', archive_file));
    
    for i = 1:length(orig_files);
        if(~isempty(strfind(compr_files, orig_files(1).name)))
            found_files(i) = 1;
        end
    end %i
    
    if(sum(found_files) == length(found_files))
        verified = 1;
    else
        verified = 0;
    end
end