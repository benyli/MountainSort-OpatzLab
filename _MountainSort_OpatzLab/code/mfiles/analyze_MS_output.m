% Analyze MountainSort mda output after sorting
% takes mda data from ./output, without or with automated curation, and
% runs analysis
% Benjamin Li 2018-07

% mda file format docs:
% https://mountainsort.readthedocs.io/en/latest/first_sort.html
% https://github.com/flatironinstitute/mountainlab/blob/master/docs/source/mda_file_format.rst


close all;
clear all;

% assumes folder structure as given in _MountainSort_OpatzLab
workingdir = [pwd '\'];
datadir = [workingdir '..\output\'];
addpath(genpath([workingdir '..\mountainlab-master\matlab\mdaio']));

% ** change whether you run output data without ('no') or with ('with')
% curation **
experiments = dir([datadir '*.' 'no' '_curation.mda']);
experiment_names = {};
for i=1:length(experiments)
    experiment_names{end+1} = experiments(i).name;
end

n_clusters = zeros(length(experiment_names),1);
for experiment=1:length(experiment_names)
    experiment_name = experiment_names{experiment};
    
    fprintf(['Analyzing experiment ' experiment_name '\n']);
    
    data = readmda([datadir experiment_name]);
    % each column is a firing event
    channels = data(1,:);
    timepoints = data(2,:);
    clusters = data(3,:);
    
    n_clusters(experiment) = length(unique(clusters));
end

figure();
histogram(n_clusters,[0:50],'FaceColor','b','EdgeColor','b');
title('clusters found','FontSize',16);
xlabel('clusters','FontSize',14);
ylabel('','FontSize',14);
ytickformat('%.0i');
box off;
set(gcf,'Color','w');
mean(n_clusters)


%% n_clusters vs. age

[all_experiment_names, all_experiment_ages]=get_customized_experiment_info();

fprintf('getting all experiments with age information\n');
updated_experiment_names = {};
found_experiment_indices = {};
experiment_ages = {};
for experiment=1:length(experiment_names)
    recording_name = (strsplit(experiment_names{experiment},'.'));
    recording_name = recording_name{2};
      
    for all_experiment_index=1:length(all_experiment_names)
        if strcmp(recording_name, all_experiment_names(all_experiment_index))
            % age information available
            updated_experiment_names{end+1} = experiment_names{experiment};
            experiment_ages{end+1} = all_experiment_ages{all_experiment_index};
            found_experiment_indices{end+1} = experiment;
        end
    end
end
found_experiment_indices = cell2mat(found_experiment_indices);

experiment_names = updated_experiment_names;
experiment_ages = cell2mat(experiment_ages);
n_clusters = n_clusters(found_experiment_indices);


fprintf('organizing and plotting age group information\n');
age_bounds = [0,5; 6,10; 11,15; 16,20; 21,25; 26,30; 31,35; 36,40; 41,50];
avg_clusters_vs_ages = zeros(size(age_bounds,1),1);
for age_range=1:size(age_bounds,1)
    lower_bound = age_bounds(age_range,1);
    upper_bound = age_bounds(age_range,2);
    
    age_indices = find(experiment_ages>=lower_bound & experiment_ages<upper_bound);
    if isempty(age_indices)
        avg_clusters_vs_ages(age_range) = 0;
    else
        avg_clusters_vs_ages(age_range) = mean(n_clusters(age_indices));
    end
end

age_bounds_string = {};
for row=1:size(age_bounds,1)
    age_string = mat2str(age_bounds(row,:));
    age_string = age_string(2:end-1);
    age_bounds_string{end+1} = ['[' age_string ')'];
end

figure();
bar(avg_clusters_vs_ages,'FaceColor','b','EdgeColor','b');
title('clusters found vs. age group','FontSize',16);
xlabel('age group','FontSize',14);
ylabel('clusters','FontSize',14);
xticklabels(age_bounds_string);
box off;
set(gcf,'Color','w');


%% firing rate vs. age
% note this depends on information about the length of the input recording

firing_rates = cell(1,length(experiment_names));
for experiment=1:length(experiment_names)
    experiment_name = experiment_names{experiment};
    
    fprintf(['Analyzing experiment ' experiment_name '\n']);
    
    data = readmda([datadir experiment_name]);
    % each column is a firing event
    channels = data(1,:);
    timepoints = data(2,:);
    clusters = data(3,:);
    
    clusters_firing_rates = zeros(length(unique(clusters)),1);
    for cluster=1:length(clusters_firing_rates)
        clusters_firing_rates(cluster) = sum(clusters(:)==cluster) / 10000000;
        % 32000 samples/second
        clusters_firing_rates(cluster) = clusters_firing_rates(cluster)*32000;
    end
    
    % firing_rates is a 1xn cell array where each cell is a vector with that
    % experiment's n_clusters cluster firing rates
    firing_rates{experiment} = clusters_firing_rates;
end

fprintf('organizing and plotting firing rate information\n');
age_bounds = [0,5; 6,10; 11,15; 16,20; 21,25; 26,30; 31,35; 36,40; 41,50];
avg_fr_vs_ages = zeros(size(age_bounds,1),1);
for age_range=1:size(age_bounds,1)
    lower_bound = age_bounds(age_range,1);
    upper_bound = age_bounds(age_range,2);
    
    age_indices = find(experiment_ages>=lower_bound & experiment_ages<upper_bound);
    if isempty(age_indices)
        avg_fr_vs_ages(age_range) = 0;
    else
        all_clusters_fr_at_age = firing_rates{age_indices(1)};
        for age_index=2:length(age_indices)
            all_clusters_fr_at_age = [all_clusters_fr_at_age; firing_rates{age_index}];
        end
        avg_fr_vs_ages(age_range) = median(all_clusters_fr_at_age);
    end
end

figure();
scatter([1:length(age_bounds)],avg_fr_vs_ages,'b');
title('unit firing rates vs. age group, continuous recording','FontSize',16);
xlabel('age group','FontSize',14);
ylabel('median unit firing rate (spikes/sec.)','FontSize',14);
xticklabels(age_bounds_string);
box off;
set(gcf,'Color','w');


%% interspike intervals vs. age

interspike_intervals = cell(1,length(experiment_names));
for experiment=1:length(experiment_names)
    experiment_name = experiment_names{experiment};
    
    fprintf(['Analyzing experiment ' experiment_name '\n']);
    
    data = readmda([datadir experiment_name]);
    % each column is a firing event
    channels = data(1,:);
    timepoints = data(2,:);
    clusters = data(3,:);
    
    n_clusters = length(unique(clusters));
    
    % experiment_interspike_intervals is a 1xn cell array where each cell
    % is a 1xn_clusters cell array of cluster_interpike_interval vectors
    experiment_interspike_intervals = cell(1,n_clusters);
    for cluster=1:n_clusters
        cluster_indices = find(clusters==cluster);
        cluster_timepoints = timepoints(cluster_indices);
        cluster_interpike_interval = diff(cluster_timepoints);
        % 32000 samples/samples
        cluster_interpike_interval = cluster_interpike_interval./32000;
        
        experiment_interspike_intervals{cluster} = cluster_interpike_interval;
    end
    interspike_intervals{experiment} = experiment_interspike_intervals;
end

fprintf('organizing and plotting interspike interval information\n');
figure();
title('interspike intervals, continuous recording','FontSize',16);
xlabel('interspike interval (sec.)','FontSize',14);
ylabel('counts','FontSize',14);
box off;
set(gcf,'Color','w');
hold on;
histogram_edges = [0:0.001:0.2];
age_bounds = [0,5; 6,10; 11,15; 16,20; 21,25; 26,30; 31,35; 36,40; 41,50];
for age_range=1:2
    lower_bound = age_bounds(age_range,1);
    upper_bound = age_bounds(age_range,2);
    
    age_indices = find(experiment_ages>=lower_bound & experiment_ages<upper_bound);
    if ~isempty(age_indices)
        for age_index=1:length(age_indices)
            current_experiment_interspike_intervals = interspike_intervals{age_index};
            
            for cluster=1:length(current_experiment_interspike_intervals)
                current_cluster_interspike_intervals = current_experiment_interspike_intervals{cluster};
                
                [N,edges] = histcounts(current_cluster_interspike_intervals, histogram_edges);
                sz = 30;
                c = [1-age_index/length(age_indices) 0 age_index/length(age_indices)];
                scatter(histogram_edges(2:end),N,sz,c,'.');
%                 histogram(current_experiment_interspike_intervals{cluster},histogram_edges);
            end
        end
    end
end
hold off;
