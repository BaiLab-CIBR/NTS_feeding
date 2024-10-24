%%
clear all
clc
data=readtable('F:\spots-test\first\total_date\1-1_dapi_chat_nissl_gcg_Excitatory_step2_2.xls');
image=imread('F:\spots-test\first\raw_figure\1-1_dapi_chat_nissl_gcg.tif');
image_atlas=imread('F:\spots-test\first\raw_figure\1-1_dapi_chat_nissl_gcg.tif');
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
cluster_position=[data_rank.Cell_Position_X(start_p:end_p),data_rank.Cell_Position_Y(start_p:end_p)];
for j=1:size(cluster_position,1)
    tempt(round(cluster_position(j,2)),round(cluster_position(j,1)))=cluster(1,i);
end
end


%%
%show your results
figure(1)
imagesc(tempt)
imwrite(uint8(tempt),'1-1_dapi_chat_nissl_gcg_Excitatory_step2_2.tif','Compression','none')
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
