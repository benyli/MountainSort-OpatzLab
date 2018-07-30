% Get raw data for input to MountainSort
% takes nlx data from a specified folder and puts it in ./input
% Benjamin Li 2018-07

function prepare_raw_data_MountainSort()
close all;
clear all;

%% get experiment names
% assumes folder structure with CSCs in experiment-named folders
% ** change raw nlx experiment folder here **
datadir_folder = 'Q:\Recording_data_2018\Sebastian\';
experiments = dir(datadir_folder);
experiment_names = {};
for i=3:length(experiments)
    experiment_names{end+1} = experiments(i).name;
end

%% convert nlx from Neuralynx to mda for MountainSort
% ** change number of experiments here **
for experiment=1:3
    % time program for each experiment
    tic
    experiment_name = experiment_names{experiment};
    datadir = [datadir_folder experiment_name '\'];
    
    fprintf(['analyzing experiment ' experiment_name '\n']);
    
    % nlx_to_mda handles all nlx loading and mda file saving
    CSCs = [1:16];
    % can choose experiment period to sort inside nlx_to_mda with
    % ExtractModeArray
    nlx_to_mda(experiment_name, datadir, CSCs);
    toc
    fprintf('\n');
end

end
