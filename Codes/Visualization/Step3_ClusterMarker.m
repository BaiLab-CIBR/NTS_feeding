%--------------------------------------------------------------------------
% Filename: ClusterMarker.m
% Author: Xinwei Gao 
% Email: gaoxinwei@cibr.ac.cn
% Date: 2023-10-12
%
% Description:
% This script visualizes cell clusters by mapping them onto an atlas image
% based on their cluster assignments. It reads cluster data from an Excel
% file, processes the data to assign cluster IDs to corresponding positions
% on the atlas, and generates a visual representation of the clusters.
%
% Steps:
% 1. Load cell cluster data from an Excel file and read the corresponding
%    raw image and atlas image.
% 2. Sort the data based on cluster assignments and extract positions for
%    each cluster.
% 3. Map each cluster onto the atlas by assigning cluster IDs to the
%    corresponding pixel positions.
% 4. Display and save the resulting cluster visualization as a TIFF image.
%
% Parameters:
% - n: The number of clusters present in the data. Adjust this value
%   according to your dataset.
%
% Note:
% - Ensure that file paths are correctly specified for your data files.
% - Adjust cluster visualization settings as needed for better clarity.
%
% Copyright (c) 2023 Xinwei Gao, Chinese Institute for Brain Research(CIBR), Beijing.
% All rights reserved.
%
%--------------------------------------------------------------------------

%%
clear all
clc
data=readtable('G:\Demo\Demo_1-1-3.xls');
image=imread('G:\Demo\1-1.tif');
image_atlas=imread('G:\Demo\Atlas.tif');
tempt=zeros(size(image_atlas));
n=19;%cluster number, you need edit it by yourself
cluster=1:1:n;
data_rank=sortrows(data,'new_seurat_clusters','descend');
data_cluster=data_rank.new_seurat_clusters;
%%
for i=1:length(cluster)
data_cluster_tempt=find(data_cluster==i);
start_p=min(data_cluster_tempt);
end_p=max(data_cluster_tempt);
cluster_position=[data_rank.CellPositionX(start_p:end_p),data_rank.CellPositionY(start_p:end_p)];
for j=1:size(cluster_position,1)
    tempt(round(cluster_position(j,2)),round(cluster_position(j,1)))=cluster(1,i);
end
end


%%
%show your results
figure(1)
imagesc(tempt)
imwrite(uint8(tempt),'Demo_1-1-3.tif','Compression','none')
% 
% figure(2)
% imshow(image)
% hold on
% axis off
% scatter(cluster_1_position(:,1),cluster_1_position(:,2),10,'red',"filled",'o','MarkerEdgeColor','none',MarkerFaceAlpha=0.5)
% hold on
% scatter(cluster_0_position(:,1),cluster_0_position(:,2),10,'green',"filled",'o','MarkerEdgeColor','none',MarkerFaceAlpha=0.5)
% hold on
% scatter(cluster_3_position(:,1),cluster_3_position(:,2),10,'blue',"filled",'o','MarkerEdgeColor','none',MarkerFaceAlpha=0.5)
