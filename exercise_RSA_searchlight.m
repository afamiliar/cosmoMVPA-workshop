%% Searchlight for representational similarity analysis
%
% *** modified by Ariana Familiar for fMRI discussion group workshop on
% 5-21-2019 at the University of Pennsylvania ****
%
%
% Using cosmo_searchlight, run cross-validation with nearest neighbor
% classifier
%
%   Exercise explanation:  http://cosmomvpa.org/ex_rsa_tutorial.html
%
%   Answer code:  http://cosmomvpa.org/matlab/run_rsm_measure_searchlight.html#run-rsm-measure-searchlight
%
% #   For CoSMoMVPA's copyright information and license terms,   #
% #   see the COPYING file distributed with CoSMoMVPA.           #


clear all; close all; clc;

current_dir = pwd;
addpath(genpath([current_dir,'/source_code/CoSMoMVPA-master'])); % path to source code

%% Define data
% manually define path where data is located
study_path  = [current_dir, '/tutorial_data/ak6/']; % this works if the code is run in the same directory as tutorial data dir
output_path = pwd;

data_path = fullfile(study_path,'s01');
data_fn   = fullfile(data_path,'/glm_T_stats_perrun.nii');
mask_fn   = fullfile(data_path,'/brain_mask.nii');
% targets=; % define this!
ds = cosmo_fmri_dataset(data_fn, ...
                        'mask', mask_fn,...
                        'targets', targets);

% compute average for each unique target, so that the dataset has 6
% samples - one for each target

%%%% >>> Your code here <<< %%%%

% load V1 model and behavioral DSMs
models_path=fullfile(study_path,'models');
load(fullfile(models_path,'behav_sim.mat'));
load(fullfile(models_path,'v1_model.mat'));

%% Set measure
% Set the 'measure' and 'measure_args' to use the
% @cosmo_target_dsm_corr_measure measure and set its parameters
% to so that the target_dsm is based on behav_sim.mat

%%%% >>> Your code here <<< %%%%

% Enable centering the data
measure_args.center_data = true;

%% Run searchlight
% use spherical neighborhood of 100 voxels
% define a neighborhood using cosmo_spherical_neighborhood
%%%% >>> Your code here <<< %%%%

% Run the searchlight
%%%% >>> Your code here <<< %%%%

% Save the results to disc using the following command:
cosmo_map2fmri(results, ...
            fullfile(output_path,'/rsm_searchlight_behav.nii'));

%% Make a histogram of correlations
hist(results.samples,47)

%% Show some slices
% plot the results using cosmo_plot_slices

%%%% >>> Your code here <<< %%%%

%% Advanced exercise: regresion-based RSA

% Using @cosmo_target_dsm_corr_measure, investigate the relative
% contributions of the v1-model and behavioural similarity matrix.
%
% Thus, set the 'measure' and 'measure_args' to use the
% @cosmo_target_dsm_corr_measure measure and set its parameters
% so that the 'glm_dsm' option uses the 'behav' and 'v1_model' targets

%%%% >>> Your code here <<< %%%%

% Enable centering the data
measure_args.center_data = true;


%% Run searchlight
% use spherical neighborhood of 100 voxels
% define a neighborhood using cosmo_spherical_neighborhood

%%%% >>> Your code here <<< %%%%

% Run the searchlight
%%%% >>> Your code here <<< %%%%

% Save the results to disc using the following command:
cosmo_map2fmri(glm_dsm_results, ...
            fullfile(output_path,'/rsm_searchlight_glm_behav-v1.nii'));

%% Show behavioural searchlight map
figure();
cosmo_plot_slices(cosmo_slice(glm_dsm_results,1));

%% Show V1 searchlight map
figure();
cosmo_plot_slices(cosmo_slice(glm_dsm_results,2));