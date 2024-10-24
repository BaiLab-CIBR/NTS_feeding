function fig = plot_z_score(mouseID, date, stimTypeName, signal, frameRate, preTime, postTime, position, manualX, manualY, errBar, timeScale)
%UNTITLED13 此处提供此函数的摘要
%   此处提供详细说明
%% Set default args
if nargin < 6
    manualX = false;
end
if nargin < 7
    manualY = false;
end
if nargin < 8
    timeScale = 's';
end
%% 
fig = figure('Visible', 'on');
timeSeries = 0:(1/frameRate):(length(signal)-1)/frameRate;
timeSeries = timeSeries + preTime;
if timeScale == 'm'
    timeSeries = timeSeries/60;
end
if timeSeries == 'h'
    timeSeries = timeSeries/3600;
end
if errBar == false
    plot(timeSeries, signal, "Color", "r");
else
    shadedErrorBar(timeSeries, signal, errBar, 'lineprops', '-r', 'transparent', true);
end
if manualX ~= false
    xlim(manualX);
end
if manualY ~= false
    ylim(manualY);
end
xlabel("Time (" + timeScale + ")");
ylabel('Fluorescence Intensity (z-score)');
% title('Peristimulus time histogram of fluorescence (z-score) '+mouseID+' '+date);
title(['Peristimulus time histogram of fluorescence (z-score) ', position,'', mouseID,' ',date,'',stimTypeName]);

end