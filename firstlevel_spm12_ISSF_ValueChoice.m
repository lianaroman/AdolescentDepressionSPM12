function firstlevel_spm12_ISSF_ValueChoice(subj_func_dir, subj_log_dir)
%studyID, func_nii, presentation_log, first_dir, rp_file, data_frame)

%% Locate the necessary data
slashes          = find(subj_func_dir == '/');
studyID          = subj_func_dir(slashes(length(slashes) - 2) + 1:slashes(length(slashes) - 1) - 1);
func_nii         = fullfile(subj_func_dir, sprintf('swu%s_ValueChoice_brain.nii', studyID)); % The fMRI .nii preprocessed data
presentation_log = find_subfolder(subj_log_dir, '^[A-Z].*ValueChoiceTask3a'); % The Presentation task logfile
first_dir        = fullfile(subj_func_dir, 'ValueChoice_firstlevel'); % first level analysis location
x                = unix(sprintf('mkdir %s', first_dir));
rp_file          = find_subfolder(subj_func_dir, 'rp.*_brain.txt'); % realignment parameters
data_frame       = [7:483]; % Volumes to include

% Load the regressor matfile
[a b c] = fileparts(presentation_log{1});
[Presentation_matfile, contrasts, TR, units] = extract_delgado_choice_ISSF(presentation_log{1}, studyID, a);

% Where applicable, modify the Presentation_matfile nuisance column to
% include ArtRepair interpolated volumes
if(strfind(func_nii, 'swv'))
    % Read the art_repaired.txt file
    artrepair = fullfile(a, 'art_repaired.txt')
    nuic_vols = textread(artrepair);
    
    % Change Presentation_matfile
    load(Presentation_matfile);
    temp = (nuic_vols - 1) * TR;
    onsets{9} = [onsets{9} temp];
    onsets{9} = sort(onsets{9})
    durations{9} = zeros(1,length(onsets{9}));
    
    % Save the new matfile
    save(Presentation_matfile, 'names', 'onsets', 'durations', 'TR', 'contrasts', 'units');
end

mypwd = pwd;

% Trim the rp file if appropriate
% temp = dlmread(rp_file);
% if(size(temp, 1) > length(data_frame))
%     temp(1:size(temp,1) - length(data_frame), :) = [];
%     [this_path, this_name, this_ext] = fileparts(rp_file);
%     rp_file = fullfile(a, sprintf('%s_trim.txt', this_name))
%     dlmwrite(rp_file, temp);
% end

temp = dlmread(rp_file{1});
if(size(temp, 1) > length(data_frame))
    temp(1:data_frame(1)-1, :) = [];
    [this_path, this_name, this_ext] = fileparts(rp_file{1});
    rp_file = {fullfile(a, sprintf('%s_trim.txt', this_name))}
    dlmwrite(rp_file{1}, temp);
end

%% Set up the matlabbatch
matlabbatch{1}.spm.util.exp_frames.files = {func_nii};
matlabbatch{1}.spm.util.exp_frames.frames = [data_frame];

matlabbatch{2}.spm.stats.fmri_spec.dir = {first_dir};
matlabbatch{2}.spm.stats.fmri_spec.timing.units = units;
matlabbatch{2}.spm.stats.fmri_spec.timing.RT = TR;
matlabbatch{2}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{2}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
matlabbatch{2}.spm.stats.fmri_spec.sess.scans(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{2}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
matlabbatch{2}.spm.stats.fmri_spec.sess.multi = {Presentation_matfile};
matlabbatch{2}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{2}.spm.stats.fmri_spec.sess.multi_reg = rp_file;
matlabbatch{2}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{2}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{2}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{2}.spm.stats.fmri_spec.volt = 1;
matlabbatch{2}.spm.stats.fmri_spec.global = 'None';
matlabbatch{2}.spm.stats.fmri_spec.mthresh = 0.3;
matlabbatch{2}.spm.stats.fmri_spec.mask = {''};
matlabbatch{2}.spm.stats.fmri_spec.cvi = 'AR(1)';

matlabbatch{3}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{3}.spm.stats.fmri_est.method.Classical = 1;

matlabbatch{4}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{4}.spm.stats.con.delete = 0;

for c = 1:length(contrasts)
    matlabbatch{4}.spm.stats.con.consess{c}.tcon.name = contrasts(c).name;
    matlabbatch{4}.spm.stats.con.consess{c}.tcon.weights = contrasts(c).vector;
    matlabbatch{4}.spm.stats.con.consess{c}.tcon.sessrep = 'none';
end % c

% Run
spm_jobman('run',matlabbatch);
