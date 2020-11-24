function recon_spm12(raw_dir, recon_dir, studyID)

% Takes an ISSF subject's raw data, reconstructs it into the desired
% destination, and skull-strips where requred
% - raw_dir     : full path to where the raw .dcm files live
%                 participant, likely 
%                 '/Volumes/cmvm/scs/groups/CRICIA/E192160_AdDrep_RO'
% - recon_dir   : full path to where the reconstructed data will live,
%                 likely
%                 '/Volumes/cmvm/scs/groups/hwhalley-adol-imaging/MRI_scans'
% - studyID     : This participant's identifier, eg 'T001'
%
% LR 121120

%% Set of fsl for bet
mypwd = pwd;
setenv( 'FSLDIR', '/usr/local/fsl');
fsldir = getenv('FSLDIR');
fsldirmpath = sprintf('%s/etc/matlab',fsldir);
path(path, fsldirmpath);
clear fsldir fsldirmpath;

%% Locate this participant's raw data
this_raw_subj_dir = find_subfolder(raw_dir, studyID);
this_raw_dir = find_subfolder(this_raw_subj_dir{1}, '2');
last_slash = max(find(this_raw_dir{1} == '/'));
this_scandate = this_raw_dir{1}(last_slash + 1:last_slash + 8);

sequences(1).orig = find_subfolder(this_raw_dir{1}, '.*_t1.*'); % Finds the raw t1 directory
sequences(1).dest = 'T1'; % Names the destination folder where data will be reconstructed
sequences(1).strip = '-R -f 0.5 -g 0'; % command options for bet for skull stripping

these_fieldmaps = find_subfolder(this_raw_dir{1}, '.*mapping'); % Field map folders have similar names, tell them apart by their order
sequences(2).orig = these_fieldmaps(1);
sequences(2).dest = 'FM1'; % Field map magnitude
sequences(2).strip = []; % No bet brain stripping for field maps
sequences(3).orig = these_fieldmaps(2);
sequences(3).dest = 'FM2'; % Field map phase
sequences(3).strip = [];

these_rest = find_subfolder(this_raw_dir{1}, '.*_rest'); % Rest folders also similar names, order tells you what they are
sequences(4).orig = these_rest(1);
sequences(4).dest = 'RestPure';
sequences(4).strip = '-F'; % Different bet brain strip command options for fMRI
sequences(5).orig = these_rest(1);
sequences(5).dest = 'RestIrrit';
sequences(5).strip = '-F';

sequences(6).orig = find_subfolder(this_raw_dir{1}, '.*ValueChoice');
sequences(6).dest = 'ValueChoice';
sequences(6).strip = '-F';

sequences(7).orig = find_subfolder(this_raw_dir{1}, '.*_SRT');
sequences(7).dest = 'SRT';
sequences(7).strip = '-F';

%% Create the new destination directories
s = unix(sprintf('mkdir %s/%s', recon_dir, studyID));
s = unix(sprintf('mkdir %s/%s/%s', recon_dir, studyID, this_scandate));

%% Reconstruct the dicoms into niftis using dcm2niix
for s = 1:length(sequences)
    % Check if it has already been reconstructed
    if(isempty(find_subfolder(fullfile(recon_dir, studyID, this_scandate, sequences(s).dest), '.*nii')))
        x = unix(sprintf('mkdir %s/%s/%s/%s', recon_dir, studyID, this_scandate, sequences(s).dest));
        x = unix(sprintf('./dcm2niix -f %%i_%s -o %s/%s/%s/%s/ %s/', sequences(s).dest, recon_dir, studyID, this_scandate, sequences(s).dest, sequences(s).orig{1}));
    else
        display(sprintf('%s %s already reconned', studyID, sequences(s).dest));
    end
end %s 
% Where:
% Dcm2niix is available here: https://github.com/rordenlab/dcm2niix/releases
% -f %i_T1_%s gives the nifti file a sensible filename HV3_T1_2
% -o lets you state where you want the nifti file to be saved
% ?and the final bit (2_t1_mprage_sag_p3_iso_Munich/) tells dcm2niix which folder to recon

%% Skull strip using fsl's bet
for s = 1:length(sequences)
    if(~isempty(sequences(s).strip) && isempty(find_subfolder(fullfile(recon_dir, studyID, this_scandate, sequences(s).dest), '.*brain.nii')))
        this_brain = sprintf('%s/%s/%s/%s/%s_%s', recon_dir, studyID, this_scandate, sequences(s).dest, studyID, sequences(s).dest);
        display(sprintf('Stripping %s', this_brain))
        x = call_fsl(sprintf('/usr/local/fsl/bin/bet %s.nii.gz %s_brain.nii.gz %s', this_brain, this_brain, sequences(s).strip));
        
        % bet automatically compresses nii's into .nii.gz, which spm can't
        % handle, so needs decompressing
        x = unix(sprintf('gunzip %s_brain.nii.gz', this_brain));
        x = unix(sprintf('gunzip %s_brain_mask.nii.gz', this_brain));
    elseif(isempty(sequences(s).strip)) % Only field maps don't get stripped
        % Decompress the reconned unstripped field map volume
        this_brain = sprintf('%s/%s/%s/%s/%s_%s', recon_dir, studyID, this_scandate, sequences(s).dest, studyID, sequences(s).dest);
        this_map = dir(sprintf('%s*.nii.gz', this_brain))
        x = unix(sprintf('gunzip %s/%s', this_map(1).folder, this_map(1).name));
    else
        display(sprintf('%s %s already stripped', studyID, sequences(s).dest));
    end
end % s
