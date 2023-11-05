fileNames = ["test1.jpg", "test3.jpg","test2.jpg","test4.jpg","test5.jpg","test6.jpg","test7.jpg",];

SAT_TOL = [0.2,1];
BLUE = [0.5, 0.75]; % between these HUE values
GREEN = [0.25,0.5]; %between these HUE values
RED = [0.05,0.96]; % >=0.95 or =< 0.05
for i = 1:length(fileNames);
    fileName = fileNames(i);
    detectHSV(fileName,SAT_TOL,RED,GREEN,BLUE);
    w = waitforbuttonpress;
end 

function [] = detectHSV(fileName,SAT_TOL,RED,GREEN,BLUE ); %fileName  %,BLUE_BOT_COORDS_GREEN_BOT_COORDS


RGB = imread(fileName); 
dim = size(RGB);
HSV = rgb2hsv(RGB);
imshow(HSV);
HUE = HSV(:,:,1);
SAT = HSV(:,:,2);
VAL = HSV(:,:,3);

redMask = (HUE >= RED(1,2)) | (HUE <= RED(1,1)) & (SAT >=SAT_TOL(1,1) & SAT <=SAT_TOL(1,2));
blueMask = (HUE <= BLUE(1,2)) & (HUE >= BLUE(1,1))& (SAT >=SAT_TOL(1,1)&  SAT <=SAT_TOL(1,2)) ;
greenMask = (HUE <= GREEN(1,2)) & (HUE >= GREEN(1,1)) & (SAT >=SAT_TOL(1,1)&  SAT <=SAT_TOL(1,2));
structuringElement = strel('square', 5);
smallestAcceptableArea = 1000;
redMask = cleanHSV(redMask,smallestAcceptableArea,structuringElement);
blueMask = cleanHSV(blueMask,smallestAcceptableArea,structuringElement);
greenMask = cleanHSV(greenMask,smallestAcceptableArea,structuringElement);


masks = [redMask,greenMask,blueMask];
centroids = getCentroids(masks,dim) %obtains the pixel coordiantes of red green and blue blocks
disp(['Red (',int2str(centroids(1,1)),',', int2str(centroids(2,1)),')'])
disp(['Green (',int2str(centroids(1,2)),',', int2str(centroids(2,2)),')'])
disp(['Blue (',int2str(centroids(1,3)),',', int2str(centroids(2,3)),')'])
 

plotOutput(centroids,masks,RGB,dim);

end 

function[mask] = cleanHSV(mask,smallestAcceptableArea,structuringElement);
mask = bwareaopen(mask, smallestAcceptableArea);
mask  = imclose(mask, structuringElement);
mask = imfill(mask, 'holes');

return
end 

function[centroids] = getCentroids(masks,dim);
centroids = zeros(2,3);
    lower = 1;
    upper = dim(1,2);
for i = 1:3
    masks(1:dim(1,1),lower:upper);
    [y, x] = find( masks(1:dim(1,1),lower:upper));
    centroids(1,i) = round(mean(x));
    centroids(2,i) = round(mean(y));
    lower = upper;
    upper = upper+ dim(1,2);
end 
return 
end 
                                    %in order  RGB
                                    function[] = plotOutput(centroids, masks,RGB,dim)
 
subplot(2,3,1)
imshow(RGB); title('Original Image');
axis on
hold on
 
plot(centroids(1,:),centroids(2,:),'w*',MarkerSize=10);
hold off;
subplot(2,3,2)
HSV = rgb2hsv(RGB);
imshow(HSV);
title('HSV Image');
 
subplot(2,3,3),imshow(masks(1:dim(1,1),1:dim(1,2)) ); title('Red block');
subplot(2,3,4),imshow(masks(1:dim(1,1),dim(1,2):dim(1,2)*2)); title('Green block');
subplot(2,3,5),imshow(masks(1:dim(1,1),dim(1,2)*2:dim(1,2)*3) ); title('Blue block');
end

function[] = plotBoundaries(masks)
[B,L] = bwboundaries(redMask,'noholes');

imshow(label2rgb(L, @jet, [.5 .5 .5]))

for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
end   
 [B,L] = bwboundaries(blueMask,'noholes');
  imshow(label2rgb(L, @jet, [.5 .5 .5]));

end 

