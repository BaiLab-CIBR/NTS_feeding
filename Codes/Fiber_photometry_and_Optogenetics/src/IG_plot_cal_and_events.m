function fig = IG_plot_cal_and_events(mouseID, date, stimTypeName, plotStim, eventInducedSignal, baseline, frCal, events, frEvent, startTime, endTime, stimStart, stimEnd, manualY, percentage, eisErr, timeScale)
% Plot raw calcium signal and events together.
%
if nargin < 6
    timeScale = 's';
end

minP = min(min(eventInducedSignal), min(baseline));
maxP = max(max(eventInducedSignal), max(baseline));
if eisErr ~= false
    minP = min(minP, min(eventInducedSignal-eisErr));
    maxP = max(maxP, max(eventInducedSignal+eisErr));
end
diff = maxP - minP;
minP = minP - diff * 0.15;
maxP = maxP + diff * 0.15;
minP = min(minP, 0);
if manualY ~= false
    minP = manualY(1);
    maxP = manualY(2);
end
fig = figure('visible', 'on');
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
iter = 1;
while iter < len
    if events(iter) > 0
        % x = yRange*0 + timeSeries(iter);
        % l = line([timeSeries(iter) timeSeries(iter)], [minP maxP], 'Color', '#FBE7A1');
        % plot_transparently([timeSeries(iter) timeSeries(iter)], [minP, maxP], 0.5, 'Color', '#FBE7A1'); too large file
        x1 = timeSeries(iter);
        while events(iter) > 0 && iter < len
            iter = iter + 1;
        end
        x2 = timeSeries(iter);
        patch([x1 x2 x2 x1], [minP minP maxP maxP], [251/256 231/256 161/256], "FaceAlpha", 0.3, "EdgeColor", "none");
        % fprintf("%f %f\n", x1, x2);
        % patch([0 1 1 0], [0 0 1 1], 'red');
    end
    iter = iter + 1;
end
% for iter = 1:len
%     if events(iter) > 0
%         patchline([timeSeries(iter) timeSeries(iter)], [minP maxP], "EdgeAlpha", 0.5, 'EdgeColor', '#FBE7A1')
%     end
% end
hold on;
timeSeries = startTime:1/frCal:startTime+(length(eventInducedSignal)-1)/frCal;
if timeScale == 'm'
    timeSeries = timeSeries/60;
end
if timeSeries == 'h'
    timeSeries = timeSeries/3600;
end
if eisErr == false
    patchline(timeSeries, eventInducedSignal, "EdgeAlpha", 0.5, "EdgeColor", 'blue');
else
    shadedErrorBar(timeSeries, eventInducedSignal, eisErr, 'lineprops', '-b', 'transparent', true);
end
hold on;
timeSeries = startTime:1/frCal:startTime+(length(baseline)-1)/frCal;
if timeScale == 'm'
    timeSeries = timeSeries/60;
end
if timeSeries == 'h'
    timeSeries = timeSeries/3600;
end
if baseline ~= false
    patchline(timeSeries, baseline, "EdgeAlpha", 0.7, "EdgeColor", 'red');
end
hold on;
if timeScale == 'm'
    stimStart = stimStart/60;
    stimEnd = stimEnd/60;
end
if timeSeries == 'h'
    stimStart = stimStart/3600;
    stimEnd = stimEnd/3600;
end
if plotStim == true
    patch([stimStart, stimEnd, stimEnd, stimStart], [minP, minP, maxP, maxP], [127/256, 255/256, 212/256], "FaceAlpha", 0.5, "EdgeColor", 'none')
end
ylim([minP maxP]);
if percentage == true
    ytickformat('percentage');
end
xlabel("Time (" +timeScale + ")");
ylabel('Fluorescence Intensity');
% title(['Time course of fluorescence intensity and events',mouseID,' ',date,' ',stimTypeName]);
title(['Time course of fluorescence intensity and events',mouseID,' ',date,' ',stimTypeName]);
end