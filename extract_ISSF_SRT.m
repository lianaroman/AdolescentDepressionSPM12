function [Presentation_matfile, contrasts, TR, units, varargout] = extract_ISSF_SRT(logfile, studyID, out_dir)

% [Presentation_matfile, contrasts, TR, varargout] = extract_ISSF_SRT(Presentation_logfile, studyID, out_dir)
%
% varargout is
% (1) RT cell array according to each condition
% (2) responses cell array of the numerical response for each word
% (3) words cell array of the stim words for each trial 
%
% LR 061120

%% Initialise
units = 'secs';

skip_vols = 6; % Volumes to scrap at the beginning

% if(nargout > 4)
%     calc_RT = 1;
% else
%     calc_RT = 0;
% end

[this_path, name, ext] = fileparts(logfile);
[event, type, time] = textread(logfile, '%*s %*s %s %s %d %*[^\n]', 'delimiter', '\t', 'headerlines', 5);

% Determine the experiment's true beginning - onset of the 7th pulse - and
% the TR
pulse_idx = find(strcmp(event, 'Pulse'));
exp_begin = time(pulse_idx(skip_vols + 1)) / 10000;
TR = (time(pulse_idx(2)) - time(pulse_idx(1))) / 10000;

names = {'Pos_inner_self', 'Pos_inner_other', 'Pos_outer_self', 'Pos_outer_other', 'Neg_inner_self', 'Neg_inner_other', 'Neg_outer_self', 'Neg_outer_other', 'Control', 'Nuisance'};
onsets = cell(length(names),1);
durations = onsets;
%pmod = struct('name', {'Rating'}, 'param', {}, 'poly', {1});
contrasts = [];
nui = 10;
RT = cell(1,length(names) - 1);
responses = cell(1,length(names) - 2);;
words = responses;

%% Extract experimental event onsets
condition(1).name = 'Control';
condition(1).stim_ons = find(strcmp('control_stim', type));
condition(1).Q_ons = find(strcmp('control_Q', type));
condition(1).cond_num = 9;

condition(2).name = 'Pos_inner';
condition(2).stim_ons = find(strncmp('pos_inner_stim', type, 14));
condition(2).selfQ_ons = find(strncmp('pos_inner_selfQ', type, 15));
condition(2).otherQ_ons = find(strncmp('pos_inner_otherQ', type, 16));
condition(2).cond_num = [1 2];

condition(3).name = 'Pos_outer';
condition(3).stim_ons = find(strncmp('pos_outer_stim', type, 14));
condition(3).selfQ_ons = find(strncmp('pos_outer_selfQ', type, 15));
condition(3).otherQ_ons = find(strncmp('pos_outer_otherQ', type, 16));
condition(3).cond_num = [3 4];

condition(4).name = 'Neg_inner';
condition(4).stim_ons = find(strncmp('neg_inner_stim', type, 14));
condition(4).selfQ_ons = find(strncmp('neg_inner_selfQ', type, 15));
condition(4).otherQ_ons = find(strncmp('neg_inner_otherQ', type, 16));
condition(4).cond_num = [5 6];

condition(5).name = 'Neg_outer';
condition(5).stim_ons = find(strncmp('neg_outer_stim', type, 14));
condition(5).selfQ_ons = find(strncmp('neg_outer_selfQ', type, 15));
condition(5).otherQ_ons = find(strncmp('neg_outer_otherQ', type, 16));
condition(5).cond_num = [7 8];

%all_stims = union(control_stim, union(pos_inner_stim, union(pos_outer_stim, union(neg_inner_stim, neg_outer_stim))));

response_ons = find(strcmp(event, 'Response'));
ISI = find(strcmp('ISI', type));

