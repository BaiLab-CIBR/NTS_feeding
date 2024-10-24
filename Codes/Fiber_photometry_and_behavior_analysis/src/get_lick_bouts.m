function [boutStartSec, boutEndSec, lickRatePerbout, consumptionRatePerbout, diffEvents] = get_lick_bouts(events, FR, startTime, waterStart, waterEnd)

% % 调试程序使用
% [boutStartSec, boutEndSec, meanLRBout, consumptionBout] = get_lick_bouts(accEvArr, frameRateAcc, startTime, stimStart, stimEnd);
% events = accEvArr;
% FR = frameRateAcc;
% waterStart = stimStart;
% waterEnd = stimEnd;

% Get lick bouts of the mouse.
% date
% mouseID
% events: The events array.
% FR: the frame rate of the events.
% startTime: The start time of the experiment.
% waterStart: The time water becoming available.
% waterEnd: The time water becoming unavailable.
%% Preprocess of the arguments
if waterEnd*FR > length(events)
    waterEnd = length(events)/FR;
end
%% Divide bout by time interval and bout duration(p.s.Second parameter is the number of licks contained in the bout in some article)
intervalThreshold=3; % 3s as the threshold of lick bout intervals
lengthThreshold=3; % 3s as the thresshold of lick bout lengths
%% Differntiation of events
events = events(round(waterStart*FR):round(waterEnd*FR));
% timeSeries = 0:1/FR:(waterEnd-waterStart);
diffEvents = diff(events);
diffEvents(diffEvents<0)=0;
%% Find lick bouts
lickStart = find(diffEvents==1);
lickInterval = diff(lickStart);
boutStart = zeros([length(lickStart) 1]);
boutEnd = zeros([length(lickStart) 1]);

if ~isempty(lickStart) % -----------------------------------added

boutStart(1) = lickStart(1);
cnt = 2;
for k = 1:1:length(lickInterval)
    if lickInterval(k) >= intervalThreshold * FR
        boutStart(cnt) = lickStart(k+1);
        boutEnd(cnt-1) = lickStart(k);
        cnt = cnt + 1;
    end
end
boutStart = boutStart(boutStart~=0);
boutEnd = boutEnd(boutEnd~=0);
boutStart(end) = [];
boutDuration = boutEnd - boutStart(1:end);
boutStart( boutDuration<lengthThreshold*FR ) = [];
boutEnd( boutDuration<lengthThreshold*FR ) = [];
boutDuration = (boutEnd-boutStart(1:end))/FR;

meanDuration = mean(boutDuration); % mean length of bouts
boutInterval = diff(boutStart)/FR; % intervals between bouts
meanInterval = mean(boutInterval); % mean intervals between bouts

boutStartSec = boutStart/FR + waterStart - startTime; 
boutEndSec = boutEnd/FR + waterStart - startTime;

%% Account the licks in each bout
lickPerbout = zeros([length(boutEnd) 1]);
for m = 1:length(boutEnd)
    lickPerbout(m) = sum(diffEvents(boutStart(m):boutEnd(m)));
    %sum(diffEvents(boutStart(m):boutStart(m)+6*FR))
end
%lickPerbout
lickRatePerbout = lickPerbout ./ boutDuration;
meanLickPerbout = mean(lickPerbout);
meanLickratePerbout = mean(lickRatePerbout);
%% Consumption rate and Consumption time
consumptionTime = length(find(events(round(waterStart*FR):end)==1)) / FR;
consumptionTimePerbout = zeros([size(boutEnd) 1]);
for n=1:length(boutEnd)
    consumptionTimePerbout(n) = sum(events(boutStart(n):boutEnd(n))) / FR;
end
consumptionRatePerbout = consumptionTimePerbout./boutDuration;
meanConsumptionTimePerbout = mean(consumptionTimePerbout);
meanConsumptionRatePerbout = mean(consumptionRatePerbout);
meanLickWeight = mean(consumptionTimePerbout./lickPerbout);

% save("analysedata/"+date+"_"+mouseID+"/lick_data.mat", "boutStartSec", "boutEndSec", "meanDuration", "meanInterval", "lickPerbout", "lickRatePerbout", "meanLickPerbout", "meanLickratePerbout", "consumptionTime", "consumptionTimePerbout", "consumptionRatePerbout", "meanConsumptionTimePerbout", "meanConsumptionRatePerbout", "meanLickWeight");
% save lickanalysis.mat tExpstart t_waterstart boutStart boutEnd lickratePerbout lickPerbout consumptionTimePerbout consumptionRatePerbout meanDuration mean_bout_interval mean_consumptiontimePerbout mean_consumptionratePerbout meanLickratePerbout meanLickPerbout meanLickWeight;
else
boutStartSec = []; boutEndSec = []; lickRatePerbout =[]; consumptionRatePerbout = [];

end

end
