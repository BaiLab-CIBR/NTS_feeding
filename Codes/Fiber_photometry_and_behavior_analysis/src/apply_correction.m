function [correctedSignal, correctedControl, dffSignal, meanIntensity, stdIntensity] = apply_correction(controlSignal, expSignal, frameRate, fitControl, controlTime, fitBase, baseTh, minTh, windowLength, check)

% 调试用
% [correctedSignal, controlSignal, dffSignal, meanIntensity, stdIntensity] = apply_correction(baselineArr(round(startTime*frameRateSignal):round(stimEnd*frameRateSignal)), ...
%     eventCalArr(round(startTime*frameRateSignal):round(stimEnd*frameRateSignal)), frameRateSignal, fitControl, stimStart-startTime, fitBase, baseTh, minTh, windowLength, true);

% controlSignal = baselineArr(round(startTime*frameRateSignal):round(stimEnd*frameRateSignal));
% expSignal = eventCalArr(round(startTime*frameRateSignal):round(stimEnd*frameRateSignal));
% frameRate = frameRateSignal;
% controlTime = stimStart-startTime;
% check = 'true';


% Correction of the control signal.
% Fit the control signal to the event induced signal (EIS).
% controlSignal
% expSignal
% frameRate
% check
    function [outliers, index] = correct(control, signal, fitS, threshold, window)
        %control = smoothdata(control, "movmean", 50);
        %signal = smoothdata(signal, "movmean", 50);
        
        len = length(control);
        index = zeros([length(signal) 1]);
        minV = zeros([floor((len-1)/window)+1 1]);
        varV = zeros([floor((len-1)/window)+1 1]);
        meanV = zeros([floor((len-1)/window)+1 1]);
        range = max(signal) - min(signal);
        for iter = 1:window:len-window
            meanV(floor((iter-1)/window)+1)=mean(signal( floor(iter):floor(min(iter+window-1, len)) ));
            minV(floor((iter-1)/window)+1) = min(signal( floor(iter):floor(min(iter+window-1, len)) ));
            varV(floor((iter-1)/window)+1) = std(signal( floor(iter):floor(min(iter+window-1, len)) ));
        end
        for iter = 1:len
            %if signal(iter) < minV(floor((iter-1)/window)+1) + range*threshold
            if abs(signal(iter) - meanV(floor((iter-1)/window)+1)) < varV(floor((iter-1)/window)+1)*threshold
                index(iter) = iter;
                %if signal(iter) > 4.2
                %    meanV(floor((iter-1)/window)+1)
                %    varV(floor((iter-1)/window)+1)*threshold
                %end
            end
        end
        %figure();
        %plot(meanV);
        %figure();
        %plot(varV);
        index = index(index~=0);
        %length(index)
        if fitS == false
            index = 1:len;
        end
        %plot(signal(index));
        %f1 = fit(control(index), signal(index), 'poly1');
        %estim1 = feval(f1, control);
        %index = abs(estim1 - signal) > threshold * std(signal);
        %fileID = fopen("p.txt", "w");
        %for iter = 1:length(estim1)
        %    fprintf(fileID, "%f: %f\n", iter/15, abs(estim1(iter) - signal(iter)));
        %end
        %fclose(fileID);
        outliers = false([1 length(index)]);
        %if exclude == true
        %    outliers = excludedata(control, signal, 'indices', index);
        %else
        %    outliers = false([1 length(signal)]);
        %end
        %sum(outliers)
        %fileID = fopen("outliers.txt", "w");
        %for iter = 1:length(outliers)
        %    if outliers(iter) == true
        %        fprintf(fileID, "%f: %f\n", iter/15, signal(iter));
        %    end
        %end
        %fclose(fileID);
        %f2 = fit(control, signal, f1, 'Exclude', outliers);
    end

    function index = get_min(signal, threshold, window)
        len = length(signal);
        index = zeros([length(signal) 1]);
        minV = zeros([floor((len-1)/window)+1 1]);
        varV = zeros([floor((len-1)/window)+1 1]);
        meanV = zeros([floor((len-1)/window)+1 1]);
        range = max(signal) - min(signal);
        for iter = 1:window:len-window
            meanV(floor((iter-1)/window)+1)=mean(signal( floor(iter):floor(min(iter+window-1, len)) ));
            minV(floor((iter-1)/window)+1) = min(signal( floor(iter):floor(min(iter+window-1, len)) ));
            varV(floor((iter-1)/window)+1) = std(signal( floor(iter):floor(min(iter+window-1, len)) ));
        end
        for iter = 1:len
            if signal(iter) < minV(floor((iter-1)/window)+1) + range*threshold
            %if abs(signal(iter) - meanV(floor((iter-1)/window)+1)) < varV(floor((iter-1)/window)+1)*threshold
                index(iter) = iter;
                %if signal(iter) > 4.2
                %    meanV(floor((iter-1)/window)+1)
                %    varV(floor((iter-1)/window)+1)*threshold
                %end
            end
        end
        index = index(index~=0);
    end

    function ret = get_exp(timeIndex, signal)
        minV = min(signal);
        maxV = min(minV+1, max(signal));
        error = 10000000;
        for const = minV:0.05:maxV
            [mdl, gof] = fit(timeIndex, signal-const, 'exp1');
            if gof.sse < error
                error = gof.sse;
                ret = mdl;
            end
        end
    end

