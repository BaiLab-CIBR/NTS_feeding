function run_account_trials_data()
% (folder, mouseListFile, boutCounted, manualPSTHX, manualDFFY, manualZY, showAllErr, showPSTHErr, skipPlot)
folder = "WHY0089";
mouseListFile = "list.txt";
boutCounted = [1 2 3 4 5 -5 -4 -3 -2 -1];
manualPSTHX = false;
manualDFFY = false;
manualZY = false;
showAllErr = true;
showPSTHErr = true;
timeScale = 'm';
skipPlot = false;
account_trials_data(folder, mouseListFile, boutCounted, manualPSTHX, manualDFFY, manualZY, showAllErr, showPSTHErr, timeScale, skipPlot);