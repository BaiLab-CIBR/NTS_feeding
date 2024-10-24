function account_trials_data(folder, mouseListFile, boutCounted, manualPSTHX, manualDFFY, manualZY, showAllErr, showPSTHErr, timeScale, skipPlot)
% "test", "test.txt", [1 2 3 4 -4 -3 -2 -1], false, false, false, true, true
% Account the data of multiple mice.
% folder: The folder containing the config file and results.
% mouseListFile: The config file containing mice to be taken into account.
% manualPSTHX: The manual setting of the xlim of PSTH. example: "false" by default, [minX, maxX] by setting.
% manualDFFY: The manual setting of the ylim of dff. example: "false" by default, [minX, maxX] by setting.
% manualZY: The manual setting of the ylim of zscore. example: "false" by default, [minX, maxX] by setting.
% showAllErr: whether to show error bar of overall average plotting. example: "true" or "false".
% showPSTHErr: whether to show error bar of PSTH average plotting. example: "true" or "false".
% skipPlot: Whether to skip plotting.
    function check_and_create(str)
        if exist(str, "dir") == 0
            mkdir(str);
        end
    end
check_and_create("metadata/"+folder+"/fig/");
check_and_create("metadata/"+folder+"/eps/");
check_and_create("metadata/"+folder+"/png/");
%% Check the data validity and read the data
"metadata/"+folder+"/"+mouseListFile
if exist("metadata/"+folder+"/"+mouseListFile, "file") == 0
    msg = "Error occured! The mouse list file does not exist!" + newline + " Reported by account_trials_data.m";
    error(msg);
end
file = fopen("metadata/"+folder+"/"+mouseListFile, 'r');
mouseList = {};
while ~feof(file)
    mouseList(end+1) = {fgetl(file)};
end
mouseList = string(mouseList);
for iter = 1:length(mouseList)
    if exist("analysedata/"+mouseList(iter), "file") == false
        msg = "Error occured! The mouse data file does not exist!" + newline + " Reported by account_trials_data.m";
    error(msg);
    end
end
%% Account all data listed
mouseDataList = {};
for iter = 1:length(mouseList)
    mouseDataList(end+1) = {load("analysedata/"+mouseList(iter))};
end
csvRow = cellstr(mouseList)';
preStart = -1000000;
postStart = 1000000;
frameRate = 0;
numMice = length(mouseDataList);
lenSignal = zeros([numMice, 1]);
lenPSTH = zeros([numMice, 1]);
meanIntensity = 0;
stdIntensity = 0;
prePSTH = -1000000;
postPSTH = 1000000;
% Get the time course aligned at the time where stimuli available
% combDFF = [];
for iter = 1:numMice
    % mouseData = mouseDataList{iter};
    frameRate = frameRate + mouseDataList{iter}.frameRateSignal;
    preStart = max(preStart, mouseDataList{iter}.startTime-mouseDataList{iter}.stimStart);
    postStart = min(postStart, mouseDataList{iter}.stimEnd-mouseDataList{iter}.stimStart);
    lenSignal(iter) = length(mouseDataList{iter}.correctedSignal);
    lenPSTH(iter) = length(mouseDataList{iter}.meanStartPSTH);
    meanIntensity = meanIntensity + mouseDataList{iter}.meanIntensity;
    prePSTH = max(prePSTH, mouseDataList{iter}.preTime);
    postPSTH = min(postPSTH, mouseDataList{iter}.postTime);
    % combDFF = [combDFF; mouseDataList{iter}.dffSignal];
end
frameRate = frameRate / numMice;
% stdIntensity = std(combDFF);
% clear combDFF;

