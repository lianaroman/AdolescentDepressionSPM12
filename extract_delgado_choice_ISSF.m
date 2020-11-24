function [Presentation_matfile, contrasts, TR, units, varargout] = extract_delgado_choice_ISSF(logfile, studyID, output_dir)

% function [Presentation_matfile, contrasts, TR, units (, choiceRT, noChoiceRT)] = extract_delgado_choice(logfile, studyID)
% 
% Extracts and defines condition names/onsets/durations for the Delgado
% reward task. There is the option to add extra output arguments,
% providing the reaction times for the choice and noChoice trials.
% Varargout returns the following:
% choiceRT, noChoiceRT, choice_noResp, noChoice_noResp, noChoice_miss, 
% noChoice_fixedTrials, choice_reward, noChoice_reward
%
% The _ISSF variant has different important trial listings:
% - choice/noChoice_      : First part, denotes the trial condition
% - _cue/response/reward_ : Second part, denoting the phases within the
%                           trial
% - _cue_Y0/Y100_         : For this trial, whether purple (substituted for
%                           old yellow) is associated with a reward of 0 or 100
% - _cue/reward_..._Ryel/Lyel : 
%                           Whether the purple (new yellow) appears on the
%                           left or right. The response buttons are 1 for
%                           left, 2 for right.
% - _reward_0/100_        : Reward phase, what was received
% - _reward_..._choseYel/choseBlu_ :
%                           The colour of the cue they chose, purple (yel)
%                           or turquoise (blu)
% - noChoice_cue_0/100    : For noChoice trials, the choice they will be
%                           forced to make will earn them 0 or 100
% - noChoice_cue_..._forceYel/forceBlu :
%                           For noChoice trials, the colour they will be
%                           forced to choose, purple (yel) or turquoise (blu)
% 
% LR 051120

%% Initialise
units = 'secs';

[this_path, name, ext] = fileparts(logfile);
[event, type, time] = textread(logfile, '%*s %*s %s %s %d %*[^\n]', 'delimiter', '\t', 'headerlines', 5);

% Determine the experiment's true beginning - onset of the 7th pulse - and
% the TR
pulse_idx = find(strcmp(event, 'Pulse'));
exp_begin = time(pulse_idx(7)) / 10000;
TR = (time(pulse_idx(2)) - time(pulse_idx(1))) / 10000;

% % Save data describing noChoice trial misses, fixed outcomes and giving up
% header = 'studyID, noChoice_miss, noChoice_fixedTrials, noChoice_noResp, noChoice_noRespMean,  noChoice_missMean,';
% data_out = fopen(fullfile(output_dir, 'behav_out.csv'), 'a');
% fprintf(data_out, '%s\n', header);

%% Pull out onsets and create SPM 1st level defs
choice_ons{1} = find(strncmp('choice_cue_Y0', type, 13));
choice_ons{2} = find(strncmp('choice_cue_50', type, 13));
choice_ons{3} = find(strncmp('choice_cue_Y100', type, 15));
choice_ons_all = union(choice_ons{1}, union(choice_ons{2}, choice_ons{3}));
noChoice_ons{1} = union(find(strncmp('noChoice_cue_0', type, 14)), find(strncmp('noChoice_cue_Y0', type, 15)));
noChoice_ons{2} = find(strncmp('noChoice_cue_50', type, 15));
noChoice_ons{3} = union(find(strncmp('noChoice_cue_100', type, 16)), find(strncmp('noChoice_cue_Y100', type, 17)));
noChoice_ons_all = union(noChoice_ons{1}, union(noChoice_ons{2}, noChoice_ons{3}));
cue_ons = union(choice_ons_all, noChoice_ons_all);

response_phase_ons = union(find(strncmp('choice_response', type, 15)), find(strncmp('noChoice_response', type, 17)));

response_ons = find(strcmp(event, 'Response'));
miss_ons = find(strcmp(type, 'noChoice_reward_miss'));
choice_no_response_ons = find(strcmp(type, 'choice_no_response'));
noChoice_no_response_ons = find(strcmp(type, 'noChoice_no_response'));
nuisance_ons = union(choice_no_response_ons, union(noChoice_no_response_ons, miss_ons));
ISI_ons = find(strcmp(type, 'ISI'));

