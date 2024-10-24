clear all
clc
data=imread('F:\spots-test\TransformedBatch2_Leve3_New surface_all spots_EX_IhI_Chat-2.0_1.tif');
list_transform=unique(data);
data_LIST=readtable('F:\spots-test\Batch2_Leve3_New surface_all spots_EX_IhI_Chat-2.0_1.xls');
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
filename = 'Batch2_Leve3_New surface_all spots_EX_IhI_Chat-2.0_1_step2.xls';
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
