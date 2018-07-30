% Take nlx to mda data and save it as input for MountainSort
% Benjamin Li 2018-07

function nlx_to_mda(experiment_name, datadir, CSCs)

%% get stimuluation info. Extraction is very slow. Avoid reloading if possible
fprintf('getting stimulation and baseline info\n');
[StimulationProperties,BaselinePeriods]=StimulationPropertiesBaselinePeriods(datadir);
% ask Sebastian about this
if isnan(BaselinePeriods{1,5})
    return;
end

%% load nlx data
fprintf('loading nlx data\n');
samples = {};
% for efficiency, load in what you need here
ExtractModeArray=[BaselinePeriods{1,5}, BaselinePeriods{1,5}+10000000];
count = 1;
n_channels = length(CSCs);
for CSC=CSCs
    % TimeStamps output is inaccurate so don't use it
    [~,samples{count},fs]=load_nlx_Modes(strcat(datadir,'CSC',num2str(count),'.ncs'),2,ExtractModeArray);
    count = count + 1;
end

%% save nlx data channels
% raw data for conversion to .mda file format must be MxN. M=electrode
% channels, N=timepoints
fprintf('organizing nlx data channels\n');
% can modify sample_length here, but probably better to extract what you
% need with ExtractModeArray
sample_length = length(samples{1});
sample_start = 1;
sample_end = sample_start + sample_length - 1;
nlx_data = zeros(n_channels, sample_length);
for channel=1:n_channels
    nlx_data(channel,1:sample_length) = samples{channel}(sample_start:sample_end);
end

%% run MountainLab Matlab setup files and save mda input file
fprintf('saving mda input file for MountainSort\n');
% assumes folder structure as given in _MountainSort_OpatzLab
workingdir = [pwd '\'];
change_path = [workingdir '..\mountainlab-master\matlab'];
cd(change_path);
run mlsetup.m;
cd(workingdir);
writemda16i(nlx_data,[workingdir '..\input\raw_data.' experiment_name '.mda']);

end
