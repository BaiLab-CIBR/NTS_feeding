function plot_raw_cal_signals(eventInducedSignal, baseline, frameRate, manualY, timeScale)
% Plot calcium signals, one is the event induced signal, another is the baseline.
% If plot_immediately is true, plot the result, otherwise only return the result.
% 
% evnetInducedSignal: The event reduced signal, the first column of the assigned ROI, briefly, EIS.
% baseline: The baseline, the third column of the assigned ROI, which is used to correct the EIS.
% plot_immediately: If true, plot the figure, otherwise not.
%% Check data validity.
if length(eventInducedSignal) ~=  length(baseline)
    msg = "Error occured! The length of event induced signal does not equal the bassline.\r\n Reported by plot_raw_cal_signals.m";
    error(msg);
end
%% Set the default value of frameRate and plot_immediately.
if nargin < 3
    frameRate = 15;
end
if nargin < 4
    manualY = false
end
if nargin < 5
    timeScale = 's';
end
%% Set figure property.
timeSeries = 0:1/frameRate:(length(baseline)-1)/frameRate;
if timeScale == 'm'
    timeSeries = timeSeries/60;
end
if timeSeries == 'h'
    timeSeries = timeSeries/3600;
end
% fig = figure('visible', 'on');
plot(timeSeries, eventInducedSignal, timeSeries, baseline);
% hold on;
% plot(timeSeries, baseline);
if manualY ~= false
    ylim(manualY);
end
% legend('EIS(t)', 'baseline(t)');
% xlabel("Time (" + timeScale + ")");
% ylabel('Fluorescence Intensity');
% title('Time course of fluorescence intensity of 2 channels');
end