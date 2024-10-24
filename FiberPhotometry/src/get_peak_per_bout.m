function peakSec = get_peak_per_bout(frameRate, startSec, endSec, signal)

% 调试使用
% boutPeakSec = get_peak_per_bout(frameRateSignal, boutStartSec, boutEndSec, smoothdata(dffSignal, "gaussian", 300));
% frameRate = frameRateSignal;
% startSec = boutStartSec;
% endSec = boutEndSec;
% signal = smoothdata(dffSignal, "gaussian", 300);

lenSignal = length(signal);

peakSec = zeros([length(startSec) 1]);
for iter = 1:length(startSec)
    %iter
    left = max(1, round(startSec(iter)*frameRate));
    right = min(lenSignal, round(endSec(iter)*frameRate));
    [maxV maxT] = max(signal(left:right));
    %maxT
    peakSec(iter) = maxT / frameRate + startSec(iter);
end
%fig = figure('Visible', 'on');
%plot(signal);
end