%% Evaluate trials
for c = 1:length(condition)
    for p = condition(c).cond_num
        pmod(p).name = {'Rating'};
        pmod(p).param = cell(1);
        pmod(p).poly = {1};
    end % p
    
    selfTrial_inc = 1;
    otherTrial_inc = 1;
    
    for t = 1:length(condition(c).stim_ons)
        display(sprintf('cond %d trial %d\n', c, t));
        for k = 1:100
            if(strcmp(type{condition(c).stim_ons(t) + k}, 'ISI'))
                this_ISI = condition(c).stim_ons(t) + k;
                break
            end
        end % k
    
        % Check if this is going to be a nuisance trial - did they provide
        % a response?
        if(strcmp(condition(c).name, 'Control'))
            % Control trial, only one question
            display('control\n')            
            
            if(isempty(intersect(find(response_ons > condition(c).stim_ons(t)), find(response_ons < this_ISI))))
                % No response for this trial
                onsets{nui} = [onsets{nui} (time(condition(c).Q_ons(t)) / 10000) - exp_begin];
                durations{nui} = [durations{nui} 0];                
            else
                onsets{condition(c).cond_num} = [onsets{condition(c).cond_num} (time(condition(c).Q_ons(t)) / 10000) - exp_begin];
                durations{condition(c).cond_num} = [durations{condition(c).cond_num} 0];
                RT{condition(c).cond_num} = [RT{condition(c).cond_num} (table(time(response_ons(intersect(find(response_ons > condition(c).Q_ons(t)), find(response_ons < this_ISI))))).Var1(1) - time(condition(c).Q_ons(t))) / 10000];
            end
                
        else
            % Experimental trial, 2 questions            
            % Self Q
            display('self')
            if(isempty(intersect(find(response_ons > condition(c).selfQ_ons(t)), find(response_ons < condition(c).otherQ_ons(t)))))
                % No response for this trial
                onsets{nui} = [onsets{nui} (time(condition(c).selfQ_ons(t)) / 10000) - exp_begin];
                durations{nui} = [durations{nui} 0];
            else
                onsets{condition(c).cond_num(1)} = [onsets{condition(c).cond_num(1)} (time(condition(c).selfQ_ons(t)) / 10000) - exp_begin];
                durations{condition(c).cond_num(1)} = [durations{condition(c).cond_num(1)} 0];                
                this_response_idx = table(response_ons(intersect(find(response_ons > condition(c).selfQ_ons(t)), find(response_ons < condition(c).otherQ_ons(t))))).Var1(1);
                RT{condition(c).cond_num(1)} = [RT{condition(c).cond_num(1)} (time(this_response_idx) - time(condition(c).selfQ_ons(t))) / 10000];
                pmod(condition(c).cond_num(1)).param{1} = [pmod(condition(c).cond_num(1)).param{1} str2num(type{this_response_idx})];
                responses{condition(c).cond_num(1)} = [responses{condition(c).cond_num(1)} str2num(type{this_response_idx})];
                words{selfTrial_inc, condition(c).cond_num(1)} = type{condition(c).stim_ons(t)}(16:end);
                selfTrial_inc = selfTrial_inc + 1;
            end
            
            % Other Q
            display('other');
            if(isempty(intersect(find(response_ons > condition(c).otherQ_ons(t)), find(response_ons < this_ISI))))
                % No response for this trial
                onsets{nui} = [onsets{nui} (time(condition(c).otherQ_ons(t)) / 10000) - exp_begin];
                durations{nui} = [durations{nui} 0];
            else
                onsets{condition(c).cond_num(2)} = [onsets{condition(c).cond_num(2)} (time(condition(c).otherQ_ons(t)) / 10000) - exp_begin];
                durations{condition(c).cond_num(2)} = [durations{condition(c).cond_num(2)} 0];
                this_response_idx = table(response_ons(intersect(find(response_ons > condition(c).otherQ_ons(t)), find(response_ons < this_ISI)))).Var1(1);
                RT{condition(c).cond_num(2)} = [RT{condition(c).cond_num(2)} (time(this_response_idx) - time(condition(c).otherQ_ons(t))) / 10000];
                pmod(condition(c).cond_num(2)).param{1} = [pmod(condition(c).cond_num(2)).param{1} str2num(type{this_response_idx})];
                responses{condition(c).cond_num(2)} = [responses{condition(c).cond_num(2)} str2num(type{this_response_idx})];
                words{otherTrial_inc, condition(c).cond_num(2)} = type{condition(c).stim_ons(t)}(16:end);
                otherTrial_inc = otherTrial_inc + 1;
            end
        end
    end % t
    
    % Add the stim onsets and responses themselves as nuisances
    onsets{nui} = [onsets{nui} (time(condition(c).stim_ons) / 10000)' - exp_begin]; 
    durations{nui} = [durations{nui} zeros(1, length(condition(c).stim_ons))];
    
    % Check if the pmod column has any variance (eg has the participant
    % selected the same response for every word), if so randomly select 1
    % word and change the value by 1
    if(~strcmp(condition(c).name, 'Control'))
        for p = 1:2
            if(max(pmod(condition(c).cond_num(p)).param{1}) == min(pmod(condition(c).cond_num(p)).param{1}))
                if(max(pmod(condition(c).cond_num(p)).param{1}) < 3)
                    pmod(condition(c).cond_num(p)).param{1}(1 + round(rand * (length(pmod(condition(5).cond_num(2)).param{1}) - 1))) = max(pmod(condition(c).cond_num(p)).param{1}) + 1;
                else
                    pmod(condition(c).cond_num(p)).param{1}(1 + round(rand * (length(pmod(condition(5).cond_num(2)).param{1}) - 1))) = max(pmod(condition(c).cond_num(p)).param{1}) - 1;
                end
            end
        end % p
    end
end % c

onsets{nui} = [onsets{nui} (time(response_ons) / 10000)' - exp_begin]; 
durations{nui} = [durations{nui} zeros(1, length(response_ons))];

%% Defining contrasts
con_c = 1;
base_contrasts(con_c).name = 'Pos inner self > rest';
base_contrasts(con_c).vector = [1];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Pos inner other > rest';
base_contrasts(con_c).vector = [0 1];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Pos outer self > rest';
base_contrasts(con_c).vector = [0 0 1];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Pos outer other > rest';
base_contrasts(con_c).vector = [0 0 0 1];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Neg inner self > rest';
base_contrasts(con_c).vector = [0 0 0 0 1];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Neg inner other > rest';
base_contrasts(con_c).vector = [0 0 0 0 0 1];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Neg outer self > rest';
base_contrasts(con_c).vector = [0 0 0 0 0 0 1];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Neg outer other > rest';
base_contrasts(con_c).vector = [0 0 0 0 0 0 0 1];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Pos inner self > control';
base_contrasts(con_c).vector = [1 0 0 0 0 0 0 0 -1];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Pos inner other > control';
base_contrasts(con_c).vector = [0 1 0 0 0 0 0 0 -1];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Pos outer self > control';
base_contrasts(con_c).vector = [0 0 1 0 0 0 0 0 -1];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Pos outer other > control';
base_contrasts(con_c).vector = [0 0 0 1 0 0 0 0 -1];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Neg inner self > control';
base_contrasts(con_c).vector = [0 0 0 0 1 0 0 0 -1];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Neg inner other > control';
base_contrasts(con_c).vector = [0 0 0 0 0 1 0 0 -1];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Neg outer self > control';
base_contrasts(con_c).vector = [0 0 0 0 0 0 1 0 -1];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Neg outer other > control';
base_contrasts(con_c).vector = [0 0 0 0 0 0 0 1 -1];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Pos > rest';
base_contrasts(con_c).vector = [1 1 1 1 0 0 0 0 0];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Neg > rest';
base_contrasts(con_c).vector = [0 0 0 0 1 1 1 1 0];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Pos > control';
base_contrasts(con_c).vector = [1 1 1 1 0 0 0 0 -4];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Neg > control';
base_contrasts(con_c).vector = [0 0 0 0 1 1 1 1 -4];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Pos > neg';
base_contrasts(con_c).vector = [1 1 1 1 -1 -1 -1 -1 0];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Inner > rest';
base_contrasts(con_c).vector = [1 1 0 0 1 1 0 0 0];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Outer > rest';
base_contrasts(con_c).vector = [0 0 1 1 0 0 1 1 0];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Inner > control';
base_contrasts(con_c).vector = [1 1 0 0 1 1 0 0 -4];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Outer > control';
base_contrasts(con_c).vector = [0 0 1 1 0 0 1 1 -4];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Inner > outer';
base_contrasts(con_c).vector = [1 1 -1 -1 1 1 -1 -1 0];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Self > rest';
base_contrasts(con_c).vector = [1 0 1 0 1 0 1 0 0];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Other > rest';
base_contrasts(con_c).vector = [0 1 0 1 0 1 0 1 0];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Self > control';
base_contrasts(con_c).vector = [1 0 1 0 1 0 1 0 -4];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Other > control';
base_contrasts(con_c).vector = [0 1 0 1 0 1 0 1 -4];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Self > other';
base_contrasts(con_c).vector = [1 -1 1 -1 1 -1 1 -1 0];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Pos inner > pos outer';
base_contrasts(con_c).vector = [1 1 -1 -1 0 0 0 0 0];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Neg inner > neg outer';
base_contrasts(con_c).vector = [0 0 0 0 1 1 -1 -1 0];
con_c = con_c + 1;

base_contrasts(con_c).name = '(PosInn > PosOut) > (NegInn > NegOut)';
base_contrasts(con_c).vector = [1 1 -1 -1 -1 -1 1 1 0];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Pos self > pos other';
base_contrasts(con_c).vector = [1 -1 1 -1 0 0 0 0 0];
con_c = con_c + 1;

base_contrasts(con_c).name = 'Neg self > Neg other';
base_contrasts(con_c).vector = [0 0 0 0 1 -1 1 -1 0];
con_c = con_c + 1;

base_contrasts(con_c).name = '(PosSelf > PosOther) > (NegSelf > NegOther)';
base_contrasts(con_c).vector = [1 -1 1 -1 -1 1 -1 1 0];
con_c = con_c + 1;

%% Translate these contrasts into the basic and parametric modulated columns
for c = 1:length(base_contrasts)
    these_cols = find(base_contrasts(c).vector);
    
    contrasts((c*2)-1).name = sprintf('main_%s', base_contrasts(c).name);
    contrasts((c*2)-1).vector = zeros(1,length(base_contrasts(c).vector) * 2);
    contrasts((c*2)-1).vector((these_cols*2)-1) = base_contrasts(c).vector(these_cols);
    
    contrasts(c*2).name = sprintf('pmod_%s', base_contrasts(c).name);
    contrasts(c*2).vector = zeros(1,length(base_contrasts(c).vector) * 2);
    contrasts(c*2).vector(these_cols*2) = base_contrasts(c).vector(these_cols);    
end % c

num_cons = length(contrasts)

for c = 1:length(contrasts)
    contrasts(num_cons + c).name = sprintf('Inv_%s', contrasts(c).name);
    contrasts(num_cons + c).vector = -1 .* contrasts(c).vector;
end % c

%% Save the output
if(isempty(out_dir))
    Presentation_matfile = fullfile(this_path, sprintf('%s_ISSF_SRT_regressors.mat', studyID));
else
    Presentation_matfile = fullfile(out_dir, sprintf('%s_ISSF_SRT_regressors.mat', studyID));
end

save(Presentation_matfile, 'names', 'onsets', 'durations', 'pmod', 'TR', 'contrasts', 'units');

varargout{1} = RT;     
varargout{2} = responses;
varargout{3} = words;