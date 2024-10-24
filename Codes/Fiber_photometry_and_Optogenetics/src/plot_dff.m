function plot_dff(mouseID, date, stimTypeName, signal, frameRate, preTime, postTime, position, manualX, manualY, errBar, timeScale)

% plot_dff(mouseID, date_format(date),stimTypeName, meanStartPSTH, frameRateSignal, preTime, postTime, "lick bout starts",manualPSTHX, manualDFFY, apply_errbar(showErr, errStartPSTH), 's');


% Plot the mean PSTH with error bar.
% meanPSTH
% stdPSTH: The standard error bar of the PSTH.
% preTime: The prestimulus time of PSTH.
% postTime: The poststimulus time of PSTH.
% manualX: The manual setting of x axis range.
% manualY: The manual setting of y axis range.
%% Set default args
if nargin < 5
    manualX = false;
end
if nargin < 6
    manualY = false;
end
if nargin < 7
    errBar = false;
end
if nargin < 8
    timeScale = 's';
end
%%
% fig = figure('Visible', 'on');
timeSeries = 0:(1/frameRate):(length(signal)-1)/frameRate;
timeSeries = timeSeries + preTime;
if timeScale == 'm'
    timeSeries = timeSeries/60;
end
if timeSeries == 'h'
    timeSeries = timeSeries/3600;
end
if errBar == false
    plot(timeSeries, signal*100, "Color", "r");
else
    shadedErrorBar(timeSeries, signal*100, errBar*100, 'lineprops', '-r', 'transparent', true);
end
if manualX ~= false
    xlim(manualX);
end
if manualY ~= false
    ylim(manualY);
end
% ytickformat('percentage');
xlabel("Time (" + timeScale + ")");
ylabel('Fluorescence Intensity (delta F/F)');
% title('Peristimulus time histogram of fluorescence (delta F/F) '+mouseID+' '+date);
title(['Peristimulus time histogram of fluorescence (delta F/F) ',position,'', mouseID,' ',date,'',stimTypeName]);

end