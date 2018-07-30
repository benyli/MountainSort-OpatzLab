% Script calculating StimulationProperties and BaselinePeriods for LFP recordings with optogenetic stimulation
% Sebastian Bitzenhofer 2016-10

function [StimulationProperties,BaselinePeriods]=StimulationPropertiesBaselinePeriods(datadir)
%% Detect stimulation times
% Load STIM1D
[time,STIM1D,fs]=load_nlx_Modes(strcat(datadir,'STIM1D.ncs'),1,[]);
STIM1D=STIM1D-median(STIM1D(1:fs*5))>((max(STIM1D)-median(STIM1D(1:fs*5)))*0.1); %standard 0.1

STIM1start=find(diff(STIM1D)==1);
STIM1end=find(diff(STIM1D)==-1);

clear STIM1D

STIM1dur=STIM1end-STIM1start;
STIM1int=(STIM1start(2:end)-STIM1end(1:end-1));

STIM1startPeriods=STIM1start([true STIM1int>fs]);
STIM1endPeriods=STIM1end([STIM1int>fs true]);
STIM1durPeriods=STIM1endPeriods-STIM1startPeriods;

%% Calculate stimulation period properties
StimulationProperties(:,1)=num2cell(time(STIM1startPeriods)');
StimulationProperties(:,2)=num2cell(time(STIM1endPeriods)');
StimulationProperties(:,10)=num2cell(STIM1startPeriods');
StimulationProperties(:,11)=num2cell(STIM1endPeriods');
StimulationProperties(:,3)=num2cell(round(STIM1durPeriods'/fs));

[STIM1numPulses,BinPulses]=histc(STIM1start,[STIM1startPeriods STIM1endPeriods(end)]);
STIM1numPulses=STIM1numPulses(1:end-1);
StimulationProperties(:,4)=num2cell(STIM1numPulses');
StimulationProperties(:,6)=num2cell(STIM1numPulses'./round(STIM1durPeriods'/fs));

for f1=1:length(STIM1startPeriods)
    StimulationProperties{f1,5}=round(mean(STIM1dur(BinPulses==f1)/fs*10^3));
    StimulationProperties{f1,9}=time(STIM1start(BinPulses==f1));
    StimulationProperties{f1,12}=STIM1start(BinPulses==f1);
    
    [~,STIM1A,~]=load_nlx_Modes(strcat(datadir,'STIM1A.ncs'),2,[STIM1startPeriods(f1) STIM1endPeriods(f1)]);
    StimulationProperties{f1,7}=round(0.0058*max(STIM1A)-2); %% Formula generated from laser output measurements
    
    if STIM1numPulses(f1)>1
        StimulationProperties{f1,8}='squareFreq';
    elseif max(STIM1A(1:round(length(STIM1A)/2)))<max(STIM1A)*0.75
        StimulationProperties{f1,8}='ramp';
        StimulationProperties{f1,6}=NaN;
    elseif mean(STIM1A)>max(STIM1A)*0.75
        StimulationProperties{f1,8}='constant';
        StimulationProperties{f1,6}=NaN;
    else        
        indexCross=find(diff(STIM1A>median(STIM1A)));
        indexCross=indexCross([diff(indexCross)>fs/200 true]);
        if length(indexCross)<=3
            StimulationProperties{f1,8}='undefined';
            StimulationProperties{f1,6}=NaN;
        elseif (indexCross(end-1)-indexCross(end-2))>=(indexCross(2)-indexCross(1))*0.75
            StimulationProperties{f1,8}='sinus';
            StimulationProperties{f1,6}=ceil(fs/(mean(diff(indexCross)))*0.5-0.2);
        elseif (indexCross(end-1)-indexCross(end-2))<(indexCross(2)-indexCross(1))*0.75
            StimulationProperties{f1,8}='chirp';
            StimulationProperties{f1,6}=[floor(fs/(indexCross(2)-indexCross(1))*0.5-1.0) ceil(fs/(indexCross(end-1)-indexCross(end-2))*0.5-0.1)];
        else
            StimulationProperties{f1,8}='undefined';
            StimulationProperties{f1,6}=NaN;
        end
    end
    clear STIM1A
end

%% Detect baseline periods >= 15 min start+30s and end-30s
STIM1startPeriods=[STIM1startPeriods length(time)];
STIM1endPeriods=[1 STIM1endPeriods];

BaselineStart=time(STIM1endPeriods((STIM1startPeriods-STIM1endPeriods)>=15*60*fs))'; %BaselineStart
BaselineEnd=time(STIM1startPeriods((STIM1startPeriods-STIM1endPeriods)>=15*60*fs))'; %BaselineEnd

BaselineStartSample=STIM1endPeriods((STIM1startPeriods-STIM1endPeriods)>=15*60*fs)'; %BaselineStart
BaselineEndSample=STIM1startPeriods((STIM1startPeriods-STIM1endPeriods)>=15*60*fs)'; %BaselineEnd

if ~isempty(BaselineStart)
    BaselinePeriods=num2cell([BaselineStart(1)+30*10^3 BaselineEnd(1)-30*10^3 (BaselineEnd(1)-BaselineStart(1))*10^-3/60 BaselineStartSample(1)+fs*0.5 BaselineEndSample(1)-fs*0.5 (BaselineEndSample(1)-BaselineStartSample(1)) fs]);
else
    BaselinePeriods=num2cell(NaN(1,7));
    disp('No baseline period')
end