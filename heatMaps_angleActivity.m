%%

bigTime=[trackData.trackingTimeVector;imData.imagingTimeVector'];

[bigTime, sortInd]=sort(bigTime);

bigFishX=[trackData.fish_x; NaN(length(imData.imagingTimeVector),1)];
bigFishX=bigFishX(sortInd);

bigFishY=[trackData.fish_y; NaN(length(imData.imagingTimeVector),1)];
bigFishY=bigFishY(sortInd);
firstGoodTrack=find(not(isnan(bigFishX)),1,'first');

bigFishX=naninterp(bigFishX(firstGoodTrack:end));
bigFishY=naninterp(bigFishY(firstGoodTrack:end));

nPixels=size(imData.dF_DATA,1);
for i=1:nPixels
    bigDFData(i,:)=[NaN(1,length(trackData.trackingTimeVector)),imData.dF_DATA(i,:)];
    bigDFData(i,:)=bigDFData(i,sortInd);
end

for o=1:nPixels
    bigDFData_new(o,:)=naninterp(bigDFData(o,firstGoodTrack:end));
end


bigTime=bigTime(firstGoodTrack:end);
bigTime=bigTime-min(bigTime);


matrix_angle=zeros(length(bigFishX),1);

centre_x=(min(trackData.fish_x)+max(trackData.fish_x))/2;
centre_y=(min(trackData.fish_y)+max(trackData.fish_y))/2;

for i=1:length(bigFishX)
    matrix_angle(i)=atan2(bigFishX(i)-centre_x,bigFishY(i)-centre_y);
end

matrix_angle(matrix_angle<0)=matrix_angle(matrix_angle<0)+2*pi;

matrix_angle_deg = matrix_angle*180/pi;

figure;
rose(matrix_angle,12);


%%

bin=1;
tau=10;

angles_ind=0:bin:359;



for a=1:length(angles_ind)
    angle_position{a}=find((matrix_angle_deg>angles_ind(a) & (matrix_angle_deg<(angles_ind(a)+tau))));
end

for i=1:size(angle_position,2)
    angle_position_mean{i} = nanmean(bigDFData_new(:,angle_position{1,i}),2); 
end

nBins=imData.header.nWidthBins*imData.header.nHeightBins;
binNumber=1:nBins;
                 
binNumber=reshape(binNumber,imData.header.nWidthBins,imData.header.nHeightBins)';

for caca=1:length(angles_ind)
    angle_position_activity{caca} = reshape(angle_position_mean{caca},size(binNumber,2),size(binNumber,1));
end


%%
v=VideoWriter('pene.avi');
open(v);

for pene=1:length(angle_position_activity)
    figure
    imagesc(angle_position_activity{pene}')
    hold on
    lineLength = 30;
    x= 30 + lineLength * cosd(pene); %centre_x
    y= 30 + lineLength * sind(pene); %centre_y 
    hold on;
    plot(x,y,'r-o','MarkerSize',20)
    %     polar(pene,'r-o')
    axis([-10 70 -20 70])
    writeVideo(v,getframe(gca))
    close
end
close(v)
%%






















