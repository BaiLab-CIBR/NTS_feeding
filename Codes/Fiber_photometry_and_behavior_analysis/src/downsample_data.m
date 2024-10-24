function downsampled = downsample_data(filepath,filename,originFR,targetFR)

% downsampled = downsample_data(filepath,accurateEventsFile,frameRateAcc,frameRateEvent);
% filename = accurateEventsFile;
% originFR = frameRateAcc;
% targetFR = frameRateEvent;

% % inputs,
% filepath = '/Users/qiushiwang/Desktop/src_revised/rawdata/2023_03_13_WHY0244';
% filename = 'signal-Event.csv';  
% originFR = 1000; % original frame rate of the raw file.                                  
% targetFR = 15; % target frame rate of the downsampled file.   

file_full = [filepath,filesep,filename];
file = readtable(file_full);
h = height(file);
w = width(file);
varTypes = string(w);
for iter = 1:w
    varTypes(iter) = "int8";
end

rawMat = table2array(file);
dsMat = zeros([int32(h*targetFR/originFR)+1, w]);
for colIter = 1:w
    for rowIter = 1:h
        mappedIndex = int32(rowIter*targetFR/originFR)+1;
        dsMat(mappedIndex, colIter) = dsMat(mappedIndex, colIter) + rawMat(rowIter, colIter);
    end
end
h = int32(h*targetFR/originFR)+1;
% for colIter = 1:w
%     for rowIter = 1:h
%         if dsMat(rowIter, colIter) >= originFR/(targetFR*2)
%             dsMat(rowIter, colIter) = 1;
%         else
%             dsMat(rowIter, colIter) = 0;
%         end
%     end
% end
downsampled = array2table(dsMat, 'VariableNames', file.Properties.VariableNames);

[f,n,e] = fileparts(file_full);
writetable(downsampled, append(f, filesep, n, "_FR_", num2str(targetFR), e));

end