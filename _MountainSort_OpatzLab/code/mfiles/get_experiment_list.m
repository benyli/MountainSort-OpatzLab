function experiments=get_experiment_list(Path,Nexperiment)
% function creates the selected experiment plus correlated parameters from
% the specified excel file
% input variable optional (vector), if not defined: all experiments are selected,
% if defined: selected experiments will be used

% Path='Q:\Personal\Sebastian\ProjectOptoChronicPFC\ExperimentPlan.xlsx';
ExcelSheet='InfoandDevMil';
xlRange='A1:FZ500';
[~,~,InfoandDevMil] = xlsread(Path,ExcelSheet,xlRange); % Import recording summary from excel sheet
for f1=1:size(InfoandDevMil,1)
    for f2=1:size(InfoandDevMil,2)
        if strcmp(InfoandDevMil{f1,f2},'NaN')
            InfoandDevMil{f1,f2}=NaN;
        end
    end
end

idxR_header1=3;
idxR_header2=4;
idxR_header3=5;


%% assign InfoandDevMil to experiments structure
idxC_header1=[find(cellfun(@ischar,InfoandDevMil(idxR_header1,:))) size(InfoandDevMil,2)+1];
IdxR=0;
idxC_Nexperiment=find(strcmp(InfoandDevMil(idxR_header3,:),'Nexperiment'));
idxC_ExpType=find(strcmp(InfoandDevMil(idxR_header3,:),'ExpType'));
for r1=6:size(InfoandDevMil,1)
    if ~isnan(InfoandDevMil{r1,idxC_Nexperiment}) && ischar(InfoandDevMil{r1,idxC_ExpType}) && or(isempty(Nexperiment),ismember(InfoandDevMil{r1,idxC_Nexperiment},Nexperiment))
        IdxR=IdxR+1;
        for h1=1:length(idxC_header1)-1
            idxC_header2=[find(cellfun(@ischar,InfoandDevMil(idxR_header2,idxC_header1(h1):idxC_header1(h1+1)-1)))+idxC_header1(h1)-1 idxC_header1(h1+1)];
            for h2=1:length(idxC_header2)-1
                idxC_header3=find(cellfun(@ischar,InfoandDevMil(idxR_header3,idxC_header2(h2):idxC_header2(h2+1)-1)))+idxC_header2(h2)-1;
                for h3=1:length(idxC_header3)
                        experiments(IdxR,1).(InfoandDevMil{idxR_header1,idxC_header1(h1)}).(InfoandDevMil{idxR_header2,idxC_header2(h2)}).(InfoandDevMil{idxR_header3,idxC_header3(h3)})=InfoandDevMil{r1,idxC_header3(h3)};
                end
            end
        end
    end
end
