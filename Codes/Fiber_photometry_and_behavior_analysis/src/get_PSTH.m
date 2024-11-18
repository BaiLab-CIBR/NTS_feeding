function [PSTH, meanPSTH, errPSTH] = get_PSTH(triggerTimes, signal, frameRate, preTime, postTime, check)

% % 调试程序使用:boutStartSec
% [startPSTH, meanStartPSTH, errStartPSTH] = get_PSTH(boutStartSec, dffSignal, frameRateSignal, preTime, postTime, false);
% triggerTimes = boutStartSec;
% signal = dffSignal;
% frameRate = frameRateSignal;
% preTime = preTime;
% postTime = postTime;
% check = 'false';

% % 调试程序使用:boutEndtSec
% [endPSTH, meanEndPSTH, errEndPSTH] = get_PSTH(boutEndSec, dffSignal, frameRateSignal, preTime, postTime, false);
% triggerTimes = boutEndSec;
% signal = dffSignal;
% frameRate = frameRateSignal;
% preTime = preTime;
% postTime = postTime;
% check = 'false';

% Get the PSTH
% triggerTimes: The time events occured.
% signal: The signal array.
% frameRate: The frame rate of the signal.
% preTime: The time to be recorded before the events.
% postTime: The time to be recorded after the events.
% check: Whether to plot the PSTH.

% PSTH = zeros([length(triggerTimes),round((postTime-preTime)*frameRate)+1]); %wqs cancelled,后面"if clip+size(PSTH,2)-1 < length(signal)"可能会会得到几行空值

length_PSTH = round((postTime-preTime)*frameRate)+1;

%(triggerTimes-3)*frameRate
for iter = 1:length(triggerTimes)
    clip = round((triggerTimes(iter)+preTime)*frameRate);
    %clip
    
    if clip+length_PSTH -1 < length(signal)  %-----------------added: 如果最后面截取的时间段不够计算计算PSTH的，则终止计算

    PSTH(iter,:) = signal(clip:clip+length_PSTH -1);

    end

end
meanPSTH = mean(PSTH);
errPSTH = std(PSTH, 0, 1) / (size(PSTH, 1)-1)^0.5;
%zScoredPSTH = zscore(PSTH, 0, 1);
%zMeanPSTH = mean(zScoredPSTH);
%zScoredPSTH(:,1)
%zErrPSTH = std(zScoredPSTH, 0, 1) / (size(PSTH, 1)-1)^0.5;
if check == true
    fig = figure('visible', 'on');
    plot(signal);
    hold on;
    for iter = 1:length(triggerTimes)
        patchline([triggerTimes(iter)*frameRate triggerTimes(iter)*frameRate], [0 1], "EdgeAlpha", 0.9, 'EdgeColor', '#FBE7A1');
    end
    hold off;
    fig = figure('visible', 'on');
    for iter = 1:length(triggerTimes)
        plot(PSTH(iter,:));
        hold on;
    end
    hold off;
    fig = figure('visible', 'on');
    plot(meanPSTH);
end
end