reward_choice_ons{1} = find(strncmp('choice_reward_0', type, 15));
reward_choice_ons{2} = find(strncmp('choice_reward_50', type, 16));
reward_choice_ons{3} = find(strncmp('choice_reward_100', type, 17));
%reward_choice_ons = union(find(strcmp(type, 'choice_reward_0')), union(find(strcmp(type, 'choice_reward_50')),find(strcmp(type, 'choice_reward_100'))));
reward_noChoice_ons{1} = union(find(strncmp('noChoice_reward_0', type, 17)), find(strncmp('noChoice_reward_Y0', type, 18)));
reward_noChoice_ons{2} = find(strncmp('noChoice_reward_50', type, 18));
reward_noChoice_ons{3} = union(find(strncmp('noChoice_reward_100', type, 19)), find(strncmp('noChoice_reward_Y100', type, 20)));
%reward_noChoice_ons = union(find(strcmp(type, 'noChoice_reward_0')), union(find(strcmp(type, 'noChoice_reward_50')),find(strcmp(type, 'noChoice_reward_100')))); 
%reward_ons = union(reward_choice_one, reward_noChoice_ons);
noResp = [0,0];

% trial_type and rewarsd lists the onset volumes of each trial's cue and reward
% phases respectively, and either its trial type, 1 choice, 2 noChoice or
% reward outcome 0 or 100
trial_type(1,1:length(choice_ons_all)) = choice_ons_all;
trial_type(2,1:length(choice_ons_all)) = 1;
temp(1,1:length(noChoice_ons_all)) = noChoice_ons_all;
temp(2,1:length(noChoice_ons_all)) = 2;
trial_type = [trial_type temp]';
trial_type = sortrows(trial_type);

rewards = [];
for r = [1:2]
    temp = [];
    temp(1,1:length(reward_choice_ons{((r-1)*2)+1})) = reward_choice_ons{((r-1)*2)+1};
    temp(2,1:length(reward_choice_ons{((r-1)*2)+1})) = (r-1)*100;
    rewards = [rewards temp];
end
for r = [1:2]
    temp = [];
    temp(1,1:length(reward_noChoice_ons{((r-1)*2)+1})) = reward_noChoice_ons{((r-1)*2)+1};
    temp(2,1:length(reward_noChoice_ons{((r-1)*2)+1})) = (r-1)*100;
    rewards = [rewards temp];
end
temp = [];
temp(1,1:length(miss_ons)) = miss_ons;
temp(2,1:length(miss_ons)) = 8;
rewards = [rewards temp];
temp = [];
temp(1,1:length(choice_no_response_ons)) = choice_no_response_ons;
temp(2,1:length(choice_no_response_ons)) = 3;
rewards = [rewards temp];
temp = [];
temp(1,1:length(noChoice_no_response_ons)) = noChoice_no_response_ons;
temp(2,1:length(noChoice_no_response_ons)) = 4;
rewards = [rewards temp];
rewards = rewards';
rewards = sortrows(rewards);

out = [trial_type(:,2) rewards(:,2)];
choice_idx = find(out(:,1) == 1);
noChoice_idx = find(out(:,1) == 2);
out(noChoice_idx, 3) = out(choice_idx(1:length(noChoice_idx)),2);
for c = 1:length(noChoice_idx)
    if(c == 1)
        out(noChoice_idx(c), 4) = length(find(choice_idx < noChoice_idx(c)));
    else
        out(noChoice_idx(c), 4) = length(find(choice_idx < noChoice_idx(c))) - c;
    end
end

out(find(out(:,1)==2), :)
studyID
% length(find(out(:,4)<0))
% length(find(out(:,2)==4))
% mean(diff(find(out(:,2)==4)))
% length(find(out(:,2)==8))
% mean(diff(find(out(:,2)==8)))
% fprintf(data_out, '%s, %d, %d, %0.3f, %d, %0.3f\n', studyID, ...
%                                                     length(find(out(:,2)==8)), ...
%                                                     length(find(out(:,4)<0)), ...
%                                                     length(find(out(:,2)==4)), ...
%                                                     mean(diff(find(out(:,2)==4))), ...
%                                                     mean(diff(find(out(:,2)==8))));
% fclose(data_out);
                                                
if(isempty(choice_ons{2}))
    names = {'choice_cue', 'noChoice_cue', 'choice_response', 'noChoice_response', 'choice_reward_0', 'choice_reward_100', 'noChoice_reward_0', 'noChoice_reward_100', 'nuisance'};
    reward_choice_ons(2) = [];
    reward_noChoice_ons(2) = [];
    nui = 9;
    ch = 6;
    tot = 9;
    reward(1) = 100*length(reward_choice_ons{2});
    reward(2) = 100*length(reward_noChoice_ons{2});    
else
    names = {'choice_cue', 'noChoice_cue', 'choice_response', 'noChoice_response', 'choice_reward_0', 'choice_reward_50', 'choice_reward_100', 'noChoice_reward_0', 'noChoice_reward_50', 'noChoice_reward_100', 'nuisance'};
    nui = 11;
    ch = 7;
    tot = 11;
    reward(1) = (100*length(reward_choice_ons{3})) + (50*length(reward_choice_ons{2}));
    reward(2) = (100*length(reward_noChoice_ons{3})) + (50*length(reward_noChoice_ons{2}));    
end

