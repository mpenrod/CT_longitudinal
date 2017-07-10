% Parallel processes recon-all commands in order to reduce processing
% times.
%% setup directory info
subID = {'NLR_145_AC', 'NLR_151_RD', 'NLR_161_AK', 'NLR_172_TH',...
    'NLR_180_ZD', 'NLR_208_LH', 'NLR_102_RS', 'NLR_150_MG', 'NLR_152_TC', ...
    'NLR_162_EF', 'NLR_174_HS', 'NLR_210_SB', 'NLR_110_HH', 'NLR_160_EK', ...
    'NLR_170_GM', 'NLR_179_GM', 'NLR_207_AH', 'NLR_211_LB', 'NLR_164_SF', ...
    'NLR_204_AM', 'NLR_206_LM', 'NLR_163_LF', 'NLR_205_AC', 'NLR_127_AM', ...
    'NLR_105_BB', 'NLR_132_WP', 'NLR_187_NB', 'RI_124_AT', 'RI_143_CH', ...
    'RI_138_LA', 'RI_141_GC', 'RI_144_OL','NLR_199_AM', 'NLR_130_RW', ...
    'NLR_133_ML', 'NLR_146_TF', 'NLR_195_AW', 'NLR_191_DF', 'NLR_197_BK', ...
    'NLR_201_GS', 'NLR_202_DD', 'NLR_203_AM', 'NLR_101_LG', 'NLR_103_AC'};
% clobber = 1;
% makesurface = 0;
% maindir = '/mnt/scratch/MRI/';
% anatdir = '/mnt/scratch/anatomy/';
% addpath(genpath('/mnt/scratch'))
%% create arrays with file paths and subject IDs
% filepaths = {};
% outsubIDs = {};
% ITKs = {};
% for ss = 1:numel(subID)
%     subject = subID{ss};
%     for processed = 1:5
%         file2bprocessed = fullfile(anatdir, subject, (strcat('t1_acpc_', num2str(processed), '.nii.gz')));
%         outsubID = strcat(subject, '_', num2str(processed));
%         nextITK = fullfile(anatdir,subject,...
%             (strcat('fs_seg_', num2str(processed),'.nii.gz')));
%         if exist(file2bprocessed,'file')
%             filepaths = [filepaths,{file2bprocessed}];
%             outsubIDs = [outsubIDs,{outsubID}];
%             ITKs = [ITKs,{nextITK}];
%         else
%             break
%         end
%     end
% end
% processedSubs = {'NLR_105_BB_2', 'NLR_105_BB_3', 'NLR_105_BB_4', ...
%     'NLR_110_HH_2', 'NLR_110_HH_3', 'NLR_110_HH_4', 'NLR_132_WP_1', ...
%     'NLR_152_TC_2', 'NLR_152_TC_3', 'NLR_152_TC_4', 'NLR_152_TC_5', ...
%     'NLR_160_EK_1', 'NLR_160_EK_2', 'NLR_162_EF_1', 'NLR_163_LF_1', ...
%     'NLR_163_LF_2', 'NLR_163_LF_3', 'NLR_163_LF_4', 'NLR_180_ZD_3', ...
%     'NLR_180_ZD_4', 'NLR_208_LH_1', 'NLR_208_LH_2', 'NLR_211_LB_1', ...
%     'NLR_211_LB_2', 'NLR_211_LB_3', 'NLR_211_LB_4'};
% count = 0;
% for ii = 1:105
%     for jj = 1:numel(processedSubs)
%         if outsubIDs{ii} == processedSubs{jj}
%             count = count + 1;
%             outsubIDs{ii} = {};
%             filepaths{ii} = {};
%             ITKs{ii} = {};
%             break
%         end
%     end
% end
%% parallel process the MRI data
% parfor id = 5:(floor(numel(filepaths)/2))
%     if ~iscell(filepaths{id}) && ~iscell(outsubIDs{id})
%         cmd = sprintf('recon-all -i %s -subjid %s -all',filepaths{id},outsubIDs{id});
%         system(cmd);
%     end
% end
%
% for rr = 5:(floor(numel(filepaths)/2))
%     if ~iscell(filepaths{rr}) && ~iscell(ITKs{rr}) && ~iscell(outsubIDs{rr})
%         % reformat freesurfer segmentation for mrVista ITKgray
%         fs_ribbon2itk(outsubIDs{rr}, ITKs{rr},[], filepaths{rr})
%     end
% end
%% run base/long command in parallel
% parfor ff = 1:19
%     if ~strcmp(subID{ff},'NLR_145_AC') && ~strcmp(subID{ff},'NLR_208_LH') ...
%             && ~strcmp(subID{ff},'NLR_132_WP')
%         fs_base_recon(subID{ff});
%     end
% end

% collect all the recon-all -long commands for this half
all_long_cmds = cell(155);
tt = 1;
index = 1;
while tt <= 16
    sub_long_cmds = {};
    if ~strcmp(subID{tt},'NLR_145_AC') && ~strcmp(subID{tt},'NLR_132_WP') ...
            && ~strcmp(subID{tt},'NLR_151_RD') && ~strcmp(subID{tt},'NLR_208_')
        sub_long_cmds = fs_long_recon(subID{tt});
        for ll = 1:numel(sub_long_cmds)
            all_long_cmds{index + (ll-1)} = sub_long_cmds{ll};
        end
    end
    index = index + numel(sub_long_cmds);
    tt = tt + 1;
end
all_long_cmds = all_long_cmds(1:(index-1));

% run all recon-all -long commands
parfor cc = 1:numel(all_long_cmds)
    system(all_long_cmds{cc});
end
