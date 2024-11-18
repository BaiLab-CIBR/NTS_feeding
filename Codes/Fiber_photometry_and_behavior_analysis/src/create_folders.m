function create_folders(filepath)
% Create output folders for input files.
% There are eight out output folders. Including:
% 1. raw signals of channel 1 and 3 of the assigned ROI.
% 2. events plotting.
% 3. combination of 1 and 2.
% 4. a heatmap for an experiment of a mouse.
% 5. PSTH of a mouse.
% 6. ... forgoten
% 7. average of heatmaps of mice.
% 8. average of PSTH of mice.
    function check_and_create(str)
        if exist(str, "dir") == 0
            mkdir(str)
        end
    end
cd(filepath); cd ..; cd ..;
check_and_create("rawdata");
check_and_create("analysedata");
check_and_create("metadata");
check_and_create("statsdata");

[~,dirname,~] = fileparts(filepath);
check_and_create("analysedata/"+dirname);
check_and_create("analysedata/"+dirname+"/pdf/");
check_and_create("analysedata/"+dirname+"/jpeg/");
% check_and_create("output\rawCalSignal");
% check_and_create("output\rawEvents");
% check_and_create("output\rawCalandEvents");
% check_and_create("output\heatmap");
% check_and_create("output\PSTH");
% check_and_create("output\zScore");
% check_and_create("output\deltaF");

% check_and_create("output\rawCalSignal\"+date);
% check_and_create("output\rawEvents\"+date);
% check_and_create("output\rawCalandEvents\"+date);
% check_and_create("output\heatmap\"+date);
% check_and_create("output\PSTH\"+date);
% check_and_create("output\zScore\"+date);
% check_and_create("output\deltaF\"+date);

% check_and_create("output\rawCalSignal\"+date+"\"+mouseID);
% check_and_create("output\rawEvents\"+date+"\"+mouseID);
% check_and_create("output\rawCalandEvents\"+date+"\"+mouseID);
% check_and_create("output\heatmap\"+date+"\"+mouseID);
% check_and_create("output\PSTH\"+date+"\"+mouseID);
% check_and_create("output\zScore\"+date+"\"+mouseID);
% check_and_create("output\deltaF\"+date+"\"+mouseID);
end