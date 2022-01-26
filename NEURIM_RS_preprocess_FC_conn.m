%% This code implements preprocessing for NEURIM rsfMRI
% I use this code to preprocess data from NEURIM slow data

clear
clc
% close all

load('E:\Tara_NeurimRS\Subject_Codes.mat'); % load subject code
rootDir= 'E:\Tara_NeurimRS\Data';

for i_day= 1:2
    
    FUNCTIONAL_FILE_INFO_RS0 = dir(fullfile(rootDir, 'RS0', sprintf('\\day%d\\*\\fun\\rest.nii', i_day)));
    FUNCTIONAL_FILE_RS0 = cellstr(strcat(char(FUNCTIONAL_FILE_INFO_RS0.folder), filesep, char(FUNCTIONAL_FILE_INFO_RS0.name)));
    
    FUNCTIONAL_FILE_INFO_RS1 = dir(fullfile(rootDir, 'RS1', sprintf('\\day%d\\*\\fun\\rest.nii', i_day)));
    FUNCTIONAL_FILE_RS1 = cellstr(strcat(char(FUNCTIONAL_FILE_INFO_RS1.folder), filesep, char(FUNCTIONAL_FILE_INFO_RS1.name)));
    
    FUNCTIONAL_FILE_INFO_RS2 = dir(fullfile(rootDir, 'RS2', sprintf('\\day%d\\*\\fun\\rest.nii', i_day)));
    FUNCTIONAL_FILE_RS2 = cellstr(strcat(char(FUNCTIONAL_FILE_INFO_RS2.folder), filesep, char(FUNCTIONAL_FILE_INFO_RS2.name)));
    
    STRUCTURAL_FILE_INFO = dir(fullfile(rootDir, 'RS0', sprintf('\\day%d\\*\\anat\\mprage.nii', i_day)));
    STRUCTURAL_FILE_all = cellstr(strcat(char(STRUCTURAL_FILE_INFO.folder), filesep, char(STRUCTURAL_FILE_INFO.name)));
    
    
    for subject_index = 1:length(STRUCTURAL_FILE_all)
        
        
        NSUBJECTS = 1;
        
        %% FIND functional/structural files
        FUNCTIONAL_FILE= [FUNCTIONAL_FILE_RS0(subject_index),FUNCTIONAL_FILE_RS1(subject_index),FUNCTIONAL_FILE_RS2(subject_index)];% ; FUNCTIONAL_FILE_day2(subject_index)];
        
        STRUCTURAL_FILE= STRUCTURAL_FILE_all(subject_index);
        split_STRUCTURAL_FILE= split(STRUCTURAL_FILE, filesep);
        folder_name = split_STRUCTURAL_FILE{end-2};
        
        %folder_name = Subject_code{subject_index};
        cwd = fullfile(rootDir,'results_connproject',sprintf('DAY%d', i_day), folder_name);
        
        
        if ~exist(cwd, 'dir')
            mkdir(cwd)
        end
        cd(cwd);
        
        
        copyfile('E:\Tara_NeurimRS\Data\TemplateConnProject\conn_NEURIM_preprocess.mat',cwd ) % copy empty conn projects
        copyfile('E:\Tara_NeurimRS\Data\TemplateConnProject\conn_NEURIM_preprocess',cwd )
        
        nsessions=3; % RS0, RS1, RS2
        FUNCTIONAL_FILE=reshape(FUNCTIONAL_FILE,[NSUBJECTS,nsessions]);
        STRUCTURAL_FILE={STRUCTURAL_FILE{1:NSUBJECTS}};
        disp([num2str(size(FUNCTIONAL_FILE,1)),' subjects']);
        disp([num2str(size(FUNCTIONAL_FILE,2)),' sessions']);
        
        TR=2; % Repetition time = 2000 miliseconds
        
        %% CONN-SPECIFIC SECTION: RUNS PREPROCESSING/SETUP/DENOISING/ANALYSIS STEPS
        %% Prepares batch structure
        batch= [];
        batch = struct;
        
        batch.filename=fullfile(cwd,'conn_NEURIM_preprocess.mat');            % New conn_*.mat experiment name
        
        %% SETUP & PREPROCESSING step (using default values for most parameters, see help conn_batch to define non-default values)
        % CONN Setup
        % CONN Setup.preprocessing
        batch.Setup.isnew=0;
        %     batch.Setup.isnew=1;
        batch.setup.acquisitiontype = 1; % continious recording
        batch.Setup.nsubjects=NSUBJECTS; % number of subjects
        batch.Setup.RT=TR;  % TR (seconds)
        batch.setup.analysis = [1 2]; % 1 for ROI to ROI and 2 for seed to voxel
        batch.setup.outputfiles = [0 1 0];
        
        % functional data
        batch.Setup.functionals=repmat({{}},[NSUBJECTS,1]);       % Point to functional volumes for each subject/session
        for nsub=1:NSUBJECTS,
            for nses=1:nsessions,
                batch.Setup.functionals{nsub}{nses}{1}=FUNCTIONAL_FILE{nsub,nses};
            end
        end %note: each subject's data is defined by three sessions and one single (4d) file per session
        batch.Setup.structurals=STRUCTURAL_FILE;                  % Point to anatomical volumes for each subject
        
        
        batch.Setup.rois.names = {'3mm_ROI_Amygdala_CM_L_MNI'};
        batch.Setup.rois.dimensions = {1,1};
        batch.Setup.rois.files{1} = 'E:\Tara_NeurimRS\AmygdalaROIs_3mm\3mm_ROI_Amygdala_CM_L_MNI.nii';
        
        
        nconditions=nsessions;
        if nconditions==1
            batch.Setup.conditions.names={'rest'};
            for ncond=1,
                for nsub=1:NSUBJECTS,
                    for nses=1:nsessions,
                        batch.Setup.conditions.onsets{ncond}{nsub}{nses}=0;
                        batch.Setup.conditions.durations{ncond}{nsub}{nses}=inf;
                    end;
                end;
            end     % rest condition (all sessions)
        else
            batch.Setup.conditions.names=[{'rest'}, arrayfun(@(n)sprintf('Session%d',n),1:nconditions,'uni',0)];
            for ncond=1,
                for nsub=1:NSUBJECTS,
                    for nses=1:nsessions,
                        batch.Setup.conditions.onsets{ncond}{nsub}{nses}=0;
                        batch.Setup.conditions.durations{ncond}{nsub}{nses}=inf;
                    end;
                end;
            end     % rest condition (all sessions)
            for ncond=1:nconditions,
                for nsub=1:NSUBJECTS,
                    for nses=1:nsessions,
                        batch.Setup.conditions.onsets{1+ncond}{nsub}{nses}=[];
                        batch.Setup.conditions.durations{1+ncond}{nsub}{nses}=[];
                    end;
                end;
            end
            for ncond=1:nconditions,
                for nsub=1:NSUBJECTS,
                    for nses=ncond,
                        batch.Setup.conditions.onsets{1+ncond}{nsub}{nses}=0;
                        batch.Setup.conditions.durations{1+ncond}{nsub}{nses}=inf;
                    end;
                end;
            end % session-specific conditions
        end
         
        batch.Setup.preprocessing.steps = {'functional_center','functional_removescans','functional_slicetime','functional_realign','functional_art','structural_center',...
            'structural_segment&normalize','functional_segment&normalize_indirect'};
        batch.Setup.preprocessing.sliceorder='ascending';
        %     batch.Setup.preprocessing.fwhm = 8; 
        batch.Setup.preprocessing.voxelsize_anat = 1;
        batch.Setup.preprocessing.voxelsize_func = 3;
        batch.Setup.preprocessing.removescans = 5;
        batch.Setup.preprocessing.boundingbox = [-90,-126,-72;90,90,108];
        batch.Setup.voxelresolution=3;
        batch.Setup.done=1;
        batch.Setup.overwrite='Yes';
        
        
        % uncomment the following 3 lines if you prefer to run one step at a time:
        conn_batch(batch); % runs Preprocessing and Setup steps only
        batch= [];
        batch = struct;
        batch.filename=fullfile(cwd,'conn_NEURIM_preprocess.mat');            % Existing conn_*.mat experiment name
        %
        %% DENOISING step
        % CONN Denoising                                    % Default options (uses White Matter+CSF+realignment+scrubbing+conditions as confound regressors); see conn_batch for additional options
        batch.Denoising.filter=[0.01, 0.1];                 % frequency filter (band-pass values, in Hz)
        batch.Denoising.done=1;
        batch.Denoising.overwrite='Yes';
        %     batch.Denoising.detrending = 2;
        %     batch.Denoising.despiking = 1;
        
        %     %
        
        % % uncomment the following 3 lines if you prefer to run one step at a time:
        conn_batch(batch); % runs Denoising step only
        batch= [];
        batch = struct;
        
        
        % FIRST-LEVEL ANALYSIS step: ROI to ROI
        % CONN Analysis                                     % Default options (uses all ROIs in conn/rois/ as connectivity sources); see conn_batch for additional options
        
        
        batch.filename=fullfile(cwd,'conn_NEURIM_preprocess.mat');
        batch.Analysis.analysis_number=1;       % Sequential number identifying each set of independent first-level analyses
        batch.Analysis.type = 2;
        batch.Analysis.measure = 1;               % connectivity measure used {1 = 'correlation (bivariate)', 2 = 'correlation (semipartial)', 3 = 'regression (bivariate)', 4 = 'regression (multivariate)';
        batch.Analysis.weight = 2;                % within-condition weight used {1 = 'none', 2 = 'hrf', 3 = 'hanning';
        batch.Analysis.sources={};              % (defaults to all ROIs)
        
        batch.Analysis.done=1;
        batch.Analysis.overwrite='Yes';
        conn_batch(batch);
        
        % batch.Analysis.sources.names = {'atlas','networks'};
        % batch.Analysis.sources.dimensions = {1,1};
        % batch.Analysis.sources.deriv = {0,0};
        
        
        batch.Analysis.done=1;
        batch.Analysis.overwrite='Yes';
        conn_batch(batch); % 
        clear batch;
        batch.filename=fullfile(cwd,'conn_NEURIM_preprocess.mat');            % Existing conn_*.mat experiment name
        
        
        
        %% FIRST-LEVEL ANALYSIS step: seed to voxel
        % % CONN Analysis                                     % Default options (uses all ROIs in conn/rois/ as connectivity sources); see conn_batch for additional options
        clear batch;
        batch.filename=fullfile(cwd,'conn_NEURIM_preprocess.mat');
        batch.Analysis.analysis_number=2;       % Sequential number identifying each set of independent first-level analyses
        batch.Analysis.type = 2;
        batch.Analysis.measure = 1;               % connectivity measure used {1 = 'correlation (bivariate)', 2 = 'correlation (semipartial)', 3 = 'regression (bivariate)', 4 = 'regression (multivariate)';
        batch.Analysis.weight = 2;                % within-condition weight used {1 = 'none', 2 = 'hrf', 3 = 'hanning';
        batch.Analysis.sources={};              % (defaults to all ROIs)
        
        
        % batch.Analysis.sources.names = {'atlas','networks'};
        % batch.Analysis.sources.dimensions = {1,1};
        % batch.Analysis.sources.deriv = {0,0};
        
        
        batch.Analysis.done=1;
        batch.Analysis.overwrite='Yes';
        
        conn_batch(batch); % 
        clear batch;
        batch.filename=fullfile(cwd,'conn_NEURIM_preprocess.mat');            % Existing conn_*.mat experiment name
        
        %% conevrting matc files to nii for coonfound free voxel data
        conn_matc2nii
    end
    
end