%% overall average signal (DFF and Z)
lenMeanDFF = round((postStart-preStart)*frameRate);
meanDFF = zeros([lenMeanDFF, 1]);
meanZ = zeros([lenMeanDFF, 1]);
errMeanDFF = zeros([lenMeanDFF, 1]);
errZ = zeros([lenMeanDFF, 1]);
tmp1 = zeros([numMice, 1]); % for dff
tmp2 = zeros([numMice, 1]); % for z-score
tmp3 = zeros([numMice, 1]); % for dff
tmp4 = zeros([numMice, 1]); % for z-score
for timePoint = 1:lenMeanDFF
    for iter = 1:numMice
        location = min( lenSignal(iter), max(1, round( mouseDataList{iter}.frameRateSignal * ((timePoint-1)/frameRate+(mouseDataList{iter}.stimStart+preStart-mouseDataList{iter}.startTime)) )));
        tmp1(iter) = mouseDataList{iter}.dffSignal(location);
        tmp2(iter) = (mouseDataList{iter}.dffSignal(location) - mouseDataList{iter}.meanIntensity) / mouseDataList{iter}.stdIntensity;
        %if tmp1(iter) > 100
        %    timePoint
        %    location
        %    mouseDataList{iter}.dffSignal(location)
        %end
        %timePoint
        %(mouseDataList{iter}.frameRateSignal * ((timePoint-1)/frameRate+(mouseDataList{iter}.stimStart+preStart)) )
    end
    meanDFF(timePoint) = mean(tmp1);
    errMeanDFF(timePoint) = std(tmp1) / (numMice-1)^0.5;
    meanZ(timePoint) = mean(tmp2);
    errZ(timePoint) = std(tmp2) / (numMice-1)^0.5;
end

stdIntensity = std(meanDFF(1:round(-preStart*frameRate)));

%% PSTH (DFF and Z)
lenMeanPSTH = round((postPSTH - prePSTH)*frameRate);
meanStartDFF = zeros([numMice+1, lenMeanPSTH]);
errStartDFF = zeros([1, lenMeanPSTH]);
meanEndDFF = zeros([numMice+1, lenMeanPSTH]);
errEndDFF = zeros([1, lenMeanPSTH]);
meanStartZ = zeros([numMice+1, lenMeanPSTH]);
errStartZ = zeros([1, lenMeanPSTH]);
meanEndZ = zeros([numMice+1, lenMeanPSTH]);
errEndZ = zeros([1, lenMeanPSTH]);
for timePoint = 1:lenMeanPSTH
    for iter = 1:numMice
        location = min(lenPSTH(iter), max(1, round( mouseDataList{iter}.frameRateSignal * ((timePoint-1)/frameRate+(prePSTH-mouseDataList{iter}.preTime)) )));
        meanStartDFF(iter, timePoint) = mouseDataList{iter}.meanStartPSTH(location);
        meanStartZ(iter, timePoint) = (mouseDataList{iter}.meanStartPSTH(location) - mouseDataList{iter}.meanIntensity) / mouseDataList{iter}.stdIntensity;
        meanEndDFF(iter, timePoint) = mouseDataList{iter}.meanEndPSTH(location);
        meanEndZ(iter, timePoint) = (mouseDataList{iter}.meanEndPSTH(location) - mouseDataList{iter}.meanIntensity) / mouseDataList{iter}.stdIntensity;
    end
    meanStartDFF(end, timePoint) = mean(meanStartDFF(1:end-1,timePoint));
    errStartDFF(1, timePoint) = std(meanStartDFF(1:end-1,timePoint)) / (numMice-1)^0.5;
    meanStartZ(end, timePoint) = mean(meanStartZ(1:end-1,timePoint));
    errStartZ(1, timePoint) = std(meanStartZ(1:end-1,timePoint)) / (numMice-1)^0.5;
    meanEndDFF(end, timePoint) = mean(meanEndDFF(1:end-1,timePoint));
    errEndDFF(1, timePoint) = std(meanEndDFF(1:end-1,timePoint)) / (numMice-1)^0.5;
    meanEndZ(end, timePoint) = mean(meanEndZ(1:end-1,timePoint));
    errEndZ(1, timePoint) = std(meanEndZ(1:end-1,timePoint)) / (numMice-1)^0.5;
