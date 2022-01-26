% M4: drug x time effect, within subject ANOVA
% Placebo:RS0-RS1 vs Neurexan:RS0-RS1 for FCMaps and FCD maps

clear
clc
% close all

load('sbjs_M2_tara_RS0RS1_030.mat')
rootDIR= 'E:\Tara_NeurimRS\';

datapath = fullfile(rootDIR, 'FC_Map'); % FC maps were copied here from CONN folders;                                          % FCD_Map; In case of FCD map were copied from DPabi folder
rootOutput = fullfile(rootDIR, 'FCAnalysis','RM_ANOVA'); % or FCDAnalysis

fRS = 'ResultsS';
model = 'RS0RS1';

em = fullfile(rootDIR, 'BrainMask.nii');
%em = '';

log = 'batch_2ndLevel_M4_WithinSbjANOVA_AmygdalaFC.log';
covar = 1;

load('/media/tara/Tara4T/Neurim/CONN_YANParameter3mm_ReorientData/FCAnalysis/AmygdalaListCONN.mat');

fprefix = 's3mm_ROI_Amygdala_CM_L_MNI';

job_cnt = 0;
matlabbatch = {};

%% model specification
job_cnt = job_cnt + 1;
mdir = fullfile(rootOutput,model,fprefix);
if ~exist(mdir,'dir')
    mkdir(mdir);
end
matlabbatch{job_cnt}.spm.stats.factorial_design.dir = {mdir};
% define factors
matlabbatch{job_cnt}.spm.stats.factorial_design.des.fblock.fac(1).name = 'subject';
matlabbatch{job_cnt}.spm.stats.factorial_design.des.fblock.fac(1).dept = 0;
matlabbatch{job_cnt}.spm.stats.factorial_design.des.fblock.fac(1).variance = 0;
matlabbatch{job_cnt}.spm.stats.factorial_design.des.fblock.fac(1).gmsca = 0;
matlabbatch{job_cnt}.spm.stats.factorial_design.des.fblock.fac(1).ancova = 0;
matlabbatch{job_cnt}.spm.stats.factorial_design.des.fblock.fac(2).name = 'drug';
matlabbatch{job_cnt}.spm.stats.factorial_design.des.fblock.fac(2).dept = 1;
matlabbatch{job_cnt}.spm.stats.factorial_design.des.fblock.fac(2).variance = 0;
matlabbatch{job_cnt}.spm.stats.factorial_design.des.fblock.fac(2).gmsca = 0;
matlabbatch{job_cnt}.spm.stats.factorial_design.des.fblock.fac(2).ancova = 0;
matlabbatch{job_cnt}.spm.stats.factorial_design.des.fblock.fac(3).name = 'time';
matlabbatch{job_cnt}.spm.stats.factorial_design.des.fblock.fac(3).dept = 1;
matlabbatch{job_cnt}.spm.stats.factorial_design.des.fblock.fac(3).variance = 0;
matlabbatch{job_cnt}.spm.stats.factorial_design.des.fblock.fac(3).gmsca = 0;
matlabbatch{job_cnt}.spm.stats.factorial_design.des.fblock.fac(3).ancova = 0;

% load subject & cov
age = [];
seq = [];
s_cnt = 0;

for s = 1:length(M4_sbjs)
    age = [age;repmat(M4_sbjs{s}.age,4,1)];
    seq = [seq;repmat(M4_sbjs{s}.seq,4,1)];
    
    nii_rs0_pla = strcat(fullfile(datapath,sprintf('%s_%s.nii',fprefix,M4_sbjs{s}.rs0_pla)));
    nii_rs1_pla = strcat(fullfile(datapath,sprintf('%s_%s.nii',fprefix,M4_sbjs{s}.rs1_pla)));
    nii_rs0_neu = strcat(fullfile(datapath,sprintf('%s_%s.nii',fprefix,M4_sbjs{s}.rs0_neu)));
    nii_rs1_neu = strcat(fullfile(datapath,sprintf('%s_%s.nii',fprefix,M4_sbjs{s}.rs1_neu)));
    
    matlabbatch{job_cnt}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(s).scans = cellstr([nii_rs0_pla;nii_rs1_pla;nii_rs0_neu;nii_rs1_neu]);
    matlabbatch{job_cnt}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(s).conds = [1 1
        1 2
        2 1
        2 2];
end

matlabbatch{job_cnt}.spm.stats.factorial_design.des.fblock.maininters{1}.fmain.fnum = 1;
matlabbatch{job_cnt}.spm.stats.factorial_design.des.fblock.maininters{2}.inter.fnums = [2
    3];
