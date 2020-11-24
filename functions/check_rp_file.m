function check_rp_file(rp_file)

% function check_rp_file(rp_file)
%
% For AvCond experiments, checks if there's 266 rather than the desired 265
% datapoints. Some subjects had their mean image accidentally included,
% which will appear 1st, and won't throw everything else off as it is a
% mean.
%
% LR 18/05/2013

[nums{1} nums{2} nums{3} nums{4} nums{5} nums{6}] = textread(rp_file, '%f %f %f %f %f %f');

if(length(nums{1}) > 265)
    for p = 1:6
        nums{p}(1) = [];
    end
    
    out = cell2mat(nums);
    
    dlmwrite(rp_file, out, 'delimiter', '\t');
end
