%% Output average of searchlight maps across subjs
%   amf
%

clear all; close all; clc;

current_dir = pwd;
addpath(genpath([current_dir,'/source_code/CoSMoMVPA-master']));
addpath(genpath([current_dir,'/source_code/afni-master']));

%%
save_results = 1; % 1 for yes, 0 for no
show_results = 0;

numSubjs = 25;

output_path = current_dir;
output_file = strcat('Group_mean_',int2str(numSubjs),'s.nii');
output_path = fullfile(output_path, output_file);

%% Define data

chunks = 1:numSubjs;
targets = repmat(1,1,numSubjs);

ds = cosmo_fmri_dataset(strcat('all_subjs.nii.gz'), ...
                        'mask', 'mni_brain_mask.nii.gz', ...
                        'targets', targets, ...
                        'chunks', chunks);

ds = cosmo_remove_useless_data(ds);

%% Compute mean
data = ds.samples;
data = mean(data);
ds.samples = data;

ds.sa.targets = [1];
ds.sa.chunks  = [1];

%%
% Plot results, if specified
if show_results
    cosmo_plot_slices(ds);
end

% Store results to disc, if specified
if save_results
    cosmo_map2fmri(ds, output_path);
end