end
size([meanStartDFF; errStartDFF])
size([csvRow; 'mean'; 'std'])
startDFFTable = array2table([meanStartDFF; errStartDFF], "RowNames", [csvRow; 'mean'; 'std'], "VariableNames", string((1:lenMeanPSTH)/frameRate+prePSTH));
writetable(startDFFTable, "metadata/"+folder+"/startDFF.csv", "WriteRowNames", true);
startZTable = array2table([meanStartZ; errStartZ], "RowNames", [csvRow; 'mean'; 'std'], "VariableNames", string((1:lenMeanPSTH)/frameRate+prePSTH));
writetable(startZTable, "metadata/"+folder+"/startZ.csv", "WriteRowNames", true);
endDFFTable = array2table([meanEndDFF; errEndDFF], "RowNames", [csvRow; 'mean'; 'std'], "VariableNames", string((1:lenMeanPSTH)/frameRate+prePSTH));
writetable(endDFFTable, "metadata/"+folder+"/endDFF.csv", "WriteRowNames", true);
endZTable = array2table([meanEndZ; errEndZ], "RowNames", [csvRow; 'mean'; 'std'], "VariableNames", string((1:lenMeanPSTH)/frameRate+prePSTH));
writetable(endZTable, "metadata/"+folder+"/endZ.csv", "WriteRowNames", true);
%clear tmp4;

%% bout counted
lenBC = length(boutCounted);
meanBCDFF = zeros([lenBC 1]);
errBCDFF = zeros([lenBC 1]);
meanBCLR = zeros([lenBC 1]);
errBCLR = zeros([lenBC 1]);
meanBCMaxDFF = zeros([lenBC 1]);
errBCMaxDFF = zeros([lenBC 1]);
for trial = 1:lenBC
    for iter = 1:numMice
        if abs(boutCounted(trial)) > length(mouseDataList{iter}.meanBoutDFF)
            error("The assigned bout " + num2str(boutCounted(trial)) + " is out of the range " + num2str(length(mouseDataList{iter}.meanBoutDFF)) + " of " + mouseList{iter} + newline + " Reported by account_mice_data.m");
        end
        if boutCounted(trial) > 0
            tmp1(iter) = mouseDataList{iter}.meanBoutDFF(boutCounted(trial));
            tmp2(iter) = mouseDataList{iter}.meanLRBout(boutCounted(trial));
            tmp3(iter) = mouseDataList{iter}.maxBoutDFF(boutCounted(trial));
        else
            tmp1(iter) = mouseDataList{iter}.meanBoutDFF(end+boutCounted(trial));
            tmp2(iter) = mouseDataList{iter}.meanLRBout(end+boutCounted(trial));
            tmp3(iter) = mouseDataList{iter}.maxBoutDFF(end+boutCounted(trial));
        end
    end
    meanBCDFF(trial) = mean(tmp1);
    errBCDFF(trial) = std(tmp1) / (numMice-1)^0.5;
    meanBCLR(trial) = mean(tmp2);
    errBCLR(trial) = std(tmp2) / (numMice-1)^0.5;
    meanBCMaxDFF(trial) = mean(tmp3);
    errBCMaxDFF(trial) = std(tmp3) / (numMice-1)^0.5;
end
clear tmp1;
clear tmp2;
clear tmp3;
%% all bout
meanBoutDFF = zeros([numMice+1 1]);
errBoutDFF = zeros([numMice+1 1]);
meanBoutLR = zeros([numMice+1 1]);
errBoutLR = zeros([numMice+1 1]);
meanBoutMaxDFF = zeros([numMice+1 1]);
errBoutMaxDFF = zeros([numMice+1 1]);
meanBoutDuration = zeros([numMice+1 1]);
errBoutDuration = zeros([numMice+1 1]);
for iter = 1:numMice
    meanBoutDFF(iter) = mean(mouseDataList{iter}.meanBoutDFF);
    errBoutDFF(iter) = std(mouseDataList{iter}.meanBoutDFF);
    meanBoutLR(iter) = mean(mouseDataList{iter}.meanLRBout);
    errBoutLR(iter) = std(mouseDataList{iter}.meanLRBout);
    meanBoutMaxDFF(iter) = mean(mouseDataList{iter}.maxBoutDFF);
    errBoutMaxDFF(iter) = std(mouseDataList{iter}.maxBoutDFF);
    meanBoutDuration(iter) = mean(mouseDataList{iter}.boutEndSec-mouseDataList{iter}.boutStartSec);
    errBoutDuration(iter) = std(mouseDataList{iter}.boutEndSec-mouseDataList{iter}.boutStartSec);
