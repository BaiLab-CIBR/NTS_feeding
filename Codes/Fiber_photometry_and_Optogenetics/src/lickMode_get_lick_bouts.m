function [boutStartSec, boutEndSec, lickRatePerbout, consumptionRatePerbout,lickStartToEnd_sec] = lickMode_get_lick_bouts(events, FR, startTime, waterStart, waterEnd, intervalThreshold, lengthThreshold, LickIntervalwithinABout_thr)

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
% intervalThreshold=20; % 3s as the threshold of lick bout intervals
% lengthThreshold=3; % 3s as the thresshold of lick bout lengths
% LickIntervalwithinABout_thr=3;
%% Differntiation of events
events = events(round(waterStart*FR):round(waterEnd*FR));
% timeSeries = 0:1/FR:(waterEnd-waterStart);
diffEvents = [0;diff(events)];
% diffEvents(diffEvents<0)=0;
%% Find lick bouts
lickStart = find(diffEvents==1);
lickEnd = find(diffEvents==-1);

if length(lickStart) > length(lickEnd)
    tmp = length(lickStart) - length(lickEnd);
    lickStart = lickStart(1:end-tmp);
elseif length(lickStart) < length(lickEnd)
    tmp = length(lickEnd) - length(lickStart);
    lickEnd = lickEnd(1:end-tmp);
end
lickStartToEnd = [lickStart, lickEnd];

if isempty(lickStart)
    boutStartSec = []; boutEndSec = []; lickRatePerbout =[]; consumptionRatePerbout = []; lickStartToEnd_sec=[];
    return
end

% 思路1：求每两个相邻的lick之间的间距（而不是相邻bout之间的间距），通过此筛选出的boutstart之间一定会有20s的间距（本代码使用的鉴定方案）
% 思路2：从每个lick开始寻找，如果lick之间的间距小于等于3s，属于一个bout，得到一个boutend，直到下一个lick和前一个lick之间的间距大于20s，归为下一个boutstart
% 如果忽略每一个lick长度本身
lick = lickStart;
ind = find(diff(lick)/FR>intervalThreshold);

if isempty(ind)
    boutStartSec = []; boutEndSec = []; lickRatePerbout =[]; consumptionRatePerbout = []; lickStartToEnd_sec=[];
    return
end

boutStart(1) = lick(1);
boutEnd(1)=lick(ind(1));
boutStart=[boutStart(1);lick(ind+1)];
for i = 1:length(boutStart)
    idx = find(lick==boutStart(i)); 
    if idx~=length(lick) % idx找到的boutstart可能是最后一次lick，后面就不再lick了，那么也就没有所谓的它之后的lickEnd了，那么终止并删除最后一次boutStart
        for j = idx:length(lick)-1
            delta=(lick(j+1)-lick(j))/FR;
            if delta>LickIntervalwithinABout_thr
                break
            end
        end
        boutEnd(i)=lick(j);
    else
        boutStart(end)=[];
    end
end
boutEnd = boutEnd';

% 基于duration排除bout：这个需要加上，因为有的时候只lick了一下，就停了很久，对于这次event，lickStart和lickEnd为同一时间点，要删掉
bout = [boutStart, boutEnd];
d = diff(bout');
idx = d/FR < lengthThreshold;
bout(idx,:) = [];   
boutStart = bout(:,1);
boutEnd = bout(:,2);


% % 方法：第一步：排除 --- 后一个lickStart和前一个lickEnd之间的差值如果大于3s，则为一个新的bout。
% if ~isempty(lickStartToEnd)
% j=1; 
% bout(1,1) = lickStartToEnd(1,1); % A为两列的数据，记录每一个bout开始和结束的时刻
% for i = 1:size(lickStartToEnd,1)-1
%     if ( lickStartToEnd(i+1,1)-lickStartToEnd(i,2) )/FR > intervalThreshold
%         j=j+1;
%         bout(j,1) = lickStartToEnd(i+1,1); % ?之前写的bout(j,1) = lickStartToEnd(i+1);
%         bout(j-1,2) = lickStartToEnd(i,2);
%         tmp1 = i;
%     end
% end
% tmp2=j;
% end
% 
% if exist('tmp1','var')
% % 第二步：合并 --- 对于最后一个bout，其后面的间隔都会比较短，可能共属于一个bout。 
% % 方法：如果后一个lickStart和前一个lickEnd之间的差值如果小于等于3s，则归为同一个bout。
% j=tmp1+1;
% for i = tmp1 : size(lickStartToEnd,1)-1
%     if ( lickStartToEnd(i+1,1)-lickStartToEnd(i,2) )/FR < intervalThreshold
%     j = j+1;
%     end
% end
%     bout(tmp2,2) = lickStartToEnd(j,2);  
% 
%  % 第三步：基于duration排除bout
% d = diff(bout');
% idx = d/FR < lengthThreshold;
% bout(idx,:) = [];   
% boutStart = bout(:,1);
% boutEnd = bout(:,2);
% end

% 
% lickInterval = diff(lickStart);
% boutStart = zeros([length(lickStart) 1]);
% boutEnd = zeros([length(lickStart) 1]);

if ~isempty(lickStart) && exist('boutEnd','var') % -----------------------------------added

% boutStart(1) = lickStart(1);
% cnt = 2;
% for k = 1:1:length(lickInterval)
%     if lickInterval(k) >= intervalThreshold * FR
%         boutStart(cnt) = lickStart(k+1);
%         boutEnd(cnt-1) = lickStart(k);
%         cnt = cnt + 1;
%     end
% end
boutStart = boutStart(boutStart~=0);
boutEnd = boutEnd(boutEnd~=0);
% boutStart(end) = [];
boutDuration = boutEnd - boutStart(1:end);
boutStart( boutDuration<lengthThreshold*FR ) = [];
boutEnd( boutDuration<lengthThreshold*FR ) = [];
boutDuration = (boutEnd-boutStart(1:end))/FR;

meanDuration = mean(boutDuration); % mean length of bouts
boutInterval = diff(boutStart)/FR; % intervals between bouts
meanInterval = mean(boutInterval); % mean intervals between bouts

boutStartSec = boutStart/FR + waterStart - startTime; 
boutEndSec = boutEnd/FR + waterStart - startTime;

lickStartToEnd_sec = lickStartToEnd/FR + waterStart - startTime; %------------------added

%% Account the licks in each bout
diffEvents(diffEvents<0)=0;    % move here----------------added
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
boutStartSec = []; boutEndSec = []; lickRatePerbout =[]; consumptionRatePerbout = []; lickStartToEnd_sec=[];

end

end
