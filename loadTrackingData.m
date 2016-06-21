function trackData=loadTrackingData(gpioData,allData)


if size(gpioData,1)>size(allData,1)
    gpioData=gpioData(1:(end-1),:);
end

firstTimeInd=find(gpioData.gpio,1,'first');

for i=1:size(allData,1)
    time_aux=allData.time{i};
    hour(i,1)=str2num(time_aux(12:13));
    minute(i,1)=str2num(time_aux(15:16));
    second(i,1)=str2num(time_aux(18:23));
end
hour=hour-min(hour);
minute=minute+hour*60;
minute=minute-min(minute);
second=second+minute*60;

second=second(firstTimeInd:end);

second=second-min(second);

fish_x=allData.x(firstTimeInd:end);
fish_y=allData.y(firstTimeInd:end);

nTranspIter=1;
nCorr=20;
for i=1:nTranspIter
    speed_x=diff(fish_x);
    speed_y=diff(fish_y);
    
    fish_speed=sqrt(speed_x.^2+speed_y.^2);
    
    teletransportation=find(fish_speed>200);
    
    for j=1:length(teletransportation)
        fish_x(teletransportation(j)+1:teletransportation(j)+nCorr)=fish_x(teletransportation(j)-1);
        fish_y(teletransportation(j)+1:teletransportation(j)+nCorr)=fish_y(teletransportation(j)-1);
    end
end

figure;
plot(second(2:end),fish_speed);
figure
hist(fish_speed)

figure;
plot(second,fish_x,'-r')
hold on
plot(second,fish_y,'-b')

figure;
plot(fish_x,fish_y)

trackData.fish_x=fish_x;
trackData.fish_y=fish_y;
trackData.second=second;

end


