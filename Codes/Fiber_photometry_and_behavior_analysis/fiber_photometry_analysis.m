%==========================================================================
% Script: controller.m
%
% This script calculates indices and draw plots of fiber photometry
% Before running this script, add the "src" folder to the matlab path.
% All results will be output to the "analysedata" folder which is under the
% individual folder (see below).
%
% Inputs:
% 1. datapath: the path where the data is stored. Note that the folder should
% be arranged on a structured format. in specific, under the datapath,
% there is a folder named "rawdata" which contains the folder of each
% individual (named YYYY_MM_DD, ie, 2024_01_01_WHY0001). Under each
% individual folder, a file named "signal.csv" is the fluorescence value
% file recorded by the fiber photometry (there are two channels recording
% the 470nm and 405nm fluorescence values). The other file named
% "signal-Event.csv" is the event marked timestamps value (0 or 1).

% 2. subject_label: This is the name of the folder where the individual data
% is stored (i.e.,individual folder that named YYYY_MM_DD as mentioned
% above).

% 3. rawSignalFile: A file in csv format that records the fluorescence
% values (including the fluorescence values of two independent channels of
% 470nm and 405nm), with its file name provided here (such as signal.csv).

% 4. rawEventFile: A file in csv format that records the event marked
% timestamps value (0 or 1), with its file name provided here
% (such as signal-Event.csv).

% 5. event_epoch_length: Specify a length of time for data analysis after
% the stimulus is given - such as 1800 seconds (enter 1800) or full length
% (enter "all").

