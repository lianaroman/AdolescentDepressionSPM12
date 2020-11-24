function P = softmax(Q_values, temperature)
% Softmax probability evaluation based on Q values
%
% Inputs:
% - Q_values    : A 1 x c vector of Q values for c actions
% - temperature : The beta parameter
%
% Softmax = Pa(t) =               e^(Qa(t) / temperature)
%                   -------------------------------------------------
%                   e^(Qa(t) / temperature) + e^(Qb(t) / temperature)
% 
% LR 25/07/2011

% The number of choosable actions
n = length(Q_values);

total = 0;
for i = 1:n
    % Sum probability of all actions
    total = total + exp((1 / temperature) * Q_values(i));
    % get the sum of all action values.
end

for i = 1:n
    % Probability of each individual action
    P(i) = exp((1 / temperature) * Q_values(i)) / total;
end
