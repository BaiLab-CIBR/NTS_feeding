function fig = plot_corrected_cal_signals(signal, frameRate, manualY, timeScale)
% Plot corrected calcium signals
% 
% signal: The corrected signal.
% frameRate: the frame rate of the signal.
% plot_immediately: If true, plot the figure, otherwise not.
%% Set the default value of frameRate and plot_immediately.
if nargin < 3
    manualY = false;
end
if nargin < 4
    timeScale = 's';
end
%% Set figure property.
timeSeries = 0:1/frameRate:(length(signal)-1)/frameRate;
if timeScale == 'm'
    timeSeries = timeSeries/60;
end
if timeSeries == 'h'
    timeSeries = timeSeries/3600;
end
fig = figure('visible', 'on');
plot(timeSeries, signal);
% hold on;
% plot(timeSeries, baseline);
if manualY ~= false
    ylim(manualY);
end
xlabel('Time (s)');
ylabel("Time (" + timeScale + ")");
title('Time course of fluorescence intensity of the corrected calcium signal');
end