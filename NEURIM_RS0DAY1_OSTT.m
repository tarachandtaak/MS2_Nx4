
clear
clc
% close all
load('sbjs_M2_tara_RS0RS1_030.mat')
rootDIR= 'E:\Tara_NeurimRS\';

datapath = fullfile(rootDIR, 'FC_Map'); % FC maps were copied here from CONN folders; 
                                         % FCD_Map; In case of FCD map were copied from DPabi folder
rootOutput = fullfile(rootDIR, 'FCAnalysis','OSTT'); % or FCDAnalysis

em = fullfile(rootDIR, 'BrainMask.nii');
%em = '';

log = 'batch_2ndLevel_M2_WithinSbjANOVA_AmygdalaFC.log';


fprefix = 's3mm_ROI_Amygdala_CM_L_MNI';

job_cnt = 0;
matlabbatch = {};

%% model specification
job_cnt = job_cnt + 1;
mdir = fullfile(rootOutput,'Day1', fprefix);
if ~exist(mdir,'dir')
    mkdir(mdir);
end

%% select placebo subject only

for s = 1:length(M4_sbjs)
    
    InputSubPath{s,1} = strrep(strcat(fullfile(datapath,sprintf('%s_%s.nii',fprefix,M4_sbjs{s}.rs0_pla))), 'Day2', 'Day1'); % only day data
    
end

%%
matlabbatch{1}.spm.stats.factorial_design.dir = {mdir};
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = InputSubPath;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {em};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'positive';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
%     matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'negative';
%     matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = -1;
%     matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;
matlabbatch{4}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{4}.spm.stats.results.conspec.titlestr = '';
matlabbatch{4}.spm.stats.results.conspec.contrasts = Inf;
matlabbatch{4}.spm.stats.results.conspec.threshdesc = 'none';
matlabbatch{4}.spm.stats.results.conspec.thresh = 0.001;
matlabbatch{4}.spm.stats.results.conspec.extent = 0;
matlabbatch{4}.spm.stats.results.conspec.conjunction = 1;
matlabbatch{4}.spm.stats.results.conspec.mask.none = 1;
matlabbatch{4}.spm.stats.results.units = 1;
matlabbatch{4}.spm.stats.results.export{1}.ps = true;

try
    spm('defaults', 'FMRI');
    spm_jobman('initcfg');
    spm_jobman('run', matlabbatch);
catch
    
    logfid = fopen(log,'a');        fprintf('%s:\n %s\n',fprefix,err.message);
    fprintf(logfid,'%s:\n %s\n',fprefix ,err.message);
    fclose(logfid);
end
