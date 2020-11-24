function prepro_spm12(subj_dir, studyID, func_series, params)

% This preprocesses functional data in spm12. It adopts a different
% approach to previous scripts, in that you tell it where the files are,
% rather than giving it a masterfile and list of people to do. Realignment
% will write a mean image only.
%
% - subj_dir    : full path to the subject's main directory/visitdate
% - func_series : either 'ValueChoice' or 'SRT' - resting state is
%                 processed differently
% - params      : .realign                    
%                   .interp = 7 (highest)
%                 .normalise
%                   .func_res = [3 3 3]
%                   .struct_res = [1 1 1]
%                 .smooth
%                   .res = [8 8 8]
%
% LR 19/3/16

%% Locate the necessary files
struct_nii = fullfile(subj_dir, 'T1', sprintf('%s_T1_brain.nii', studyID));
func_nii = fullfile(subj_dir, func_series, sprintf('%s_%s_brain.nii', studyID, func_series));
FM1_nii = find_subfolder(fullfile(subj_dir, 'FM1'), sprintf('%s_FM1.*nii', studyID));
FM2_nii = find_subfolder(fullfile(subj_dir, 'FM2'), sprintf('%s_FM2.*nii', studyID));

%% Unpack functional data
matlabbatch{1}.spm.util.exp_frames.files = {func_nii};
matlabbatch{1}.spm.util.exp_frames.frames = Inf;

%% Calculate field map
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.phase = FM2_nii;
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.magnitude = FM1_nii;
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.et = [4.92 7.38]; % Siemens PRISMA/SKYRA gre_field_mapping sequence
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.maskbrain = 1;
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.blipdir = -1; % Siemens PRISMA/SKYRA gre_field_mapping sequence j-
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.tert = 2.54; % Siemens PRISMA/SKYRA gre_field_mapping sequence
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.epifm = 1;
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.ajm = 0;
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.method = 'Mark3D';
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.fwhm = 10;
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.pad = 0;
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.ws = 1;
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.template = {'/Users/lianaromaniuk/Science/spm12/toolbox/FieldMap/T1.nii'};
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.fwhm = 5;
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.nerode = 2;
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.ndilate = 4;
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.thresh = 0.5;
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.reg = 0.02;
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.session.epi(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.matchvdm = 0;
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.sessname = 'session';
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.writeunwarped = 0;
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.anat = '';
matlabbatch{2}.spm.tools.fieldmap.calculatevdm.subj.matchanat = 0;

%% Realign
matlabbatch{3}.spm.spatial.realignunwarp.data.scans(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{3}.spm.spatial.realignunwarp.data.pmscan(1) = cfg_dep('Calculate VDM: Voxel displacement map (Subj 1, Session 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','vdmfile', '{}',{1}));
matlabbatch{3}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
matlabbatch{3}.spm.spatial.realignunwarp.eoptions.sep = 4;
matlabbatch{3}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
matlabbatch{3}.spm.spatial.realignunwarp.eoptions.rtm = 0;
matlabbatch{3}.spm.spatial.realignunwarp.eoptions.einterp = params.realign.interp;
matlabbatch{3}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
matlabbatch{3}.spm.spatial.realignunwarp.eoptions.weight = '';
matlabbatch{3}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
matlabbatch{3}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
matlabbatch{3}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
matlabbatch{3}.spm.spatial.realignunwarp.uweoptions.jm = 0;
matlabbatch{3}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
matlabbatch{3}.spm.spatial.realignunwarp.uweoptions.sot = [];
matlabbatch{3}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
matlabbatch{3}.spm.spatial.realignunwarp.uweoptions.rem = 1;
matlabbatch{3}.spm.spatial.realignunwarp.uweoptions.noi = 5;
matlabbatch{3}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
matlabbatch{3}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
matlabbatch{3}.spm.spatial.realignunwarp.uwroptions.rinterp = params.realign.interp;
matlabbatch{3}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
matlabbatch{3}.spm.spatial.realignunwarp.uwroptions.mask = 1;
matlabbatch{3}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';

%% Coregistration
matlabbatch{4}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
matlabbatch{4}.spm.spatial.coreg.estimate.source = {struct_nii};
matlabbatch{4}.spm.spatial.coreg.estimate.other = {''};
matlabbatch{4}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{4}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{4}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{4}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

%% Segmentation
matlabbatch{5}.spm.spatial.preproc.channel.vols = {struct_nii};
matlabbatch{5}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{5}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{5}.spm.spatial.preproc.channel.write = [1 1];
matlabbatch{5}.spm.spatial.preproc.tissue(1).tpm = {'/Users/lianaromaniuk/Science/spm12/tpm/TPM.nii,1'};
matlabbatch{5}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{5}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{5}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{5}.spm.spatial.preproc.tissue(2).tpm = {'/Users/lianaromaniuk/Science/spm12/tpm/TPM.nii,2'};
matlabbatch{5}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{5}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{5}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{5}.spm.spatial.preproc.tissue(3).tpm = {'/Users/lianaromaniuk/Science/spm12/tpm/TPM.nii,3'};
matlabbatch{5}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{5}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{5}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{5}.spm.spatial.preproc.tissue(4).tpm = {'/Users/lianaromaniuk/Science/spm12/tpm/TPM.nii,4'};
matlabbatch{5}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{5}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{5}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{5}.spm.spatial.preproc.tissue(5).tpm = {'/Users/lianaromaniuk/Science/spm12/tpm/TPM.nii,5'};
matlabbatch{5}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{5}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{5}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{5}.spm.spatial.preproc.tissue(6).tpm = {'/Users/lianaromaniuk/Science/spm12/tpm/TPM.nii,6'};
matlabbatch{5}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{5}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{5}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{5}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{5}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{5}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{5}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{5}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{5}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{5}.spm.spatial.preproc.warp.write = [0 1];
matlabbatch{5}.spm.spatial.preproc.warp.vox = NaN;
matlabbatch{5}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                              NaN NaN NaN];

%% Normalisation - fMRI
matlabbatch{6}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
matlabbatch{6}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Realign & Unwarp: Unwarped Images (Sess 1)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','uwrfiles'));
matlabbatch{6}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
matlabbatch{6}.spm.spatial.normalise.write.woptions.vox = params.normalise.func_res;
matlabbatch{6}.spm.spatial.normalise.write.woptions.interp = 7;
matlabbatch{6}.spm.spatial.normalise.write.woptions.prefix = 'w';

%% Normalisation - structural
matlabbatch{7}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
matlabbatch{7}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{7}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
matlabbatch{7}.spm.spatial.normalise.write.woptions.vox = params.normalise.struct_res;
matlabbatch{7}.spm.spatial.normalise.write.woptions.interp = 7;
matlabbatch{7}.spm.spatial.normalise.write.woptions.prefix = 'w';

%% Smoothing
matlabbatch{8}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{8}.spm.spatial.smooth.fwhm = params.smooth.res;
matlabbatch{8}.spm.spatial.smooth.dtype = 0;
matlabbatch{8}.spm.spatial.smooth.im = 0;
matlabbatch{8}.spm.spatial.smooth.prefix = 's';

%% Run
spm_jobman('run',matlabbatch);