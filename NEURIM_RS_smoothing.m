


clear 

SubInfo= dir('/*zROI*.nii'); 

SubPath= cellstr(strcat(char(SubInfo.folder), filesep, char(SubInfo.name))); 

matlabbatch{1}.spm.spatial.smooth.data = SubPath;
matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';

spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

