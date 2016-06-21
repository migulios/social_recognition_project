

function calcHeatMap(trackData,imData,clusterNum,sig,dtRes)


bigTime=[trackData.trackingTimeVector;imData.imagingTimeVector'];

[bigTime, sortInd]=sort(bigTime);

bigFishX=[trackData.fish_x; NaN(length(imData.imagingTimeVector),1)];
bigFishX=bigFishX(sortInd);

bigFishY=[trackData.fish_y; NaN(length(imData.imagingTimeVector),1)];
bigFishY=bigFishY(sortInd);

bigCluster=[NaN(length(trackData.trackingTimeVector),1);imData.dF_clusters(clusterNum,:)'];
bigCluster=bigCluster(sortInd);

firstGoodTrack=find(not(isnan(bigFishX)),1,'first');

bigCluster=naninterp(bigCluster(firstGoodTrack:end));
bigFishX=naninterp(bigFishX(firstGoodTrack:end));
bigFishY=naninterp(bigFishY(firstGoodTrack:end));
bigTime=bigTime(firstGoodTrack:end);
bigTime=bigTime-min(bigTime);

totLength=length(bigTime);
firstQL=length(bigTime(1:length(bigTime)/4));
seqtQL=length(bigTime(length(firstQL):length(bigTime)/2));
thirdQL=length(bigTime(length(seqtQL):length(bigTime)));

figure;
subplot(2,1,1)
plot(bigTime,bigFishX,'r')
hold on
plot(bigTime,bigFishY,'g')
subplot(2,1,2)
plot(bigTime,bigCluster,'g')

prefXPos=sum(bigFishX.*bigCluster)/sum(bigCluster);
prefYPos=sum(bigFishY.*bigCluster)/sum(bigCluster);

x=300:1100;
y=50:800;

[X,Y]=meshgrid(x,y);

heatMap=zeros(size(X));
lastTime=-dtRes;
for i=seqtQL:thirdQL
    if bigTime(i)-lastTime>=dtRes;
        heatMap=heatMap+bigCluster(i)*exp(-((X-bigFishX(i)).^2+(Y-bigFishY(i)).^2)./(2*sig^2));
        lastTime=bigTime(i)
    end
end

figure;
imagesc(heatMap)

end