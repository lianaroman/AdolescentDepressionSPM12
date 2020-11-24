function exp_begin = find_Presentation_exp_begin(event_label, onset_time, discard_vols)

% function exp_begin = find_Presentation_exp_begin(event_label, onset_time, discard_vols)
%
% Given a Presentation log file's event label column (listing Picture,
% Pulse, Response etc), the onset time column, and the number of volumes 
% you intend to discard, will return the experiment onset time in seconds
%
% LR 07/04/2013

pulse_count = 0;

for line = 1:length(event_label)
    if(strfind(event_label{line}, 'Pulse'))
        pulse_count = pulse_count + 1;
        
        if(pulse_count == discard_vols + 1)
            exp_begin = str2num(onset_time{line}) / 10000;
            break
        end
    end
end