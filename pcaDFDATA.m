%# Function for the pca by cluster
% we need the imaging data and the numbers of clusters
function imData=pcaDFDATA(imData, n_clusters)

%# Smoothing the signal before pca
n_smooth=6;

for i = 1: size(imData.dF_DATA,1)
    dF_DATA_smooth (i,:) = smooth (imData.dF_DATA(i,:),n_smooth);
end

%# pca 
[pca_coeff,pca_values,~,~,pca_var]=pca(dF_DATA_smooth);

%CLustering 
clusterColour=colormap(jet(n_clusters));
clusters_id=kmeans(pca_values,n_clusters);

figure;
for i=1:n_clusters
    plot(pca_values(clusters_id==i,1),pca_values(clusters_id==i,2),'.','color',clusterColour(i,:))
hold on
end

clusters_idMat=reshape(clusters_id,imData.header.nWidthBins,imData.header.nHeightBins);
figure;imagesc(clusters_idMat')
colormap(clusterColour)

for i=1:n_clusters
   dF_clusters(i,:)= mean(imData.dF_DATA(clusters_id==i,:));
end

figure;
imagesc(dF_clusters);

figure;
plot(dF_clusters');

imData.dF_clusters=dF_clusters;
imData.header.nClusters=n_clusters;
imData.clusterID=clusters_id;
imData.header.clusterImage=clusters_idMat;
imData.header.pca_values=pca_values;

figure,
subplot(2,2,1)
plot(imData.dF_clusters(1,:),'y')
subplot(2,2,2)
plot(imData.dF_clusters(2,:),'r')
subplot(2,2,3)
plot(imData.dF_clusters(3,:),'g')
subplot(2,2,4)
plot(imData.dF_clusters(4,:),'b')

figure,
plot(imData.header.pca_values(1:4,:)')

end
