function plot_cal_and_events(mouseID, date, stimTypeName,eventInducedSignal, baseline, frCal, events, frEvent, startTime, endTime, manualY, percentage, timeScale)

% % 调试代码用
% plot_cal_and_events(mouseID, date, stimTypeName,eventCalArr, baselineArr, frameRateSignal, eventsArr, frameRateEvent, 0, length(baselineArr)/frameRateSignal, false, false, timeScale);
% eventInducedSignal = eventCalArr;
% baseline = baselineArr;
% frCal=frameRateSignal;
% events=eventsArr;
% frEvent=frameRateEvent;
% startTime=0;
% endTime=length(baselineArr)/frameRateSignal;
% manualY=false;
% percentage = false;


% Plot raw calcium signal and events together.
%
if nargin < 6
    timeScale = 's';
end

minP = min(min(eventInducedSignal), min(baseline));
maxP = max(max(eventInducedSignal), max(baseline));
diff = maxP - minP;
minP = minP - diff * 0.15;
maxP = maxP + diff * 0.15;
minP = min(minP, 0);
if manualY ~= false
    minP = manualY(1);
    maxP = manualY(2);
end
% fig = figure('visible', 'on');
% disp(minP);
% disp(maxP);
len = length(events);
timeSeries = startTime:1/frEvent:startTime+(length(events)-1)/frEvent;
if timeScale == 'm'
    timeSeries = timeSeries/60;
end
if timeSeries == 'h'
    timeSeries = timeSeries/3600;
end
% yRange = linspace(minP, maxP);
% iter = 1;
% while iter < len
%     if events(iter) > 0
%         % x = yRange*0 + timeSeries(iter);
        % l = line([timeSeries(iter) timeSeries(iter)], [minP maxP], 'Color', '#FBE7A1');
        % plot_transparently([timeSeries(iter) timeSeries(iter)], [minP, maxP], 0.5, 'Color', '#FBE7A1'); too large file
%         x1 = timeSeries(iter);
%         while events(iter) > 0 && iter < len
%             iter = iter + 1;
%         end
%         x2 = timeSeries(iter-1);
%         patch([x1 x2 x2 x1], [minP minP maxP maxP], [251/256 231/256 161/256], "FaceAlpha", 0.3, "EdgeColor", "none");
%         fprintf("%f %f\n", x1, x2);
%         % patch([0 1 1 0], [0 0 1 1], 'red');
%     end
%     iter = iter + 1;
% end
for iter = 1:len
    if events(iter) > 0
        patchline([timeSeries(iter) timeSeries(iter)], [minP maxP], "EdgeAlpha", 0.5, 'EdgeColor', '#FBE7A1')
    end
end
hold on;
timeSeries = startTime:1/frCal:startTime+(length(eventInducedSignal)-1)/frCal;
if timeScale == 'm'
    timeSeries = timeSeries/60;
end
if timeSeries == 'h'
    timeSeries = timeSeries/3600;
end
patchline(timeSeries, eventInducedSignal, "EdgeAlpha", 0.5, 'EdgeColor', 'blue');
hold on;
timeSeries = startTime:1/frCal:startTime+(length(baseline)-1)/frCal;
if timeScale == 'm'
    timeSeries = timeSeries/60;
end
if timeSeries == 'h'
    timeSeries = timeSeries/3600;
end
% if baseline ~= false
if sum(baseline) ~= false % edited
    patchline(timeSeries, baseline, "EdgeAlpha", 0.7, 'EdgeColor', 'red');
end
ylim([minP maxP]);
if percentage == true
    ytickformat('percentage');
end
xlabel("Time (" +timeScale + ")");
ylabel('Fluorescence Intensity');
title(['Time course of fluorescence intensity and events',mouseID,' ',date,' ',stimTypeName]);
end