onsets = cell(length(names),1);
durations = onsets;
RT = cell(2,1);
display(sprintf('Total reward - choice: %d, noChoice: %d', reward(1), reward(2)));

%% Evaluate trials
for i = 1:length(cue_ons)
    % Check if this is going to be a nuisance trial
    for k = 1:100
        if(strcmp(type{cue_ons(i) + k}, 'ISI'))
            this_ISI = cue_ons(i) + k;
            break
        end        
    end % k
    
    if(~isempty(intersect(find(nuisance_ons > cue_ons(i)), find(nuisance_ons < this_ISI))))
        % This is a nuisance trial
        onsets{nui} = [onsets{nui} (time(cue_ons(i)) / 10000) - exp_begin];
        durations{nui} = [durations{nui} 0];
        
        if(~isempty(intersect(choice_ons_all, cue_ons(i))))
            noResp(1) = noResp(1) + 1;
        else
            noResp(2) = noResp(2) + 1;
        end
        
    else
        % Cue phase
        this_cue_onset = (time(cue_ons(i)) / 10000) - exp_begin;
        
        % Response phase
        overlap = response_phase_ons(intersect(find(response_phase_ons > cue_ons(i)), find(response_phase_ons < this_ISI)));
        this_response_phase_onset = (time(overlap) / 10000) - exp_begin;
        RT_overlap = response_ons(intersect(find(response_ons > response_phase_ons(i)), find(response_ons < this_ISI)));
        
        if(isempty(RT_overlap))
            % They pressed before the choice screen appeared -
            % nuisance
            onsets{nui} = [onsets{nui} (time(cue_ons(i)) / 10000) - exp_begin];
            durations{nui} = [durations{nui} 0];
            
        else
            % Check for choice or noChoice trial
            if(~isempty(intersect(choice_ons_all, cue_ons(i))))
                % Choice trial
                % Cue phase                
                onsets{1} = [onsets{1} this_cue_onset];
                durations{1} = [durations{1} 0];
                
                % Response phase                
                onsets{3} = [onsets{3} this_response_phase_onset];
                durations{3} = [durations{3} 0];
                
                RT{1} = [RT{1} (time(RT_overlap(1)) - time(overlap)) / 10000];
                
                for cond = 1:length(reward_choice_ons)
                    overlap = reward_choice_ons{cond}(intersect(find(reward_choice_ons{cond} > cue_ons(i)), find(reward_choice_ons{cond} < this_ISI)));
                    
                    if(~isempty(overlap))
                        onsets{4+cond} = [onsets{4+cond} (time(overlap) / 10000) - exp_begin];
                        durations{4+cond} = [durations{4+cond} 0];
                        break
                    end
                end % cond
                
            elseif(~isempty(intersect(noChoice_ons_all, cue_ons(i))))
                % noChoice trial
                % Cue phase                
                onsets{2} = [onsets{2} this_cue_onset];
                durations{2} = [durations{2} 0];
                
                % Response phase                
                onsets{4} = [onsets{4} this_response_phase_onset];
                durations{4} = [durations{4} 0];
                
                RT{2} = [RT{2} (time(RT_overlap(1)) - time(overlap)) / 10000];
                
                for cond = 1:length(reward_noChoice_ons)
                    overlap = reward_noChoice_ons{cond}(intersect(find(reward_noChoice_ons{cond} > cue_ons(i)), find(reward_noChoice_ons{cond} < this_ISI)));
                    
                    if(~isempty(overlap))
                        onsets{ch+cond} = [onsets{ch+cond} (time(overlap) / 10000) - exp_begin];
                        durations{ch+cond} = [durations{ch+cond} 0];
                        break
                    end
                end % cond
            end
        end
    end
end % i

