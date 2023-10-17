
fileNames = ["test3.jpg","test1.jpg","test2.jpg","balls.JPG"];

SAT_TOL = [0.2,1];
BLUE = [0.55, 0.75]; % between these HUE values
GREEN = [0.25,0.5]; %between these HUE values
RED = [0.05,0.95]; % >=0.95 or =< 0.05

for i = 1:length(fileNames)
    fileName = fileNames(i);
    detectHSV(fileName,SAT_TOL,RED,GREEN,BLUE);
    w = waitforbuttonpress;
end 
detectHSV(fileName,SAT_TOL,RED,GREEN,BLUE)
function [] = detectHSV(fileName,SAT_TOL,RED,GREEN,BLUE)
RGB = imread(fileName); 
dim = size(RGB);
HSV = rgb2hsv(RGB);
HUE = HSV(:,:,1);
SAT = HSV(:,:,2);
VAL = HSV(:,:,3);

redMask = (HUE >= RED(1,2)) | (HUE <= RED(1,1)) & (SAT >=SAT_TOL(1,1) & SAT <=SAT_TOL(1,2));
blueMask = (HUE <= BLUE(1,2)) & (HUE >= BLUE(1,1))& (SAT >=SAT_TOL(1,1)&  SAT <=SAT_TOL(1,2)) ;
greenMask = (HUE <= GREEN(1,2)) & (HUE >= GREEN(1,1)) & (SAT >=SAT_TOL(1,1)&  SAT <=SAT_TOL(1,2));

structuringElement = strel('square', 5);
smallestAcceptableArea = 400;
redMask = cleanHSV(redMask,smallestAcceptableArea,structuringElement);
blueMask = cleanHSV(blueMask,smallestAcceptableArea,structuringElement);
greenMask = cleanHSV(greenMask,smallestAcceptableArea,structuringElement);

imshow(redMask);
masks = [redMask,greenMask,blueMask];
centroids = getCentroids(masks,dim)
plotOutput(centroids,masks,RGB,dim);

end 

function[mask] = cleanHSV(mask,smallestAcceptableArea,structuringElement)
mask = bwareaopen(mask, smallestAcceptableArea);
mask  = imclose(mask, structuringElement);
mask = imfill(mask, 'holes');

return
end 

function[centroids] = getCentroids(masks,dim)
centroids = zeros(2,3);
    lower = 1;
    upper = dim(1,2);
for i = 1:3
    masks(1:dim(1,1),lower:upper)
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

 subplot(2,2,1)
imshow(RGB); title('Original Image');
axis on 
hold on 

plot(centroids(1,:),centroids(2,:),'w*',MarkerSize=10);
hold off;
subplot(2,2,2),imshow(masks(1:dim(1,1),1:dim(1,2)) ); title('Blue block');
subplot(2,2,3),imshow(masks(1:dim(1,1),dim(1,2):dim(1,2)*2)); title('Green block');
subplot(2,2,4),imshow(masks(1:dim(1,1),dim(1,2)*2:dim(1,2)*3) ); title('Red block');
end 

function[] = plotBoundaries(masks)
[B,L] = bwboundaries(redMask,'noholes');

imshow(label2rgb(L, @jet, [.5 .5 .5]))

for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
end   
 [B,L] = bwboundaries(blueMask,'noholes');
  imshow(label2rgb(L, @jet, [.5 .5 .5]))

end 


