function [meanLick, meanConsumption] = get_bout_licks(frameRate, events, startSec, endSec)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明
numBouts = length(startSec);
%numBouts
meanLick = zeros([numBouts 1]);
meanConsumption = zeros([numBouts 1]);
for iter = 1:numBouts
    left = max(1, round(startSec(iter)*frameRate));
    right = min(length(events), round(endSec(iter)*frameRate));
    meanConsumption(iter) = sum(events(left:right)) / (right-left);
    %sum(events(left:right))
    meanLick(iter) = (sum(diff(events(left:right))==1) + events(left)) / (right-left);
end
end