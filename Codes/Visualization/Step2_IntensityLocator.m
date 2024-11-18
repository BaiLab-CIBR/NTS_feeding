%--------------------------------------------------------------------------
% Filename: Step2_IntensityLocator.m
% Author: Xinwei Gao 
% Email: gaoxinwei@cibr.ac.cn
% Date: 2023-10-12
% 
% Description:
% This script processes a transformed cell image and extracts the positions
% of cells based on their intensity values. It identifies unique intensity
% values that correspond to cell markers and calculates the average position
% for each intensity, outputting the results to an Excel file.
%
% Steps:
% 1. Read the transformed image data and identify unique intensity values.
% 2. Read the original intensity data from an Excel file and find common
%    intensities between the transformed image and original data.
% 3. For each unique intensity, calculate the average position of the
%    corresponding pixels and store the results in a structured format.
% 4. Save the extracted positions and IDs to an Excel file for further analysis.
%
% Parameters:
% - pixel_size: The size of each pixel, used for scaling positions.
%
% Note:
% - Ensure that the file paths are correctly set for your data files.
% - Modify 'pixel_size' as needed based on your image resolution.
%
% Copyright (c) 2023 Xinwei Gao, Chinese Institute for Brain Research(CIBR), Beijing.
% All rights reserved.
%--------------------------------------------------------------------------

clear all
clc
data=imread('G:\Demo\TransformedDemo_1-1_1.tif');
list_transform=unique(data);
data_LIST=readtable('G:\Demo\Demo_1-1_1.xls');
intensity_raw=data_LIST.Intensity;
intensity=intersect(intensity_raw,list_transform);
%%
pixel_size=1;
% image=imread('path');
% intensity=round(linspace(1,65535,(size(list,1)-1)));
num=length(intensity);
T=zeros(size(data));
% list=unique(data);
disp(num2str(num));
disp(num2str(length(intensity)));


%     edges = edge(data, 'Sobel');
%     filled = imfill(edges, 'holes');
%     se = strel('square', 100);
%     bw_dilated = imdilate(filled, se);
%     imshow(bw_dilated)
  %%  

for i=1:num
[row,col]=find(data==intensity(i));
posititon(i).row=round(mean(col))*pixel_size;
posititon(i).col=round(mean(row))*pixel_size;
posititon(i).ID=i;
end
table_data = struct2table(posititon);
%%
filename = 'Demo_1-1_2.xls';
writetable(table_data, filename, 'Sheet', 'Sheet1', 'Range', 'A1');





% for i=1:num
%   [row, col]=find(data==i); 
%   position(i).row=col*353;
%   position(i).col=row*353; 
%   position(i).ID=i;
%   
% 
% end
% position=[position_X,position_Y];
% 
% 
% 
% 
% edges = edge(Bit_tempt, 'Sobel');
% filled = imfill(edges, 'holes');
% se = strel('square', 10);
% bw_dilated = imdilate(filled, se);
% figure(1)
% imshow(bw_dilated)
% hold on
% figure(2)
% imshow(image)
