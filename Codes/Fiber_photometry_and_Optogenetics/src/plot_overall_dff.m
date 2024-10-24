function fig = plot_overall_dff(mouseID, date, stimTypeName, signal, frameRate, startTime, endTime, manualY, errBar, timeScale)
% Plot the signal deltaF/F from start time to end time.
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
%%
fig = figure('Visible', 'on');
timeSeries = 0:(1/frameRate):(length(signal)-1)/frameRate;
timeSeries = timeSeries + startTime;
if timeScale == 'm'
    timeSeries = timeSeries/60;
end
if timeSeries == 'h'
    timeSeries = timeSeries/3600;
end
%size(timeSeries)
%size(signal)    
if errBar == false
    plot(timeSeries, signal*100);
else
    shadedErrorBar(timeSeries, signal*100, errBar*100, 'lineprops', '-b', 'transparent', true);
end
if manualY ~= false
    ylim(manualY);
end
ytickformat('percentage');
xlabel("Time (" + timeScale + ")");
ylabel('Fluorescence Intensity (delta F/F)');
% title('Activity of fluorescence (delta F/F) '+mouseID+' '+date);
title(['Activity of fluorescence (delta F/F) ',mouseID,' ',date,' ',stimTypeName]);
end