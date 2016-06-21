

function trackData=synchData(imData, trackData)


lastImageSecond=imData.imagingTimeVector(end);
lastFrameTracking=find(trackData.second>lastImageSecond,1,'first');

trackData.trackingTimeVector=trackData.second(1:lastFrameTracking);
trackData.fish_x=trackData.fish_x(1:lastFrameTracking);
trackData.fish_y=trackData.fish_y(1:lastFrameTracking);


figure;
subplot(2,1,1)
plot(repmat(imData.imagingTimeVector,imData.header.nClusters,1)',imData.dF_clusters');
subplot(2,1,2)
plot(trackData.trackingTimeVector,trackData.fish_x,'-r')
hold on
plot(trackData.trackingTimeVector,trackData.fish_y,'-g')

end