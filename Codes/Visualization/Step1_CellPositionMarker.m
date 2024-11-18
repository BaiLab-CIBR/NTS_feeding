%--------------------------------------------------------------------------
% Filename: CellPositionMarker.m
% Author: Xinwei Gao 
% Email: gaoxinwei@cibr.ac.cn
% Date: 2023-10-12
% 
% Description:
% This script processes cell image data by reading cell positions and
% assigning intensity values from a specified range (1 to 65535) to each cell.
% It generates a new image file where each cell is represented with its 
% corresponding intensity, facilitating further analysis. The script also
% includes morphological operations to enhance cell visibility.
%
% Steps:
% 1. Read cell data from an Excel file and assign unique IDs.
% 2. Read the corresponding raw image file.
% 3. Encode intensity values for each cell and save the updated data.
% 4. Generate a new image with cells marked by their intensity values.
% 5. Save and display the processed image for verification.
%
% Copyright (c) 2023 Xinwei Gao, Chinese Institute for Brain Research(CIBR), Beijing.
% All rights reserved.
%--------------------------------------------------------------------------

clear all
clc
data=readtable('G:\Demo\Demo_1-1.xls');
data_ID=1:1:size(data,1);
data_ID=data_ID';
data_ID=array2table(data_ID);
data_ID.Properties.VariableNames={'Data_ID'};
image=imread("G:\Demo\1-1.tif");
num=size(data,1);
intensity=round(linspace(1,65535,num));
I=array2table(intensity');
I.Properties.VariableNames={'Intensity'};
data_new=[data,data_ID,I];
writetable(data_new,'Demo_1-1_1.xls');
%%
tempt=zeros(size(image));

% Intensity=data_new.data_ID;
X_P=data_new.CellPositionX;
Y_P=data_new.CellPositionY;
P_cell=[X_P,Y_P];
for i=1:size(data_new,1)
tempt(round(Y_P(i,1)),round(X_P(i,1)))=intensity(1,i);
se = strel('disk', 20); % 将大小设置为 5
% 对图像进行膨�?操作，并保持像素强度值不�?
J = imdilate(tempt, se, 'full');
end
Bit_tempt=uint16(J);
% length(find(Bit_tempt>0))
imwrite(Bit_tempt, 'Demo_1-1_1.tif', 'Compression', 'none');
% edges = edge(Bit_tempt, 'Sobel');
% filled = imfill(edges, 'holes');
% se = strel('square', 10);
% bw_dilated = imdilate(filled, se);
% aa=unique(J);
% bb=unique(tempt);
figure(1)
imshow(J)
hold on
figure(2)
imshow(image)
% imagesc(tempt)
% hold on
% scatter(round(X_P),round(Y_P),10,'red',"filled",'o','MarkerEdgeColor','none',MarkerFaceAlpha=0.5)

