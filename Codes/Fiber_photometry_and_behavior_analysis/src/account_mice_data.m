function account_mice_data(folder, mouseListFile, boutCounted, manualPSTHX, manualDFFY, manualZY, showAllErr, showPSTHErr, timeScale, skipPlot)
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
            mkdir(str)
        end
    end
check_and_create("statsdata/"+folder+"/fig/");
check_and_create("statsdata/"+folder+"/eps/");
check_and_create("statsdata/"+folder+"/png/");
%% Check the data validity and read the data
%"statsdata/"+folder+"/"+mouseListFile
if exist("statsdata/"+folder+"/"+mouseListFile, "file") == 0
    msg = "Error occured! The mouse list file does not exist!" + newline + " Reported by account_mice_data.m";
    error(msg);
end
file = fopen("statsdata/"+folder+"/"+mouseListFile, 'r');
mouseList = {};
while ~feof(file)
    mouseList(end+1) = {fgetl(file)};
end
mouseList = string(mouseList);
for iter = 1:length(mouseList)
    if exist("metadata/"+mouseList(iter), "file") == false
        msg = "Error occured! The mouse data file does not exist!" + newline + " Reported by account_mice_data.m";
    error(msg);
    end
end
%% Account all data listed
mouseDataList = {};
for iter = 1:length(mouseList)
    mouseDataList(end+1) = {load("metadata/"+mouseList(iter))};
end
csvRow = cellstr(mouseList)';
preStart = -1000000;
postStart = 1000000;
frameRate = 0;
numMice = length(mouseDataList);
lenSignal = zeros([numMice, 1]);
lenPSTH = zeros([numMice, 1]);
meanIntensity = 0;
prePSTH = -1000000;
postPSTH = 1000000;
% Get the time course aligned at the time where stimuli available
% combDFF = [];
for iter = 1:numMice
    % mouseData = mouseDataList{iter};
    frameRate = frameRate + mouseDataList{iter}.frameRate;
    preStart = max(preStart, mouseDataList{iter}.preStart);
    postStart = min(postStart, mouseDataList{iter}.postStart);
    lenSignal(iter) = length(mouseDataList{iter}.meanDFF);
    lenPSTH(iter) = length(mouseDataList{iter}.meanDFF);
    % meanIntensity = meanIntensity + mouseDataList{iter}.meanIntensity;
    prePSTH = max(prePSTH, mouseDataList{iter}.prePSTH);
    postPSTH = min(postPSTH, mouseDataList{iter}.postPSTH);
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
        location = min( lenSignal(iter), max(1, round( mouseDataList{iter}.frameRate * ((timePoint-1)/frameRate+(preStart-mouseDataList{iter}.preStart)) )));
        tmp1(iter) = mouseDataList{iter}.meanDFF(location);
        tmp2(iter) = (mouseDataList{iter}.meanDFF(location) - mouseDataList{iter}.meanIntensity) / mouseDataList{iter}.stdIntensity;
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
        location = min(lenPSTH(iter), max(1, round( mouseDataList{iter}.frameRate * ((timePoint-1)/frameRate+(prePSTH-mouseDataList{iter}.prePSTH)) )));
        meanStartDFF(iter, timePoint) = mouseDataList{iter}.aveStartDFF(location);
        meanStartZ(iter, timePoint) = (mouseDataList{iter}.aveStartDFF(location) - mouseDataList{iter}.meanIntensity) / mouseDataList{iter}.stdIntensity;
        meanEndDFF(iter, timePoint) = mouseDataList{iter}.aveEndDFF(location);
        meanEndZ(iter, timePoint) = (mouseDataList{iter}.aveEndDFF(location) - mouseDataList{iter}.meanIntensity) / mouseDataList{iter}.stdIntensity;
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
startDFFTable = array2table([meanStartDFF; errStartDFF], "RowNames", [csvRow; 'mean'; 'std'], "VariableNames", string((1:lenMeanPSTH)/frameRate+prePSTH));
writetable(startDFFTable, "statsdata/"+folder+"/startDFF.csv", "WriteRowNames", true);
startZTable = array2table([meanStartZ; errStartZ], "RowNames", [csvRow; 'mean'; 'std'], "VariableNames", string((1:lenMeanPSTH)/frameRate+prePSTH));
writetable(startZTable, "statsdata/"+folder+"/startZ.csv", "WriteRowNames", true);
endDFFTable = array2table([meanEndDFF; errEndDFF], "RowNames", [csvRow; 'mean'; 'std'], "VariableNames", string((1:lenMeanPSTH)/frameRate+prePSTH));
writetable(endDFFTable, "statsdata/"+folder+"/endDFF.csv", "WriteRowNames", true);
endZTable = array2table([meanEndZ; errEndZ], "RowNames", [csvRow; 'mean'; 'std'], "VariableNames", string((1:lenMeanPSTH)/frameRate+prePSTH));
writetable(endZTable, "statsdata/"+folder+"/endZ.csv", "WriteRowNames", true);
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
        if abs(boutCounted(trial)) > length(mouseDataList{iter}.meanBCDFF)
            error("The assigned bout " + num2str(boutCounted(trial)) + " is out of the range " + num2str(length(mouseDataList{iter}.meanBoutDFF)) + " of " + mouseList{iter} + newline + " Reported by account_mice_data.m");
        end
        if boutCounted(trial) > 0
            tmp1(iter) = mouseDataList{iter}.meanBCDFF(boutCounted(trial));
            tmp2(iter) = mouseDataList{iter}.meanBCLR(boutCounted(trial));
            tmp3(iter) = mouseDataList{iter}.meanBCMaxDFF(boutCounted(trial));
        else
            tmp1(iter) = mouseDataList{iter}.meanBCDFF(end+boutCounted(trial));
            tmp2(iter) = mouseDataList{iter}.meanBCLR(end+boutCounted(trial));
            tmp3(iter) = mouseDataList{iter}.meanBCMaxDFF(end+boutCounted(trial));
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
    meanBoutLR(iter) = mean(mouseDataList{iter}.meanBoutLR);
    errBoutLR(iter) = std(mouseDataList{iter}.meanBoutLR);
    meanBoutMaxDFF(iter) = mean(mouseDataList{iter}.meanBoutMaxDFF);
    errBoutMaxDFF(iter) = std(mouseDataList{iter}.meanBoutMaxDFF);
    meanBoutDuration(iter) = mean(mouseDataList{iter}.meanBoutDuration);
    errBoutDuration(iter) = std(mouseDataList{iter}.meanBoutDuration);
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
writetable(boutTable, "statsdata/"+folder+"/bouts.csv", "WriteRowNames", true)

