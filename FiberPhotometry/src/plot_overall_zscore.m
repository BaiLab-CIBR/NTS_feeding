function fig = plot_overall_zscore(mouseID, date, stimTypeName, signal, frameRate, startTime, endTime, manualY, errBar, timeScale)
% Plot the signal zscore from start time to end time.
%% Set the default value of frameRate and plot_immediately.
if nargin < 5
    manualY = false;
end
if nargin < 6
    errBar = false;
end
if nargin < 7
    timeScale = 's';
end
fig = figure('Visible', 'on');
timeSeries = 0:(1/frameRate):(length(signal)-1)/frameRate;
timeSeries = timeSeries + startTime;
if timeScale == 'm'
    timeSeries = timeSeries/60;
end
if timeSeries == 'h'
    timeSeries = timeSeries/3600;
end
if errBar == false
    plot(timeSeries, signal);
else
    shadedErrorBar(timeSeries, signal, errBar, 'lineprops', '-b', 'transparent', true)
end
if manualY ~= false
    ylim(manualY);
end
xlabel("Time (" + timeScale + ")");
ylabel('Fluorescence Intensity (z-score)');
% title('Activity of fluorescence (z-score) of '+mouseID+' '+date);
title(['Activity of fluorescence (z-score) of ',mouseID,' ',date,' ',stimTypeName]);
end