% specify covar
if covar
    cov_cnt = 0;
    cov_cnt = cov_cnt + 1;
    matlabbatch{job_cnt}.spm.stats.factorial_design.cov(cov_cnt).c = age;
    matlabbatch{job_cnt}.spm.stats.factorial_design.cov(cov_cnt).cname = 'age';
    matlabbatch{job_cnt}.spm.stats.factorial_design.cov(cov_cnt).iCFI = 1;
    matlabbatch{job_cnt}.spm.stats.factorial_design.cov(cov_cnt).iCC = 1;
    cov_cnt = cov_cnt + 1;
    matlabbatch{job_cnt}.spm.stats.factorial_design.cov(cov_cnt).c = seq;
    matlabbatch{job_cnt}.spm.stats.factorial_design.cov(cov_cnt).cname = 'sequence';
    matlabbatch{job_cnt}.spm.stats.factorial_design.cov(cov_cnt).iCFI = 1;
    matlabbatch{job_cnt}.spm.stats.factorial_design.cov(cov_cnt).iCC = 1;
    
    matlabbatch{job_cnt}.spm.stats.factorial_design.cov(cov_cnt).iCC = 1;
else
    matlabbatch{job_cnt}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
end

matlabbatch{job_cnt}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{job_cnt}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{job_cnt}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{job_cnt}.spm.stats.factorial_design.masking.em = {em};
matlabbatch{job_cnt}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{job_cnt}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{job_cnt}.spm.stats.factorial_design.globalm.glonorm = 1;

%% model estimate
job_cnt = job_cnt + 1;
matlabbatch{job_cnt}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{job_cnt-1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{job_cnt}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{job_cnt}.spm.stats.fmri_est.method.Classical = 1;

%% contrast specification
job_cnt = job_cnt + 1;
matlabbatch{job_cnt}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{job_cnt-1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
con_cnt = 0;
con_cnt = con_cnt + 1;
matlabbatch{job_cnt}.spm.stats.con.consess{con_cnt}.tcon.name = 'Main effect: Placebo > Neurexan';
matlabbatch{job_cnt}.spm.stats.con.consess{con_cnt}.tcon.weights = [1 1 -1 -1];
matlabbatch{job_cnt}.spm.stats.con.consess{con_cnt}.tcon.sessrep = 'none';
con_cnt = con_cnt + 1;
matlabbatch{job_cnt}.spm.stats.con.consess{con_cnt}.tcon.name = 'Main effect: Placebo < Neurexan';
matlabbatch{job_cnt}.spm.stats.con.consess{con_cnt}.tcon.weights = [-1 -1 1 1];
matlabbatch{job_cnt}.spm.stats.con.consess{con_cnt}.tcon.sessrep = 'none';
con_cnt = con_cnt + 1;
matlabbatch{job_cnt}.spm.stats.con.consess{con_cnt}.tcon.name = 'Main effect: RS0 > RS1';
matlabbatch{job_cnt}.spm.stats.con.consess{con_cnt}.tcon.weights = [1 -1 1 -1];
matlabbatch{job_cnt}.spm.stats.con.consess{con_cnt}.tcon.sessrep = 'none';
con_cnt = con_cnt + 1;
matlabbatch{job_cnt}.spm.stats.con.consess{con_cnt}.tcon.name = 'Main effect: RS0 < RS1';
matlabbatch{job_cnt}.spm.stats.con.consess{con_cnt}.tcon.weights = [-1 1 -1 1];
matlabbatch{job_cnt}.spm.stats.con.consess{con_cnt}.tcon.sessrep = 'none';
con_cnt = con_cnt + 1;
matlabbatch{job_cnt}.spm.stats.con.consess{con_cnt}.tcon.name = 'Drug x Time Interaction: PLA(RS0-RS1)-NEU(RS0-RS1)';
matlabbatch{job_cnt}.spm.stats.con.consess{con_cnt}.tcon.weights = [1 -1 -1 1];
matlabbatch{job_cnt}.spm.stats.con.consess{con_cnt}.tcon.sessrep = 'none';
con_cnt = con_cnt + 1;
matlabbatch{job_cnt}.spm.stats.con.consess{con_cnt}.tcon.name = 'Drug x Time Interaction: NEU(RS0-RS1)-PLA(RS0-RS1)';
matlabbatch{job_cnt}.spm.stats.con.consess{con_cnt}.tcon.weights = [-1 1 1 -1];
matlabbatch{job_cnt}.spm.stats.con.consess{con_cnt}.tcon.sessrep = 'none';

matlabbatch{job_cnt}.spm.stats.con.delete = 0;

try
    spm('defaults', 'FMRI');
    spm_jobman('initcfg');
    spm_jobman('run', matlabbatch);
catch
    
    logfid = fopen(log,'a');        fprintf('%s:\n%s:\n %s\n',model ,fprefix,err.message);
    fprintf(logfid,'%s:\n%s:\n %s\n',model, fprefix ,err.message);
    fclose(logfid);
end