peakStartDFF = max(meanStartDFF);
peakEndDFF = max(meanEndDFF);
peakStartZ = max(meanStartZ);
peakEndZ = max(meanEndZ);
aveStartDFF = mean(meanStartDFF);
aveEndDFF = mean(meanEndDFF);
aveStartZ = mean(meanStartZ);
aveEndZ = mean(meanEndZ);
save("statsdata/"+folder+"/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_stats.mat", ...
    "frameRate", "preStart", "postStart", "meanDFF", "meanZ", "meanIntensity", ...
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
saveas(aveDFFPlotting, "statsdata/"+folder+"/fig/"+"average_DFF.fig");
exportgraphics(aveDFFPlotting, "statsdata/"+folder+"/eps/"+"average_DFF.eps", "ContentType", "vector");
exportgraphics(aveDFFPlotting, "statsdata/"+folder+"/png/"+"average_DFF.png", "Resolution", 1200);
aveZPlotting = plot_overall_zscore(folder, '', meanZ, frameRate, preStart, postStart, manualZY, apply_errbar(showAllErr, errZ), timeScale);
saveas(aveZPlotting, "statsdata/"+folder+"/fig/"+"average_Z.fig");
exportgraphics(aveZPlotting, "statsdata/"+folder+"/eps/"+"average_Z.eps", "ContentType", "vector");
exportgraphics(aveZPlotting, "statsdata/"+folder+"/png/"+"average_Z.png", "Resolution", 1200);
clear aveDFFPlotting;
clear aveZPlotting;

% plot PSTH with dff and z-score
startDFFPlotting = plot_dff(folder, '', meanStartDFF(end,:), frameRate, prePSTH, postPSTH, manualPSTHX, manualDFFY, apply_errbar(showPSTHErr, errStartDFF), timeScale);
endDFFPlotting = plot_dff(folder, '', meanEndDFF(end,:), frameRate, prePSTH, postPSTH, manualPSTHX, manualDFFY, apply_errbar(showPSTHErr, errEndDFF), timeScale);
saveas(startDFFPlotting, "statsdata/"+folder+"/fig/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_DFF_bout_start.fig");
exportgraphics(startDFFPlotting, "statsdata/"+folder+"/eps/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_DFF_bout_start.eps", "ContentType", "vector");
exportgraphics(startDFFPlotting, "statsdata/"+folder+"/png/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_DFF_bout_start.png", "Resolution", 1200);
saveas(endDFFPlotting, "statsdata/"+folder+"/fig/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_DFF_bout_end.fig");
exportgraphics(endDFFPlotting, "statsdata/"+folder+"/eps/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_DFF_bout_end.eps", "ContentType", "vector");
exportgraphics(endDFFPlotting, "statsdata/"+folder+"/png/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_DFF_bout_end.png", "Resolution", 1200);
clear startDFFPlotting;
clear endDFFPlotting;
startZPlotting = plot_z_score(folder, '', meanStartZ(end,:), frameRate, prePSTH, postPSTH, manualPSTHX, manualDFFY, apply_errbar(showPSTHErr, errStartZ), timeScale);
endZPlotting = plot_z_score(folder, '', meanEndZ(end,:), frameRate, prePSTH, postPSTH, manualPSTHX, manualDFFY, apply_errbar(showPSTHErr, errEndZ), timeScale);
saveas(startZPlotting, "statsdata/"+folder+"/fig/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_Z_bout_start.fig");
exportgraphics(startZPlotting, "statsdata/"+folder+"/eps/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_Z_bout_start.eps", "ContentType", "vector");
exportgraphics(startZPlotting, "statsdata/"+folder+"/png/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_Z_bout_start.png", "Resolution", 1200);
saveas(endZPlotting, "statsdata/"+folder+"/fig/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_Z_bout_end.fig");
exportgraphics(endZPlotting, "statsdata/"+folder+"/eps/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_Z_bout_end.eps", "ContentType", "vector");
exportgraphics(endZPlotting, "statsdata/"+folder+"/png/"+"PSTH_"+num2str(-prePSTH)+"_"+num2str(postPSTH)+"_Z_bout_end.png", "Resolution", 1200);
clear startDFFPlotting;
clear endDFFPlotting;

boutDFFPlotting = plot_bout_stats("Averaged DFF among mice in each trial", "Delta F/F (%)", meanBCDFF*100, errBCDFF*100);
saveas(boutDFFPlotting, "statsdata/"+folder+"/fig/"+"DFF_in_bouts.fig");
exportgraphics(boutDFFPlotting, "statsdata/"+folder+"/eps/"+"DFF_in_bouts.eps", "ContentType", "vector");
exportgraphics(boutDFFPlotting, "statsdata/"+folder+"/png/"+"DFF_in_bouts.png", "Resolution", 1200);
clear boutDFFPlotting;
boutLRPlotting = plot_bout_stats("Averaged lick rate among mice in each trial", "lick rate (lick number per second)", meanBCLR, errBCLR);
saveas(boutLRPlotting, "statsdata/"+folder+"/fig/"+"lick_rate_in_bouts.fig");
exportgraphics(boutLRPlotting, "statsdata/"+folder+"/eps/"+"lick_rate_in_bouts.eps", "ContentType", "vector");
exportgraphics(boutLRPlotting, "statsdata/"+folder+"/png/"+"lick_rate_in_bouts.png", "Resolution", 1200);
clear boutLRPlotting;
boutMaxDFFPlotting = plot_bout_stats("Max DFF among mice in each trial", "Delta F/F (%)", meanBCMaxDFF*100, errBCMaxDFF*100);
saveas(boutMaxDFFPlotting, "statsdata/"+folder+"/fig/"+"max_DFF_in_bouts.fig");
exportgraphics(boutMaxDFFPlotting, "statsdata/"+folder+"/eps/"+"max_DFF_in_bouts.eps", "ContentType", "vector");
exportgraphics(boutMaxDFFPlotting, "statsdata/"+folder+"/png/"+"max_DFF_in_bouts.png", "Resolution", 1200);
clear boutMaxDFFPlotting;

end