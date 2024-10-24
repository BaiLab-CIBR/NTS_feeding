function fig = plot_raw_events(events, frameRate, timeScale)
% Plot events.
% events: The recorded signal of events, one represents an event.
%%  Set the default value of frameRate
if nargin < 2
    frameRate = 1000;
end
if nargin < 3
    timeScale = 's';
end
%% Set figure property
timeSeries = 0:(1/frameRate):(length(events)-1)/frameRate;
if timeScale == 'm'
    timeSeries = timeSeries/60;
end
if timeSeries == 'h'
    timeSeries = timeSeries/3600;
end
len = length(events);
fig = figure('visible', 'on');
xlim([0 timeSeries(end)]);
ylim([0 1]);
for iter = 1:len
    if events(iter) > 0
        line([timeSeries(iter) timeSeries(iter)], [0 1], 'Color', '#FBE7A1');
    end
end
xlabel("Time (" + timeScale + ")");
% ylabel('Fluorescence Intensity');
title('Time course of events');
end