%% Add a dummy trial to columns if they are empty
for c = 1:length(onsets)
    if(isempty(onsets{c}))
        onsets{c} = [onsets{c} ((time(c) / 10000) - exp_begin - 1)'];
        durations{c} = [durations{c} 0];
    end
end

%% Save the mat file and contrasts
% If there is no study ID, pull out the log file number
if(isempty(studyID))
    studyID = this_name(1:4);
end

%if(calc_RT)
    varargout{1} = RT{1};
    varargout{2} = RT{2};
    varargout{3} = noResp(1);
    varargout{4} = noResp(2);
    varargout{5} = length(find(out(:,2)==8));
    varargout{6} = length(find(out(:,4)<0));
    varargout{7} = reward(1);   
    varargout{8} = reward(2);   
%end

%% Specifying contrasts to evaluate at the first level
con_c = 1;
contrasts(con_c).name = 'Basic motor test';
contrasts(con_c).vector = [0 0 1 1 zeros(1,tot-4)];
con_c = con_c + 1;

contrasts(con_c).name = 'Choice cue > Rest';
contrasts(con_c).vector = [1 zeros(1,tot-1)];
con_c = con_c + 1;

contrasts(con_c).name = 'NoChoice cue > Rest';
contrasts(con_c).vector = [0 1 zeros(1,tot-2)];
con_c = con_c + 1;

contrasts(con_c).name = 'Choice > noChoice cue';
contrasts(con_c).vector = [1 -1 zeros(1,tot-2)];
con_c = con_c + 1;

% contrasts(con_c).name = 'noChoice > Choice cue';
% contrasts(con_c).vector = [-1 1 zeros(1,tot-2)];
% con_c = con_c + 1;

contrasts(con_c).name = 'Choice response > Rest';
contrasts(con_c).vector = [0 0 1 zeros(1,tot-3)];
con_c = con_c + 1;

contrasts(con_c).name = 'noChoice response > Rest';
contrasts(con_c).vector = [0 0 0 1 zeros(1,tot-4)];
con_c = con_c + 1;

contrasts(con_c).name = 'choice > noChoice response';
contrasts(con_c).vector = [0 0 1 -1 zeros(1,tot-4)];
con_c = con_c + 1;

% contrasts(con_c).name = 'noChoice > Choice response';
% contrasts(con_c).vector = [0 0 -1 1 zeros(1,tot-4)];
% con_c = con_c + 1;

contrasts(con_c).name = 'Choice reward 0 > Rest';
contrasts(con_c).vector = [0 0 0 0 1 zeros(1,tot-5)];
con_c = con_c + 1;

contrasts(con_c).name = 'Choice reward 100 > Rest';
contrasts(con_c).vector = [0 0 0 0 0 1 zeros(1,tot-6)];
con_c = con_c + 1;

contrasts(con_c).name = 'Choice increasing reward';
contrasts(con_c).vector = [0 0 0 0 -1 1 zeros(1,tot-6)];
con_c = con_c + 1;

% contrasts(con_c).name = 'Choice decreasing reward';
% contrasts(con_c).vector = [0 0 0 0 1 -1 zeros(1,tot-6)];
% con_c = con_c + 1;

contrasts(con_c).name = 'NoChoice reward 0 > Rest';
contrasts(con_c).vector = [0 0 0 0 0 0 1 zeros(1,tot-7)];
con_c = con_c + 1;

contrasts(con_c).name = 'NoChoice reward 100 > Rest';
contrasts(con_c).vector = [0 0 0 0 0 0 0 1 0];
con_c = con_c + 1;

contrasts(con_c).name = 'NoChoice increasing reward';
contrasts(con_c).vector = [0 0 0 0 0 0 -1 1 0];
con_c = con_c + 1;

% contrasts(con_c).name = 'NoChoice decreasing reward';
% contrasts(con_c).vector = [0 0 0 0 0 0 1 -1 0];
% con_c = con_c + 1;

contrasts(con_c).name = 'Choice reward > Rest';
contrasts(con_c).vector = [0 0 0 0 1 1 0 0 0];
con_c = con_c + 1;

contrasts(con_c).name = 'NoChoice reward > Rest';
contrasts(con_c).vector = [0 0 0 0 0 0 1 1 0];
con_c = con_c + 1;

contrasts(con_c).name = 'Choice reward > NoChoice reward';
contrasts(con_c).vector = [0 0 0 0 1 1 -1 -1 0];
con_c = con_c + 1;

contrasts(con_c).name = '100 reward > Rest';
contrasts(con_c).vector = [0 0 0 0 0 1 0 1 0];
con_c = con_c + 1;

contrasts(con_c).name = '0 reward > Rest';
contrasts(con_c).vector = [0 0 0 0 1 0 1 0 0];
con_c = con_c + 1;

contrasts(con_c).name = '100 reward > 0 reward';
contrasts(con_c).vector = [0 0 0 0 -1 1 -1 1 0];
con_c = con_c + 1;

% contrasts(con_c).name = 'noChoice reward > Choice reward';
% contrasts(con_c).vector = [0 0 0 0 -1 -1 1 1 0];
% con_c = con_c + 1;

contrasts(con_c).name = 'Choice increasing reward > NoChoice decreasing reward';
contrasts(con_c).vector = [0 0 0 0 -1 1 1 -1 0];
con_c = con_c + 1;

% contrasts(con_c).name = 'Choice decreasing reward > NoChoice increasing reward';
% contrasts(con_c).vector = [0 0 0 0 1 -1 -1 1 0];
% con_c = con_c + 1;

%% Save a .mat file for SPM first level analysis
if(isempty(output_dir))
    Presentation_matfile = fullfile(this_path, sprintf('%s_delgadoChoice_regressors.mat', studyID));
else
    Presentation_matfile = fullfile(output_dir, sprintf('%s_delgadoChoice_regressors.mat', studyID));
end
save(Presentation_matfile, 'names', 'onsets', 'durations', 'TR', 'contrasts', 'units');

