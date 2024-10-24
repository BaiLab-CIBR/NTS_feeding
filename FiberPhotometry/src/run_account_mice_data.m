function run_account_mice_data()
% (folder, mouseListFile, boutCounted, manualPSTHX, manualDFFY, manualZY, showAllErr, showPSTHErr, skipPlot)
folder = "ff";
mouseListFile = "list.txt";
boutCounted = [1 2 3 4 -4 -3 -2 -1];
manualPSTHX = false;
manualDFFY = false;
manualZY = false;
showAllErr = true;
showPSTHErr = true;
timeScale = 'm';
skipPlot = false;
account_mice_data(folder, mouseListFile, boutCounted, manualPSTHX, manualDFFY, manualZY, showAllErr, showPSTHErr, timeScale, skipPlot);