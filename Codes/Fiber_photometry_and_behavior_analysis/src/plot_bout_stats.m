function fig = plot_bout_stats(name ,yName, value, errBar)
%UNTITLED3 此处提供此函数的摘要
%   此处提供详细说明
fig = figure('visible', 'on');
errorbar(value, errBar, 'bo','MarkerFaceColor','b');
xlim([0 length(value)+1]);
xlabel('Trials');
ylabel(yName);
title(name);
end