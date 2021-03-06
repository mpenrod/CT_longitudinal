% edit this to actual SUBJECTS_DIR
cd('/mnt/scratch/projects/freesurfer');

%% Load in thickness data, spherical surface, and cortex labels
[lhY,lh_mri] = fs_read_Y('lh_intervention.thickness.stack.fwhm10.mgh');
lhsphere = fs_read_surf('fsaverage/surf/lh.sphere');
lhcortex = fs_read_label('fsaverage/label/lh.cortex.label');
[rhY,rh_mri] = fs_read_Y('rh_intervention.thickness.stack.fwhm10.mgh');
rhsphere = fs_read_surf('fsaverage/surf/rh.sphere');
rhcortex = fs_read_label('fsaverage/label/rh.cortex.label');

%% Construct design matrix
Qdec = fReadQdec('inter_long.qdec.table.dat');
% remove the column denoting time points
Qdec = rmQdecCol(Qdec,1); 
% grab subject IDs (fsID-base) and then remove the column
sID = Qdec(2:end,1);
% remove age column
Qdec = rmQdecCol(Qdec,2);
% convert the remaining data to a numeric matrix and sort the data
M = Qdec2num(Qdec);
% M = ordered design matrix, Y = ordered data matrix, and ni = a vector 
% with the number of repeated measures for each subject
[M,lhY,ni] = sortData(M,1,lhY,sID);
[M,rhY,ni] = sortData(M,1,rhY,sID);

%% Parameter estimation and inference
% zcol = [ones(90,1) zeros(90,1)];
% [stats,st] = lme_mass_fit(M,[],[],zcol,Y,ni);

% [lh_stats,lh_st] = lme_mass_fit_vw(M,[1],lhY,ni,[],'lh_lme_stats',6);
% [rh_stats,rh_st] = lme_mass_fit_vw(M,[1],rhY,ni,[],'rh_lme_stats',6);

[lhTh0,lhRe] = lme_mass_fit_EMinit(M,[1],lhY,ni,lhcortex);
[rhTh0,rhRe] = lme_mass_fit_EMinit(M,[1],rhY,ni,rhcortex);

[lhRgs,lhRgMeans] = lme_mass_RgGrow(lhsphere,lhRe,lhTh0,lhcortex,2,95);
[rhRgs,rhRgMeans] = lme_mass_RgGrow(rhsphere,rhRe,rhTh0,rhcortex,2,95);

lhstats = lme_mass_fit_Rgw(M,[1],lhY,ni,lhTh0,lhRgs,lhsphere);
rhstats = lme_mass_fit_Rgw(M,[1],rhY,ni,rhTh0,rhRgs,rhsphere);


lh_fstats = lme_mass_F(lhstats,CM,[]);
rh_fstats = lme_mass_F(rhstats,CM,[]);

