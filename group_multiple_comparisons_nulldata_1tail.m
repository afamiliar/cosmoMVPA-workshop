%% Multiple comparison correction with Threshold-Free Cluster Enhancement
%       amf
%
%   *** this is intended to be example code (i.e. this is not runnable b/c
%       the datasets are NOT located in the workshop directory) ***
%
% cosmo_cluster_neighborhood
% cosmo_montecarlo_cluster_stat
%
%   one sample t-test
%       each sample (row in ds.samples) contains data from one subject
%       each unique value in .sa.chunks corresponds to one subject
%       each unique value in .sa.targets corresponds to a condition of interest
%
% For publication-quality analyses, niter=10000 or more is
% recommended
%

clear all; close all; clc;

current_dir = pwd;
addpath(genpath([current_dir,'/source_code/CoSMoMVPA-master']));
addpath(genpath([current_dir,'/source_code/afni-master']));

%%
save_results = 1; % 1 for yes, 0 for no
show_results = 0;

numSubjs = 25;
numNullDatasets = 50; % per subject
chunks   = 1:numSubjs;
targets  = ones(1,numSubjs);

output_path = current_dir;


%% Define data
% load null_data
fprintf('Now loading null datasets:\n');
for n = 1:numNullDatasets
    nulldata_path = '/Users/afam/Documents/Integration/null_data_randCond/';
    nulldata_path = strcat(nulldata_path,'smoothed_MNI_naive_bayes_searchlight_nulldata_',int2str(n),'.nii.gz/');
    null_data{n} = cosmo_fmri_dataset(strcat(nulldata_path,'all_nulldata_',int2str(numSubjs),'.nii.gz'), ...
                        'mask', 'mni_brain_mask.nii.gz', ...
                        'targets', targets, 'chunks', chunks);
   
%     null_data{n}=cosmo_remove_useless_data(null_data{n});
    
    disp(n)
end

% load original results
ds = cosmo_fmri_dataset(strcat('all_subjs.nii.gz'), ...
                        'mask', 'mni_brain_mask.nii.gz', ...
                        'targets', targets, ...
                        'chunks', chunks);

ds = cosmo_remove_useless_data(ds);

%% Define neighborhood 

fprintf('Now defining neighborhood:\n');
cl_nh = cosmo_cluster_neighborhood(ds);

% % Show a plot with the sorted number of neighbors for each voxel
% n_neighbors_per_feature = cellfun(@numel,cl_nh.neighbors);
% plot(sort(n_neighbors_per_feature))


%% Run cosmo_montecarlo_cluster_stat
% There is one condition per chunk; all targets are set to 1.
% Thus the subsequent anaylsis is a one-sample t-test.

opt = struct();
opt.h0_mean = 0.25; % t-test against this mean (chance accuracy)

% set the number of iterations.
opt.niter = 100; % recommended 10,000 for publication-quality results (but obviously takes a lot longer to run)

opt.null = null_data;

% % specify what cluster statistic to use (default is tfce)
% opt.cluster_stat = 'maxsize';
% opt.cluster_stat = 'maxsum';
% opt.cluster_stat = 'max';

% % this must be defined if cluster_stat is not tfce
% opt.p_uncorrected = 0.01; %0.001;

output_file = strcat('TFCE_group_',int2str(numSubjs),'s_',int2str(opt.niter),'iter_',int2str(numNullDatasets),...
                    'nulldata.nii');
output_path = strcat(output_path, output_file);

% using cosmo_montecarlo_cluster_stat, compute a map with z-scores
% against the null hypothesis of a mean [opt.h0_mean], corrected for multiple
% comparisons
fprintf('Now running t-tests:\n');
tfce_z_ds_stim = cosmo_montecarlo_cluster_stat(ds, cl_nh, opt);

%%
% Plot results, if specified
if show_results
    cosmo_plot_slices(tfce_z_ds_stim);
end

% Store results to disc, if specified
if save_results
    cosmo_map2fmri(tfce_z_ds_stim, output_path);
end