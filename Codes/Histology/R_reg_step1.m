clear all
clc
data=readtable('F:\spots-test\second\total_date\Batch2_Leve3_New surface_all spots_EX_IhI_Chat-2.0_1.xls');
data_ID=1:1:size(data,1);
data_ID=data_ID';
data_ID=array2table(data_ID);
data_ID.Properties.VariableNames={'Data_ID'};
image=imread("F:\spots-test\second\raw_figure\2-2_dapi_chat_nissl_vglut3.tif");
num=size(data,1);
intensity=round(linspace(1,65535,num));
I=array2table(intensity');
I.Properties.VariableNames={'Intensity'};
data_new=[data,data_ID,I];
writetable(data_new,'Batch2_Leve3_New surface_all spots_EX_IhI_Chat-2.0_1.xls');
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
imwrite(Bit_tempt, 'Batch2_Leve3_New surface_all spots_EX_IhI_Chat-2.0_1.tif', 'Compression', 'none');
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