% f470Channel, f405Channel: specify the channel numbers of f470 and f405
% from your "rawSignalFile" (f470 and f405 fluorescent time series should
% come from the same file, but located in the different channels.

% 6. eventChannel: specify the channel number of your "rawEventFile"

% 6. ylow, yhigh: the display range of Y-axis coordinates when drawing.

% stimStart: The moment at which the stimulus period began of the experiment

% stimTypeName: (1) random model (such as lick behavior): input 'random;
% (2) paired model (Artificially given stimuli, each of which has a paired
% start and end timestamps), input 'paired';
% (3) continuous model (Artificially given continuous stimuli), input
% 'continuous'.

% 7. preTime_DFF, postTime_DFF: Specifies the time before and after the
% "stimStart" when calculating DF/F.

% 7. preTime_PSTH, postTime_PSTH: Specifies the time before and after the
% stimulus moment (time 0) when calculating PSTH.

% 8. frameRate_event: the frame rate of the event data
% (i.e. event marked timestamps)

% 9. frameRateEvent_down: Factor for downsampling event data

% 10. Lick bout related parameters:
% (1) lengthThreshold: the minimum duration of a bout (need to be greater
% than this to become a lick bout)
% (2) LickIntervalwithinABout_thr: the minimum interval between two
% consecutive licks (need to be less than this to become a lick bout).
% (3) intervalThreshold: The minimum time between two consecutive lick
% bouts (to exclude the latter bout from being affected by the lasting
% response of the previous bout)
% (4) selectBout: Specifies whether to analyze specific lick bouts. If yes,
% enter a specific value such as "[1:5]"; otherwise, enter "no".
% (5) labelBout: Whether to highlight the time period of every lick bout in
% the entire drawn fluorescence trace.
% (6) patch_bout_in_psth: Whether to draw the duration of the bout
% (patch with a color) when drawing the PSTH image. if so, please give a
% patch time length (on the "patch_width" parameter).


clc; clear; close all
%% inputs (the following is for examples),
datapath = 'G:\WHY_all';
subject_label = '2024_01_01_WHY0001'; % format: YYYY_MM_DD_xxxxxxx
rawSignalFile = 'signal.csv';
rawEventsFile = 'signal-Event.csv';
f470Channel = 1;
f405Channel = 3;
eventChannel = 1;
stimTypeName = 'random'; % or "paired" or "continuous"
stimStart = 500; % the unit is second
frameRate_event = 1000;
frameRateEvent_down = 15;
event_epoch_length = 1800; % a number (the unit is second) or 'all'
ylow = -30; yhigh =100;
preTime_DFF = -600; postTime_DFF = 1800; % the unit is second
preTime_PSTH = -100; postTime_PSTH = 100; % the unit is second
% lick bout related
lengthThreshold=3; % the unit is second
LickIntervalwithinABout_thr=3; % the unit is second
intervalThreshold=20; % the unit is second
selectBout = no; % e.g. [1:5]
labelBout = 'no';
patch_bout_in_psth = 'no'; patch_width = 10; % the unit is second

%% default parameters
fitControl = true; % whether to fit the control signal before the stimuli start.
fitBase = true; % Whether to use the baseline periods of 470nm and 405nm
baseTh = 3.0; minTh = -0.01;
windowLength = 120; % Time window for data smoothing during data fitting
manualCSY = [ylow,yhigh]; % ylim of overall corrected signal plotting.
manualPSTHX = [ylow,yhigh]; % manualPSTHX: The manual setting of the xlim of PSTH.
manualDFFY = [ylow,yhigh]; % manualDFFY: The manual setting of the ylim of dff.
showErr = true; % showErr: whether to show error bar. example: "true" or "false".
timeScale = "m"; % timeScale: The time scale to be plotted. "s" means
% second as a unit; "m" means minute as a unit; "h" means hour as a unit.


%%----------------------------------Main----------------------------------
% headfile = importdata([datapath,filesep,'headfile.xlsx']);
cd(datapath); if ~exist('analysedata','file'); mkdir('analysedata');end
% if ~exist('composite','file'); mkdir('composite');end
cd('analysedata')
rawdatapath = [datapath,filesep,'rawdata'];
outputpath = [datapath,filesep,'analysedata',subject_label];
filepath = [rawdatapath, filesep, subject_label];
stimTypeName = headfile.textdata{Nsub,3};
tmp=max(strfind(subject_label,'_'));
date = subject_label(1:tmp-1);
mouseID = subject_label(tmp+1:end);

%% downsample data
downsampled = downsample_data(filepath,rawEventsFile,frameRate_event,frameRateEvent_down);

%% import fluorescence data
downEventsFile = 'signal-Event_FR_15.csv';
rawSignalFilePath = append(filepath,filesep,rawSignalFile);
downEventsFilePath = append(filepath,filesep,downEventsFile);
rawEventsFilePath = append(filepath,filesep,rawEventsFile);
rawSignal = readtable(rawSignalFilePath);
downEvents = readtable(downEventsFilePath);
eventCal = rawSignal(:,f470Channel);
baseline = rawSignal(:,f405Channel);

%% Read event data,in case of no event channel (such as i.p.), all event elements are set to 0.
if eventChannel == 0
    events = array2table(zeros(size(downEvents,1),1));
else
    events = downEvents(:,eventChannel);
end
clear rawSignal downEvents;

if ~strcmp(rawEventsFile,downEventsFile)
    accurateEvents = readtable(rawEventsFilePath);
    if width(accurateEvents) < eventChannel
        msg = "Error occured! The accurate event file size does match the assigned channel! " + newline + " Reported by controller.m";
        error(msg);
    end
    if eventChannel ~= 0
        accurateEvents = accurateEvents(:,eventChannel);
    end
else
    accurateEvents = events;
end

if eventChannel == 0
    accurateEvents = array2table(zeros(size(accurateEvents,1),1));
end

eventCalArr = table2array(eventCal);
baselineArr = table2array(baseline);
eventsArr = table2array(events);
accEvArr = table2array(accurateEvents);

% Calculate the sampling rate of the fluorescence data of each individual
frameRateSignal = length(baselineArr) * frameRate_event / length(accEvArr);

%%
whole_lenth_data = length(accEvArr)/1000; disp(['The whole length of the data is ', num2str(round(whole_lenth_data)), ' seconds'])
whole_lenth_event = whole_lenth_data - stimStart;  disp(['The whole length of the event epoch is ', num2str(round(whole_lenth_event)), ' seconds'])

startTime = stimStart+preTime_DFF; % startTime: The time of the start of the experiment.
if strcmp(event_epoch_length,'all')
    stimEnd = whole_lenth_data;
else
    stimEnd = stimStart + event_epoch_length; % stimEnd: The end time of stimulation.
end

%% Calculate the DF/F value by fitting 470 channels and 405 channels
[correctedSignal, controlSignal, dffSignal, meanIntensity, stdIntensity] = apply_correction(baselineArr(round(startTime*frameRateSignal):round(stimEnd*frameRateSignal)), ...
    eventCalArr(round(startTime*frameRateSignal):round(stimEnd*frameRateSignal)), frameRateSignal, fitControl, stimStart-startTime, fitBase, baseTh, minTh, windowLength, true);
%% baseline moved to y=0 level
len_base = round(abs(preTime_DFF)*frameRateSignal);
base = dffSignal(1:len_base);
ave_base = mean(base);
dffSignal_cor = dffSignal - ave_base;


%% plot draft (preview before calculate bout and its related PSTH)
figure('color',[1 1 1]); t=tiledlayout(2,3,'TileSpacing','tight','Padding','tight');
nexttile(4);
plot_cal_and_events(mouseID, date, stimTypeName,eventCalArr, baselineArr, frameRateSignal, eventsArr, frameRateEvent_down, 0, length(baselineArr)/frameRateSignal, false, false, timeScale);
xlabel('Time (min)'); ylabel('Fluorescence'); title('Overview');
nexttile([1 3])
plot_cal_and_events(mouseID, date_format(date), stimTypeName,dffSignal_cor*100, false, frameRateSignal, eventsArr(round(startTime*15):round(stimEnd*15)), frameRateEvent_down, startTime-stimStart, stimEnd-stimStart, manualCSY, false, timeScale);
ylabel('DF/F');
line([-10 stimEnd/60],[0 0],'color','k'); grid on; xlabel('Time (min)');title('')

%% Get the time when the stimulus starts and ends
% random model (such as lick behavior)
if strcmp(stimTypeName,'random')
    [boutStartSec, boutEndSec, meanLRBout, consumptionBout, lickStartToEnd_sec] = lickMode_get_lick_bouts(accEvArr, frameRate_event, startTime, stimStart, stimEnd,intervalThreshold, lengthThreshold, LickIntervalwithinABout_thr);
    % paired model (Artificially given stimuli, each of which has a paired start and end timestamps)
elseif strcmp(stimTypeName,'paired')
    [boutStartSec, boutEndSec] =  og_get_lick_bouts(accEvArr, frameRate_event, startTime, stimStart, stimEnd);
    meanLRBout = nan; consumptionBout =nan;
    % continuous model (Artificially given continuous stimuli)
elseif strcmp(stimTypeName,'continuous')
    [boutStartSec, boutEndSec, meanLRBout, consumptionBout,diffEvents] = get_lick_bouts(accEvArr, frameRate_event, startTime, stimStart, stimEnd);
    meanLRBout = nan; consumptionBout =nan;
end

if isnumeric(selectBout)
    boutStartSec = boutStartSec(selectBout);
    boutEndSec   = boutEndSec(selectBout);
end

if exist('boutEndSec','var')
    boutDuration = boutEndSec - boutStartSec;
    lickPerBout = meanLRBout .* boutDuration;
end

if ~isempty(boutStartSec) && length(boutStartSec)>1
    boutPeakSec = get_peak_per_bout(frameRateSignal, boutStartSec, boutEndSec, smoothdata(dffSignal, "gaussian", 300));
    [meanBoutDFF, maxBoutDFF, halfwayTimeBoutDFF] = get_bout_stats(smoothdata(dffSignal, "gaussian", 300), frameRateSignal, boutStartSec, boutEndSec, startTime, stimStart, stimEnd);

    %% calculate PSTH
    [startPSTH,meanStartPSTH, errStartPSTH] = get_PSTH(boutStartSec, dffSignal, frameRateSignal, preTime_PSTH, postTime_PSTH, false); %------added
    [endPSTH, meanEndPSTH, errEndPSTH] = get_PSTH(boutEndSec, dffSignal, frameRateSignal, preTime_PSTH, postTime_PSTH, false); %------added
    fprintf(['bout number = ',num2str(size(startPSTH,1)),'\n']);

    % Baseline correction of PSTH for all individual stimuli
    len_baseSec = preTime_PSTH;
    len_base = abs(round(preTime_PSTH*frameRateSignal));
    base = startPSTH(:,1:len_base);
    ave_base = mean(base,2);
    startPSTH_cor = startPSTH - ave_base;

    % baseline correction for PSTH
    base = meanStartPSTH(1:len_base);
    ave_base = mean(base);
    meanStartPSTH_cor = meanStartPSTH - ave_base;
end


%% Graphs plotting process------------------
close
figure('color',[1 1 1]); t=tiledlayout(2,3,'TileSpacing','tight','Padding','tight');

nexttile(4);
plot_cal_and_events(mouseID, date, stimTypeName,eventCalArr, baselineArr, frameRateSignal, eventsArr, frameRateEvent_down, 0, length(baselineArr)/frameRateSignal, false, false, timeScale);
xlabel('Time (min)'); ylabel('Fluorescence'); title('Overview');

if strcmp(stimTypeName,'paired')
    for i=1:length(boutStartSec)
        A = (boutStartSec+preTime_DFF)/60;
        B = (boutEndSec+preTime_DFF)/60;
        patch([A(i),B(i),B(i),A(i)],[ylow,ylow,yhigh,yhigh],[251 231 161]/255,'FaceAlpha',0.5, 'EdgeColor','none');
    end
end

nexttile([1 3])
plot_cal_and_events(mouseID, date_format(date), stimTypeName,dffSignal_cor*100, false, frameRateSignal, eventsArr(round(startTime*15):round(stimEnd*15)), frameRateEvent_down, startTime-stimStart, stimEnd-stimStart, manualCSY, false, timeScale);
ylabel('DF/F');
line([-10 30],[0 0],'color','k'); grid on; xlabel('Time (min)');title('')


%% plot first lick bout (please set parameter of "intervalThreshold" with a low value)
if strcmp(labelBout,'yes')
    if ~isempty(boutStartSec)
        boutStartMinute = boutStartSec/60-10+(1/60);
        boutEndMinute = boutEndSec/60-10+(1/60);
    end
    if ~isempty(boutStartSec)
        for i = 1:length(boutStartMinute)
            line([boutStartMinute(i) boutStartMinute(i)],[-20 100],'color','g');
            line([boutEndMinute(i) boutEndMinute(i)],[-20 100],'color','g');
        end
    end
end

%% plot PSTH map
if ~strcmp(stimTypeName,'continuous')
    n_bout = length(boutStartSec);
    if n_bout > 1
        nexttile(6)
        plot_dff(mouseID, date_format(date),stimTypeName, meanStartPSTH_cor, frameRateSignal, preTime_PSTH, postTime_PSTH, "lick bout starts",manualPSTHX, manualDFFY, apply_errbar(showErr, errStartPSTH), 's');
        xlabel('Time (s)'); ylabel('DF/F (%)'); title('Averaged PSTH'); grid on %--------------------------------------added
        xlim([preTime_PSTH postTime_PSTH]);
        if strcmp(patch_bout_in_psth,'yes'); patch([0 patch_width patch_width 0],[ylow ylow yhigh yhigh],'k','facealpha',0.1,'edgecolor','none'); end
        nexttile(5)
        startHMapPSTH = imagesc([preTime_PSTH, postTime_PSTH], [1, size(startPSTH_cor, 1)], startPSTH_cor);colormap(hot);colorbar;title(['Bout start DFF heatmap of ',' ',date_format(date),' ',stimTypeName]);
        xlim([preTime_PSTH postTime_PSTH]);
        axis square; xlabel('Time (s)'); ylabel('Bout #'); title('PSTH of each bout')
    end
end
title_name = [num2str(Nsub),'_',genotype, ', ', stimTypeName, ': ', date_subj_name,];

if exist('note','var')
    title(t,{title_name,note},'interpreter','none','fontsize',8)
else
    title(t,title_name,'interpreter','none','fontsize',8)
end

outputname = [date_subj_name, '_', genotype, '_', stimTypeName];
saveas(gca,[outputpath,filesep,outputname,'.jpeg']);

cd(outputpath)
if ~exist(outputpath,'file');mkdir(outputpath);end

if strcmp(labelBout,'yes')
    if ~isempty(boutStartSec)
        boutStartMinute = boutStartSec/60-10+(1/60);
        boutEndMinute = boutEndSec/60-10+(1/60);
    end
    if ~isempty(boutStartSec)
        for i = 1:length(boutStartMinute)
            line([boutStartMinute(i) boutStartMinute(i)],[-20 100],'color','g');
            line([boutEndMinute(i) boutEndMinute(i)],[-20 100],'color','g');
        end
    end
end
saveas(gca,[outputpath,filesep,'DFF_',outputname,'.pdf']);
saveas(gca,[outputpath,filesep,'DFF_',outputname,'.jpeg']);


cd(outputpath)
save('dffSignal.mat','dffSignal')
if exist('startPSTH','var'); save('startPSTH.mat','startPSTH');save('endPSTH.mat','endPSTH');end
if exist('boutStartSec','var'); save('boutStartSec.mat','boutStartSec'); save('boutEndSec.mat','boutEndSec'); end




