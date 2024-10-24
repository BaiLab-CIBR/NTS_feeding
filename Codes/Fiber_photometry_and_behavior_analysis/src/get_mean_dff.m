function ret = get_mean_dff(level, folder, file, startTime, endTime)
% level = "analysedata", "metadata", "statsdata"
%

%% Check the data validity and read the data
if exist(level+"/"+folder+"/"+file, "file") == 0
    msg = "Error occured! The data file does not exist!" + newline + " Reported by get_mean_dff.m";
    error(msg);
end
%%
data = load(level+"/"+folder+"/"+file);
if level == "analysedata"
    frameRate = data.frameRateSignal;
    signal = data.dffSignal;
    zeroP = data.stimStart - data.startTime;
else
    frameRate = data.frameRate;
    signal = data.meanDFF;
    zeroP = -data.preStart;
end
startP = round((startTime-zeroP) * frameRate);
endP = round((endTime-zeroP) * frameRate);
startP = max(1, min(length(signal), startP));
endP = max(1, min(length(signal), endP));
ret = mean(signal(startP:endP));
disp(ret);
fig = figure();
plot(-zeroP:1/frameRate:(length(signal)-1)/frameRate-zeroP, signal);
%plot(startTime:1/frameRate:startTime+(endP-startP)/frameRate, signal(startP:endP));
hold on;
rangeVal = max(signal) - min(signal);
rangeMin = min(signal) - rangeVal*0.15;
rangeMax = max(signal) + rangeVal*0.15;
ylim([rangeMin, rangeMax]);
patch([startTime, endTime, endTime, startTime], [rangeMin, rangeMin, rangeMax, rangeMax], [0 0 0], 'faceColor', '#FFDEAD', 'faceAlpha', 0.3, 'EdgeColor', 'none');
end