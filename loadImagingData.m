
function imData=loadImagingData(binSize)

fileNames = {'f1(00002).tif','f1(00003).tif','f1(00004).tif','f1(00005).tif'}; %,...


nFiles=length(fileNames);
tiffInfo = imfinfo(fileNames{1});

testFrame=imread(fileNames{1},'Index',1,'Info',tiffInfo);

figure;
imagesc(testFrame);
corners=ginput(2);
corners=round(corners/binSize)*binSize;

crop_x=corners(:,1)'
crop_y=corners(:,2)'

width=tiffInfo(1).Width;
height=tiffInfo(1).Height;

new_width=crop_x(2)-crop_x(1)+1;
new_height=crop_y(2)-crop_y(1)+1;

widthBins=1:binSize:(new_width+1);
heightBins=1:binSize:(new_height+1);

nWidthBins=length(widthBins)-1;
nHeightBins=length(heightBins)-1;

nBins=nWidthBins*nHeightBins;

for k=1:nFiles
    tiffInfo = imfinfo(fileNames{k});
    no_frame(k) = numel(tiffInfo);    %# Get the number of images in the file
end

totFrames=sum(no_frame);

binCell=zeros(nWidthBins,nHeightBins,totFrames);

for k=1:nFiles
    tiffInfo = imfinfo(fileNames{k});
    no_frame(k) = numel(tiffInfo);    %# Get the number of images in the file
    matrix_video = uint16(zeros(new_height,new_width,no_frame(k)));      %# Preallocate the movie
    
    for iFrame = 1:no_frame(k)
        tempFrame=imread(fileNames{k},'Index',iFrame,'Info',tiffInfo);
        matrix_video(:,:,iFrame) = tempFrame(crop_y(1):crop_y(2),crop_x(1):crop_x(2));
    end
    for w=1:nWidthBins
        for h=1:nHeightBins
            binCell(w,h,(sum(no_frame(1:k))-no_frame(k)+1):sum(no_frame(1:k)))= squeeze(mean(mean(matrix_video(heightBins(h):heightBins(h+1)-1,...
                widthBins(w):widthBins(w+1)-1,:),1),2));
        end
    end
end

meanImage=mean(binCell,3);

figure;
imagesc(mean(binCell,3)')

binNumber=1:nBins;

binNumber=reshape(binNumber,nWidthBins,nHeightBins)';

binMovieMatrix=reshape(binCell,size(binNumber,2)*size(binNumber,1),[]);

figure;
imagesc(binMovieMatrix)

figure;
imagesc(binNumber)
colormap(jet(128))

imagingFR = 30.30; %Frames per secons
imagingDT= 1/imagingFR;
tau1 = 10;%ceil(200/no_frame); %smoothing window (how many points to smooth)
tau2 = 100;%ceil(1200/no_frame); %window to calculate F0

for file_counter = 1:size(binMovieMatrix,1)
    avg_mat = tsmovavg(binMovieMatrix(file_counter,:),'s',tau1,2); %this smooths raw trace by 'tau1' window
    
    for t = (tau2+1):size(binMovieMatrix,2)
        roi_fzero(file_counter,t) = min(avg_mat(abs(t-tau2):t)); %takes the min (==F0) of window 'tau2' for timepoint 't'
    end
end

dF_DATA = (binMovieMatrix-roi_fzero)./roi_fzero; %this calculates DF/F
dF_DATA = dF_DATA(:,(tau2+1):end);

imagingTimeVector=0:imagingDT:(totFrames*imagingDT);
imagingTimeVector=imagingTimeVector(1:size(dF_DATA,2));

figure, plot(dF_DATA')
figure, imagesc(dF_DATA)

max_resp=max(dF_DATA,[],2);
max_respMat=reshape(max_resp,size(binNumber,2),size(binNumber,1));

figure; imagesc(max_respMat')


imData.dF_DATA=dF_DATA;
imData.header.width=new_width;
imData.header.height=new_height;
imData.header.nWidthBins=nWidthBins;
imData.header.nHeightBins=nHeightBins;
imData.header.binSize=binSize;
imData.header.nFrames=totFrames;
imData.header.meanImage=meanImage;
imData.header.maxImage=max_respMat;
imData.header.imagingFR=imagingFR;
imData.header.imagingDT=imagingDT;
imData.imagingTimeVector=imagingTimeVector;


end