end
meanBoutDFF(end) = mean(meanBoutDFF(1:end-1));
meanBoutLR(end) = mean(meanBoutLR(1:end-1));
meanBoutMaxDFF(end) = mean(meanBoutMaxDFF(1:end-1));
errBoutDFF(end) = mean(meanBoutDFF(1:end-1));
errBoutLR(end) = mean(meanBoutLR(1:end-1));
errBoutMaxDFF(end) = mean(meanBoutMaxDFF(1:end-1));
meanBoutDuration(end) = mean(meanBoutDuration(1:end-1));
errBoutDuration(end) = std(meanBoutDuration(1:end-1));
boutTable = table(meanBoutDFF, errBoutDFF, meanBoutLR, errBoutLR, meanBoutMaxDFF, errBoutMaxDFF, meanBoutDuration, errBoutDuration, 'RowNames', [csvRow; "mean"]);
writetable(boutTable, "metadata/"+folder+"/bouts.csv", "WriteRowNames", true);

peakStartDFF = max(meanStartDFF);
peakEndDFF = max(meanEndDFF);
peakStartZ = max(meanStartZ);
peakEndZ = max(meanEndZ);
aveStartDFF = mean(meanStartDFF);
aveEndDFF = mean(meanEndDFF);
aveStartZ = mean(meanStartZ);
aveEndZ = mean(meanEndZ);
save("metadata/"+folder+"/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_stats.mat", ...
    "frameRate", "preStart", "postStart", "meanDFF", "meanZ", "meanIntensity", "stdIntensity", ...
    "meanBCDFF", "meanBCLR", "meanBCMaxDFF", "prePSTH", "postPSTH", ...
    "meanBoutDFF", "meanBoutLR", "meanBoutMaxDFF", "meanBoutDuration", ...
    "peakStartDFF", "peakEndDFF", "peakStartZ", "peakEndZ", "aveStartDFF", "aveEndDFF", "aveStartZ", "aveEndZ");
 
%% Plottings
if skipPlot == true
    return
end
% meanZ = (meanDFF - mean(meanDFF)) / std(meanDFF);
%mouseDataList{1}.frameRateSignal * ((lenMeanDFF-1)/frameRate+(mouseDataList{1}.stimStart+preStart))
%mouseDataList{2}.frameRateSignal * ((lenMeanDFF-2)/frameRate+(mouseDataList{2}.stimStart+preStart))
%disp('finished!');
aveDFFPlotting = plot_overall_dff(folder, '', meanDFF, frameRate, preStart, postStart, manualDFFY, apply_errbar(showAllErr, errMeanDFF), timeScale);
saveas(aveDFFPlotting, "metadata/"+folder+"/fig/"+"average_DFF.fig");
exportgraphics(aveDFFPlotting, "metadata/"+folder+"/eps/"+"average_DFF.eps", "ContentType", "vector");
exportgraphics(aveDFFPlotting, "metadata/"+folder+"/png/"+"average_DFF.png", "Resolution", 1200);
aveZPlotting = plot_overall_zscore(folder, '', meanZ, frameRate, preStart, postStart, manualZY, apply_errbar(showAllErr, errZ), timeScale);
saveas(aveZPlotting, "metadata/"+folder+"/fig/"+"average_Z.fig");
exportgraphics(aveZPlotting, "metadata/"+folder+"/eps/"+"average_Z.eps", "ContentType", "vector");
exportgraphics(aveZPlotting, "metadata/"+folder+"/png/"+"average_Z.png", "Resolution", 1200);
clear aveDFFPlotting;
clear aveZPlotting;