%% Set the default value of controlTime and check
if nargin < 4
    controlTime = false
end
if nargin < 5
    excludeExp = false
end
if nargin < 7
    check = false
end
%%
timeSeries = 0:1/frameRate:(length(controlSignal)-1)/frameRate;
if fitControl == false
    controlTimeIndex = 1:length(controlSignal);
else
    controlTimeIndex = 1:round(controlTime * frameRate);
    controlTimeIndex = max(1, controlTimeIndex);
    controlTimeIndex = min(length(controlSignal), controlTimeIndex);
end
% [params, estim] = polyfit(controlSignal(controlTimeIndex), expSignal(controlTimeIndex), 1);
controlSignalSmooth = smoothdata(controlSignal, "movmean", 10);
expSignalSmooth = smoothdata(expSignal, "movmean", 10);

timeSeriesForFit = timeSeries(controlTimeIndex);
controlSignalForFit = controlSignalSmooth(controlTimeIndex);
expSignalForFit = expSignalSmooth(controlTimeIndex);

indexMin = get_min(expSignalSmooth(round(controlTime*frameRate)+1:end), minTh, windowLength) + round(controlTime*frameRate);
[excepts, indexMean] = correct(controlSignalForFit, expSignalForFit, fitBase, baseTh, windowLength*frameRate);
%length(indexMin)
%length(controlTimeIndex)
%params = polyfit(timeSeries([indexMean; indexMin]), expSignal([indexMean; indexMin]), 1);
%tmp = polyval(params, timeSeries');
%expSignal = expSignal - tmp;
%param = polyfit(timeSeries([indexMean; indexMin]), controlSignal([indexMean; indexMin]), 1);
%tmp = polyval(params, timeSeries');
%controlSignal = controlSignal - tmp;
%size(timeSeriesForFit)
%size(timeSeries([indexMean; indexMin]))
%size(controlSignalForFit([indexMean; indexMin]))
%fControl = get_exp(timeSeries([indexMean; indexMin])', controlSignalSmooth([indexMean; indexMin]));
%fControl
%controlSignalSmooth = controlSignalSmooth - feval(fControl, timeSeries);
%controlSignal = controlSignal - feval(fControl, timeSeries);
%fExp = get_exp(timeSeries([indexMean; indexMin])', expSignalSmooth([indexMean; indexMin]));
%fExp
%expSignalSmooth = expSignalSmooth - feval(fExp, timeSeries);
%expSignal = expSignal - feval(fExp, timeSeries);

% correctedControl = polyval(params, controlSignal);
% correctedSignal = expSignal - polyval(params, controlSignal); ([controlTimeIndex; indexMin])
%f = fit(controlSignalSmooth([indexMean; indexMin]), expSignalSmooth([indexMean; indexMin]), 'poly1');
%correctedControl = feval(f, controlSignal);

f = polyfit(controlSignalSmooth([indexMean; indexMin]), expSignalSmooth([indexMean; indexMin]), 1);

% 如果只使用中心值进行拟合，使用这句
% f = polyfit(controlSignalSmooth(indexMean), expSignalSmooth(indexMean), 1);

correctedControl = polyval(f, controlSignal);
correctedSignal = expSignal - correctedControl;
correctedSignalForFit = correctedSignal(controlTimeIndex);
%params = polyfit(timeSeries([indexMean; indexMin]), correctedSignal([indexMean; indexMin]), 1);
%params = polyfit(timeSeriesForFit([indexMean]), correctedSignalForFit([indexMean]), 1);
%params
%tmp = polyval(params, timeSeries');
%correctedSignal = correctedSignal - tmp;
%fittype('a+b*exp(-c*x)'), 'StartPoint', [0.5, 10, 0.1],
%fDecay = fit(timeSeriesForFit(indexMin)', correctedSignalForFit(indexMin), fittype('a*x+b'), 'StartPoint', [-0.2, 0.2], 'Exclude', excepts);
%fDecay
%correctedSignal = correctedSignal - feval(fDecay, timeSeries);
%expSignalForFit(indexMin);

dffSignal = correctedSignal ./ correctedControl;
meanIntensity = mean(dffSignal(indexMean));
stdIntensity = std(dffSignal(indexMean));

% if check == true    %-----------------------------------------revised：注释掉了
%     fig = figure('visible', 'on');
%     %plot(timeSeriesForFit(indexMean), (correctedSignalForFit(indexMean)), timeSeriesForFit(indexMean), (correctedControl(indexMean)));
%     plot(expSignal([indexMean; indexMin]));
%     hold on;
%     plot(correctedControl([indexMean; indexMin]));
%     hold on;
%     plot(expSignal([indexMean; indexMin]) - correctedControl([indexMean; indexMin]));
% end

end