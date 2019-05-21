%% odd-even classification with LDA classifier
%
% *** modified by Ariana Familiar for fMRI discussion group workshop on
% 5-21-2019 at the University of Pennsylvania ****
%
%
% #   For CoSMoMVPA's copyright information and license terms,   #
% #   see the COPYING file distributed with CoSMoMVPA.           #

clear all; close all; clc;

current_dir = pwd;
addpath(genpath([current_dir,'/source_code/CoSMoMVPA-master'])); % path to source code

%% Data input
% manually define path where data is located
study_path  = [current_dir, '/tutorial_data/ak6/']; % this works if the code is run in the same directory as tutorial data dir

% Load the dataset with VT (ventral temporal) mask
subject_id = 's01';
data_path  = [study_path, subject_id]; % data from subject s01

num_cond = 6;
num_runs = 10;
targets  = repmat((1:num_cond)', num_runs,1);
chunks   = floor(((1:(num_cond*num_runs))-1)/num_cond)'+1;

ds = cosmo_fmri_dataset([data_path '/glm_T_stats_perrun.nii'], ...
                     'mask', [data_path '/vt_mask.nii'], ...
                     'targets', targets, ...
                     'chunks',chunks);

% remove constant features
ds = cosmo_remove_useless_data(ds);

%% Define sample attributes
% Add labels as sample attributes
classes = {'monkey','lemur','mallard','warbler','ladybug','lunamoth'};
ds.sa.labels = repmat(classes,1,num_runs)';

%% Part 1: classify all categories; train/test on even/odd runs and vice versa
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Partition into training/testing data:
%   slice into odd and even runs using ds.sa.chunks attribute, and
%   store in new dataset structs called 'ds_even' and 'ds_odd'.
%   (hint: use the 'mod' function (remainder after division) to see which
%   chunks are even or odd)
even_msk = mod(ds.sa.chunks,2)==0;
odd_msk  = mod(ds.sa.chunks,2)==1;

ds_even = cosmo_slice(ds, even_msk);
ds_odd  = cosmo_slice(ds, odd_msk);

% First, train on even, test on odd
train_samples = ds_even.samples;
train_targets = ds_even.sa.targets;
test_samples  = ds_odd.samples;

test_pred = cosmo_classify_lda(train_samples, train_targets, test_samples);

test_targets = ds_odd.sa.targets;
accuracy     = mean(test_pred==test_targets);
fprintf('\nLDA all categories even-odd: accuracy %.3f\n', accuracy);

% Now train on odd, test on even
train_samples = ds_odd.samples;
train_targets = ds_odd.sa.targets;
test_samples  = ds_even.samples;

test_pred = cosmo_classify_lda(train_samples, train_targets, test_samples);

test_targets = ds_even.sa.targets;
accuracy     = mean(test_pred==test_targets);
fprintf('\nLDA all categories odd-even: accuracy %.3f\n', accuracy);


%% Part 2: bird classification; train on even runs, test on odd runs
%  discriminate between mallards and warblers
categories={'mallard','warbler'};

% select samples where .sa.labels match on of the categories
% for the even and odd runs seperately. Slice the dataset twice and store
% the result in 'ds_even_birds' and 'ds_odd_birds'
% (use cosmo_match with .sa.labels and categories to define a mask,
% then cosmo_slice to select the data)
msk_even_birds = cosmo_match(ds_even.sa.labels, categories);
ds_even_birds  = cosmo_slice(ds_even, msk_even_birds);

msk_odd_birds = cosmo_match(ds_odd.sa.labels, categories);
ds_odd_birds  = cosmo_slice(ds_odd, msk_odd_birds);

% % show the data
% fprintf('Even data:\n')
% cosmo_disp(ds_even_birds);
% 
% fprintf('Odd data:\n')
% cosmo_disp(ds_odd_birds);

% ======= train on even runs, test on odd runs ========
% Use cosmo_classify_lda to get predicted targets for the odd runs when
% training on the even runs, and assign these predictions to
% a variable 'test_pred'.
% (hint: use .samples and .sa.targets from ds_even_birds, and
%        use .samples from ds_odd_birds)
train_samples = ds_even_birds.samples;
train_targets = ds_even_birds.sa.targets;
test_samples  = ds_odd_birds.samples;

test_pred = cosmo_classify_lda(train_samples, train_targets, test_samples);

% Assign the real tagets of the odd runs to a variable 'test_targets'
test_targets = ds_odd_birds.sa.targets;

% show real and predicted labels
fprintf('\ntarget predicted\n');
disp([test_targets test_pred])

% compare the predicted labels for the odd
% runs with the actual targets to compute the accuracy. Store the accuracy
% in a variable 'accuracy'.
accuracy = mean(test_pred==test_targets);
fprintf('\nLDA birds even-odd: accuracy %.3f\n', accuracy);

% compare with naive bayes classification
% (hint: do classification as above, but use cosmo_classify_naive_bayes)
test_pred_nb = cosmo_classify_naive_bayes(train_samples, train_targets, test_samples);

test_targets = ds_odd_birds.sa.targets;
accuracy     = mean(test_pred_nb==test_targets);
fprintf('\nNaive Bayes birds even-odd: accuracy %.3f\n', accuracy);

