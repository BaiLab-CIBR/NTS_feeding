function [boutStartSec, boutEndSec] = og_get_lick_bouts(events, FR, startTime, waterStart, waterEnd)  

% % 调试程序使用
% [boutStartSec, boutEndSec, meanLRBout, consumptionBout] = get_lick_bouts(accEvArr, frameRateAcc, startTime, stimStart, stimEnd);
%  [boutStartSec, boutEndSec] =  og_get_lick_bouts(accEvArr, frameRateAcc, startTime, stimStart, stimEnd);
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
intervalThreshold=70; % 3s as the threshold of lick bout intervals
lengthThreshold_low=3; % 3s as the thresshold of lick bout lengths
lengthThreshold_high=70; % 3s as the thresshold of lick bout lengths
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

if isempty(lickStart)
    disp('No any events were detected, maybe the stimulation start time was wrongly set! Try to increase the start time of stimulation with at least the additional 1800s')
end
boutStart(1) = lickStart(1);

cnt = 2;
for k = 1:1:length(lickInterval)
    if lickInterval(k) >= intervalThreshold * FR
        boutStart(cnt) = lickStart(k+1);
        boutEnd(cnt-1) = lickStart(k);
        cnt = cnt + 1;
    end
end
boutEnd(cnt-1) = lickStart(end);
boutStart = boutStart(boutStart~=0);
boutEnd = boutEnd(boutEnd~=0);
% boutStart(end) = [];
boutDuration = boutEnd - boutStart(1:end);
% boutStart( boutDuration<lengthThreshold_low*FR ) = []; boutStart( boutDuration>lengthThreshold_high*FR ) = [];
ind1 = find(boutDuration<lengthThreshold_low*FR); ind2 = find(boutDuration>lengthThreshold_high*FR);
ind = [ind1,ind2];
boutStart(ind) = []; 
% boutEnd( boutDuration<lengthThreshold_low*FR ) = []; boutEnd( boutDuration>lengthThreshold_high*FR ) = [];
boutEnd(ind) = []; 
boutDuration = (boutEnd-boutStart(1:end))/FR;

meanDuration = mean(boutDuration); % mean length of bouts
boutInterval = diff(boutStart)/FR; % intervals between bouts
meanInterval = mean(boutInterval); % mean intervals between bouts

boutStartSec = boutStart/FR + waterStart - startTime; 
boutEndSec = boutEnd/FR + waterStart - startTime;



% if contains(stimTypeName,'og') % 如果是oral gavage模式，判断标准：%---------------------------------added
%     downsampled = table2array(downsampled);
%     Event_down = downsampled(:,eventChannel);
%     Event_taskOn = Event_down(stimStart*frameRateEvent:end);
%     lick_timestamp = find(Event_taskOn==1); % 每一个lick对应的时间戳
%     diff_lick = diff(lick_timestamp) ./ frameRateEvent; 
%     bout_interval = 100; % lick之间差值大于50s的话，归为不同的bout
%     boutStart = lick_timestamp( diff_lick>5 & diff_lick<50 );
%     boutEnd = [lick_timestamp( diff_lick>bout_interval ); lick_timestamp(end)];
%     meanLRBout = nan; consumptionBout =nan;
% end
% if length(boutStart) < length(boutEnd) % 时常会出现第一次打标拿线头时不小心碰到打标一次，删除前面的打标点
%     d = length(boutEnd) - length(boutStart);
%     boutEnd(1:d) = [];
% end
% boutStartSec = round(boutStart ./ frameRateEvent + stimStart-1);
% boutEndSec = round(boutEnd ./ frameRateEvent + stimStart-1);

