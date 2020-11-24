function chi = check_chi(chi)

% Checks a chi for madness - is it missing a leading zero?
%
% HCW & LR 26/10/2011

if(chi(1) == 'S')
    % Leave alone
else
    if(length(chi) < 10)
        % Missing a zero
        chi = ['0' chi];
    end
end