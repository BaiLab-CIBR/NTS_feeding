function [boutIntensityDFFMean, boutIntensityDFFMax, boutIntensityDFFHWT] = get_bout_stats(signal, frameRate, boutStart, boutEnd, timeStart, stimStart, stimEnd)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明
boutNum = length(boutStart);
lenSignal = length(signal);
boutIntensityDFFMean = zeros([1 boutNum]);
boutIntensityDFFMax = zeros([1 boutNum]);
boutIntensityDFFHWT = zeros([1 boutNum]);
for iter = 1:boutNum
    left = max(1, round(boutStart(iter)*frameRate));
    right = min(lenSignal, round(boutEnd(iter)*frameRate));
    boutIntensityDFFMean(iter) = mean(signal(left:right));
    [boutIntensityDFFMax(iter) argmax] = max(signal(left:right));
    %(argmax)/frameRate
    for tp = left:right
        if signal(tp) > (boutIntensityDFFMax(iter)- signal(left)) * 0.67 + signal(left)
            boutIntensityDFFHWT(iter) = double(tp-left) / double(right-left);
            break;
        end
    end
    %(boutIntensityDFFMax(iter) - signal(left)) * 0.67
end
%boutIntensityDFFHWT
% save("analysedata/"+date+"_"+mouseID+"/lick_data.mat", "boutIntensityDFF", '-append');
end