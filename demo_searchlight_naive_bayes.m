%% Demo: fMRI searchlight with naive bayes classifier
%
% *** modified by Ariana Familiar for fMRI discussion group workshop on
% 5-21-2019 at the University of Pennsylvania ****
%
%
% The data used here is available from http://cosmomvpa.org/datadb-v0.3.zip
%
% This example uses the following dataset:
%  'digit'
%    A participant made finger pressed with the index and middle finger of
%    the right hand during 4 runs in an fMRI study. Each run was divided in
%    4 blocks with presses of each finger and analyzed with the GLM,
%    resulting in 2*4*4=32 t-values
%
% This example uses the cosmo_naive_bayes_classifier_searchlight, which is
% a fast alternative to using the regular searchlight with a
% crossvalidation measure and a classifier
%
% #   For CoSMoMVPA's copyright information and license terms,   #
% #   see the COPYING file distributed with CoSMoMVPA.           #

clear all; close all; clc;

current_dir = pwd;
addpath(genpath([current_dir,'/source_code/CoSMoMVPA-master'])); % path to source code
addpath(genpath([current_dir,'/source_code/afni-master'])); % path to AFNI source code

%% Data input
% manually define path where data is located, and where output should
% be saved
study_path  = [current_dir, '/tutorial_data/digit/']; % this works if the code is run in the same directory as tutorial data dir
output_path = current_dir;

%% Load data and define partitions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This analysis identified brain regions where the categories can be
% distinguished using an odd-even partitioning scheme and a Naive Bayes
% classifier.

data_path = study_path;
data_fn   = [data_path, 'glm_T_stats_perblock+orig.HEAD'];
mask_fn   = [data_path, 'brain_mask+orig.HEAD'];

num_cond = 2;
num_runs = 16;
targets  = repmat(1:num_cond,1,num_runs)';    % class labels: 1 2 1 2 1 2 1 2 1 2 ... 1 2
chunks   = floor(((1:(num_cond*num_runs))-1)/(num_runs/2))+1; % run labels:   1 1 1 1 1 1 1 1 2 2 ... 4 4

ds_per_run = cosmo_fmri_dataset(data_fn, ...
                                'mask', mask_fn,...
                                'targets', targets,...
                                'chunks', chunks);

% % print dataset
% fprintf('Dataset input:\n');
% cosmo_disp(ds_per_run);


% set parameters for naive bayes searchlight (partitions) in a
% measure_args struct.
measure_args = struct();

% Set partition scheme. odd_even is fast; for publication-quality analysis
% nfold_partitioner is recommended.
% Alternatives are:
% - cosmo_nfold_partitioner    (take-one-chunk-out crossvalidation)
% - cosmo_nchoosek_partitioner (take-K-chunks-out  "             ").
measure_args.partitions = cosmo_oddeven_partitioner(ds_per_run);

% % print measure and arguments
% fprintf('Searchlight measure arguments:\n');
% cosmo_disp(measure_args);

% Define a neighborhood with approximately 100 voxels in each searchlight.
nvoxels_per_searchlight = 100;
disp('Defining neighborhood:')
nbrhood = cosmo_spherical_neighborhood(ds_per_run,...
                        'count', nvoxels_per_searchlight);


%% Run the searchlight
%
disp('Running searchlight:')
nb_results = cosmo_naive_bayes_classifier_searchlight(ds_per_run,...
                                                nbrhood,measure_args);

%% Show and save results
% print output dataset
% fprintf('Dataset output:\n');
% cosmo_disp(nb_results);

% Plot the output
cosmo_plot_slices(nb_results);

% Define output location
output_fn = [output_path, '/naive_bayes_searchlight+orig'];

% Store results to disc
cosmo_map2fmri(nb_results, output_fn);

