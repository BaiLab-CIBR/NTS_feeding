function plot_relation(folder, mouseListFile)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明
%% Check the data validity and read the data
if strcmp(extractBetween(mouseListFile, strlength(mouseListFile)-2, strlength(mouseListFile)), "txt") == true
    if exist("metadata/"+folder+"/"+mouseListFile, "file") == 0
        msg = "Error occured! The mouse list file does not exist!" + newline + " Reported by plot_relation.m";
        error(msg);
    end
    file = fopen("metadata/"+folder+"/"+mouseListFile, 'r');
    mouseList = {};
    while ~feof(file)
        mouseList(end+1) = {fgetl(file)};
    end
    mouseList = string(mouseList);
    for iter = 1:length(mouseList)
        if exist(mouseList(iter), "file") == false
            msg = "Error occured! The mouse data file does not exist!" + newline + " Reported by plot_relation.m";
            error(msg);
        end
    end
    mouseNum = length(mouseList);
elseif strcmp(extractBetween(mouseListFile, strlength(mouseListFile)-2, strlength(mouseListFile)), "mat") == true
    mouseNum = 1;
    if exist("analysedata/"+folder+"/"+mouseListFile, "file") == false
        msg = "Error occured! The mouse data file does not exist!" + newline + " Reported by plot_relation.m";
        error(msg);
    end
    mouseList = ["analysedata/"+folder+"/"+mouseListFile];
else
    msg = "Error occured! The mouse data file format is not valid!" + newline + " Reported by plot_relation.m";
    error(msg);
end
mouseDataList = {};
for iter = 1:mouseNum
    mouseDataList(end+1) = {load(mouseList(iter))};
end
%%
colorList = [114/256, 143/256, 206/256; 102/256, 205/256, 170/256; 255/256, 250/256, 205/256; 255/256, 255/256, 51/256; 170/256, 108/256, 57/256; 247/256, 93/256, 89/256; 105/256, 96/256, 236/256];
shapeList = ["o", "+", "*", "x", "^", "square", "diamond"];
calVar = ["meanBoutDFF", "maxBoutDFF", "halfwayTimeBoutDFF"];
evtVar = ["meanLRBout", "consumptionBout", "boutDuration"];
if mouseNum == 1
    pointNum = length(mouseDataList{1}.boutStartSec);
else
    pointNum = mouseNum;
end
calVal = zeros([3 pointNum]);
evtVal = zeros([3 pointNum]);
pColor = zeros([1 pointNum]);
if mouseNum == 1
    pColor(:) = mouseDataList{1}.stimType;
    for iter = 1:pointNum
        calVal(1, iter) = mouseDataList{1}.meanBoutDFF(iter);
        calVal(2, iter) = mouseDataList{1}.maxBoutDFF(iter);
        calVal(3, iter) = mouseDataList{1}.halfwayTimeBoutDFF(iter);
        evtVal(1, iter) = mouseDataList{1}.meanLRBout(iter);
        evtVal(2, iter) = mouseDataList{1}.consumptionBout(iter);
        evtVal(3, iter) = mouseDataList{1}.boutEndSec(iter) - mouseDataList{1}.boutStartSec(iter);
    end
else
    for iter = 1:pointNum
        pColor(iter) = mouseDataList{iter}.stimType;
        calVal(1, iter) = mean(mouseDataList{iter}.meanBoutDFF);
        calVal(2, iter) = mean(mouseDataList{iter}.maxBoutDFF);
        calVal(3, iter) = mean(mouseDataList{iter}.halfwayTimeBoutDFF);
        evtVal(1, iter) = mean(mouseDataList{iter}.meanLRBout);
        evtVal(2, iter) = mean(mouseDataList{iter}.consumptionBout);
        evtVal(3, iter) = mean(mouseDataList{iter}.boutEndSec(iter) - mouseDataList{1}.boutStartSec(iter));
    end
end
for x = 1:length(calVar)
    for y = 1:length(evtVar)
        fig = figure('visible', 'on');
        for p = 1:pointNum
            scatter(calVal(x,p), evtVal(y,p), [], colorList(pColor(p),:));%, shapeList(pColor(p)));
            hold on;
        end
        for l = 1:length(colorList)
            if length(pColor(pColor==l)) == 0
                break;
            end
            pList = find(pColor==l);
            mdl = fitlm(calVal(x,pList), evtVal(y,pList), RobustOpts="on");
            %mdl
            xlabel(calVar(x));
            ylabel(evtVar(y));
            title('Linear fit of calcium and events');
        end
        hold off;
    end
end

end