% plot PSTH with dff and z-score
startDFFPlotting = plot_dff(folder, '', meanStartDFF(end,:), frameRate, prePSTH, postPSTH, manualPSTHX, manualDFFY, apply_errbar(showPSTHErr, errStartDFF), timeScale);
endDFFPlotting = plot_dff(folder, '', meanEndDFF(end,:), frameRate, prePSTH, postPSTH, manualPSTHX, manualDFFY, apply_errbar(showPSTHErr, errEndDFF), timeScale);
saveas(startDFFPlotting, "metadata/"+folder+"/fig/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_DFF_bout_start.fig");
exportgraphics(startDFFPlotting, "metadata/"+folder+"/eps/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_DFF_bout_start.eps", "ContentType", "vector");
exportgraphics(startDFFPlotting, "metadata/"+folder+"/png/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_DFF_bout_start.png", "Resolution", 1200);
saveas(endDFFPlotting, "metadata/"+folder+"/fig/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_DFF_bout_end.fig");
exportgraphics(endDFFPlotting, "metadata/"+folder+"/eps/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_DFF_bout_end.eps", "ContentType", "vector");
exportgraphics(endDFFPlotting, "metadata/"+folder+"/png/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_DFF_bout_end.png", "Resolution", 1200);
clear startDFFPlotting;
clear endDFFPlotting;
startZPlotting = plot_z_score(folder, '', meanStartZ(end,:), frameRate, prePSTH, postPSTH, manualPSTHX, manualDFFY, apply_errbar(showPSTHErr, errStartZ), timeScale);
endZPlotting = plot_z_score(folder, '', meanEndZ(end,:), frameRate, prePSTH, postPSTH, manualPSTHX, manualDFFY, apply_errbar(showPSTHErr, errEndZ), timeScale);
saveas(startZPlotting, "metadata/"+folder+"/fig/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_Z_bout_start.fig");
exportgraphics(startZPlotting, "metadata/"+folder+"/eps/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_Z_bout_start.eps", "ContentType", "vector");
exportgraphics(startZPlotting, "metadata/"+folder+"/png/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_Z_bout_start.png", "Resolution", 1200);
saveas(endZPlotting, "metadata/"+folder+"/fig/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_Z_bout_end.fig");
exportgraphics(endZPlotting, "metadata/"+folder+"/eps/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_Z_bout_end.eps", "ContentType", "vector");
exportgraphics(endZPlotting, "metadata/"+folder+"/png/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_Z_bout_end.png", "Resolution", 1200);
clear startDFFPlotting;
clear endDFFPlotting;

boutDFFPlotting = plot_bout_stats("Averaged DFF of " +folder+ " in each trial", "Delta F/F (%)", meanBCDFF*100, errBCDFF*100);
saveas(boutDFFPlotting, "metadata/"+folder+"/fig/"+"DFF_in_bouts.fig");
exportgraphics(boutDFFPlotting, "metadata/"+folder+"/eps/"+"DFF_in_bouts.eps", "ContentType", "vector");
exportgraphics(boutDFFPlotting, "metadata/"+folder+"/png/"+"DFF_in_bouts.png", "Resolution", 1200);
clear boutDFFPlotting;
boutLRPlotting = plot_bout_stats("Averaged lick rate of " +folder+ " in each trial", "lick rate (lick number per second)", meanBCLR, errBCLR);
saveas(boutLRPlotting, "metadata/"+folder+"/fig/"+"lick_rate_in_bouts.fig");
exportgraphics(boutLRPlotting, "metadata/"+folder+"/eps/"+"lick_rate_in_bouts.eps", "ContentType", "vector");
exportgraphics(boutLRPlotting, "metadata/"+folder+"/png/"+"lick_rate_in_bouts.png", "Resolution", 1200);
clear boutLRPlotting;
boutMaxDFFPlotting = plot_bout_stats("Max DFF of " +folder+ " in each trial", "Delta F/F (%)", meanBCMaxDFF*100, errBCMaxDFF*100);
saveas(boutMaxDFFPlotting, "metadata/"+folder+"/fig/"+"max_DFF_in_bouts.fig");
exportgraphics(boutMaxDFFPlotting, "metadata/"+folder+"/eps/"+"max_DFF_in_bouts.eps", "ContentType", "vector");
exportgraphics(boutMaxDFFPlotting, "metadata/"+folder+"/png/"+"max_DFF_in_bouts.png", "Resolution", 1200);
clear boutMaxDFFPlotting;

end