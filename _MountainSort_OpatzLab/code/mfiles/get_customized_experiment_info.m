% modifed get_experiment_list to retrun customized info
% Benjamin Li 2018-07

function [all_experiment_names, all_experiment_ages]=get_customized_experiment_info()

% Analysis of ephys data for single animals (recorded with neuralynx)
% Sebastian Bitzenhofer 2016-12

%% EXPERIMENT SET
%% basic analysis information
Nexperiment=[];
Path='Q:\Personal\Sebastian\ProjectOptoChronicPFC\ExperimentPlan.xlsx';
experiments=get_experiment_list(Path,Nexperiment);

resultsdir_main='Q:\Personal\Sebastian\ProjectOptoChronicPFC\Analysis\results\EphysAnalysis\';

groups={'Db1','Db'}; % just run if only certain groups required
Num1=0;
for f1=1:size(experiments,1)
    if ~isempty(experiments(f1).Basic.General.animalID) && sum(isnan(experiments(f1).AcuteRecordings.Recording1.RecordingName))==0
        if  ~any(strcmp(experiments(f1).Basic.General.ExpType,groups)) % with ~ exclude, without ~ only include
            Num1=Num1+1;
            experiments1(Num1,1)=experiments(f1);
        end
    end
end
experiments=experiments1;
clear experiments1


%% match animals with ages
all_experiment_names = {};
all_experiment_ages = {};
for f1=1:size(experiments,1)
    if ~isempty(experiments(f1).Basic.General.animalID) && sum(isnan(experiments(f1).AcuteRecordings.Recording1.RecordingName))==0
        all_experiment_names{end+1}=experiments(f1).AcuteRecordings.Recording1.RecordingName;
        all_experiment_ages{end+1}=experiments(f1).AcuteRecordings.General.P_age;
    end
end

end
