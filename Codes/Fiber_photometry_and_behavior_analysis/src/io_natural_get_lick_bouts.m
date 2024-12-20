function [boutStartSec, boutEndSec] = io_natural_get_lick_bouts(events, FR, startTime, waterStart, waterEnd)

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
intervalThreshold=50; % 3s as the threshold of lick bout intervals
lengthThreshold=3; % 3s as the thresshold of lick bout lengths
%% Differntiation of events
events = events(round(waterStart*FR):round(waterEnd*FR));
% timeSeries = 0:1/FR:(waterEnd-waterStart);
diffEvents = diff(events);
% diffEvents(diffEvents<0)=0; %------------------------revised
%% Find lick bouts
lickStart = find(diffEvents==1);
lickEnd = find(diffEvents==-1); %------------------------added

% lickStart = lickStart ./ FR;
% lickEnd = lickEnd ./ FR;

if length(lickStart) ~= length(lickEnd) % 如果二者不等，通常有两个原因，实验开始前误碰 & 截取的时间段使配对的最后一个lickEnd还没出现
    if lickEnd(end) < lickStart(end)   % 对于第二种情况
        lickStart(end) = [];             % 无论怎样处理，以lickEnd(end)作为基准向前配对都是正确的
    end
end

if length(lickStart) > length(lickEnd) % 时常会出现第一次打标拿线头时不小心碰到打标一次，删除前面的打标点
    d = length(lickStart) - length(lickEnd); 
    lickStart(1:d) = [];
end

% lickInterval = diff(lickStart);
% boutStart = zeros([length(lickStart) 1]);
% boutEnd = zeros([length(lickStart) 1]);
% boutStart(1) = lickStart(1);
% cnt = 2;
% for k = 1:1:length(lickInterval)
%     if lickInterval(k) >= intervalThreshold * FR
%         boutStart(cnt) = lickStart(k+1);
% %         boutEnd(cnt-1) = lickStart(k);
%         cnt = cnt + 1;
%     end
% end
% boutStart = boutStart(boutStart~=0);
% boutEnd = boutEnd(boutEnd~=0);
% boutStart(end) = [];
% boutDuration = boutEnd - boutStart(1:end);
% boutStart( boutDuration<lengthThreshold_low*FR ) = []; boutStart( boutDuration>lengthThreshold_high*FR ) = [];
% boutEnd( boutDuration<lengthThreshold_low*FR ) = []; boutEnd( boutDuration>lengthThreshold_high*FR ) = [];
% boutDuration = (boutEnd-boutStart(1:end))/FR;
% 
% meanDuration = mean(boutDuration); % mean length of bouts
% boutInterval = diff(boutStart)/FR; % intervals between bouts
% meanInterval = mean(boutInterval); % mean intervals between bouts


boutStartSec = lickStart/FR + waterStart - startTime; %----------revised
boutEndSec = lickEnd/FR + waterStart - startTime;%----------------revised



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

