test_1 = "test1.jpg";
test_2 ="test2.jpg";
test_3 = "test3.jpg";
cam = webcam(2);
img = snapshot(cam);

test_img = test_1;
%HSV = rgb2hsv(test_img);
fontsize = 12;
size(imread(test_1))
rgbImage = img
%[rgbImage, storedColorMap] = imread(test_img);
[rows, columns ,numberOfColorBands] = size(img);

redBand = rgbImage(:, :, 1);
greenBand = rgbImage(:, :, 2);
blueBand = rgbImage(:, :, 3);
redThresholdLow = 85;
redThresholdHigh = 255;
greenThresholdLow = 0;
greenThresholdHigh = 70;
blueThresholdLow = 0;
blueThresholdHigh = 90;
redMask = (redBand >= redThresholdLow) & (redBand <= redThresholdHigh);
greenMask = (greenBand >= greenThresholdLow) & (greenBand <= greenThresholdHigh);
blueMask = (blueBand >= blueThresholdLow) & (blueBand <= blueThresholdHigh);

redObjectsMask =(redMask & greenMask & blueMask);
blueObjectsMask =( greenMask & ~blueMask);
greenObjectsMask =( ~greenMask & blueMask);

subplot_rows = 3;
subplot_columns = 3;

subplot(subplot_columns,subplot_rows,1)
imshow(img)
title('Original', 'FontSize', fontsize    );
subplot(subplot_columns,subplot_rows,2)
imshow(redMask)
title('Not Red', 'FontSize', fontsize    );
subplot(subplot_columns,subplot_rows,3)
imshow(greenMask)
title('Not Green', 'FontSize', fontsize    );
subplot(subplot_columns,subplot_rows,4)
imshow(blueMask)
title('Not Blue', 'FontSize', fontsize    );
subplot(subplot_columns,subplot_rows,5)
imshow(redObjectsMask)
title('Red', 'FontSize', fontsize    );
subplot(subplot_columns,subplot_rows,6)
imshow(blueObjectsMask)
title('Blue', 'FontSize', fontsize    );
subplot(subplot_columns,subplot_rows,7)
imshow(greenObjectsMask)
title('Green', 'FontSize', fontsize    );


smallestAcceptableArea = 500;
figure;

redObjectsMask = bwareaopen(redObjectsMask, smallestAcceptableArea);
blueObjectsMask = bwareaopen(blueObjectsMask, smallestAcceptableArea);
greenObjectsMask = bwareaopen(greenObjectsMask, smallestAcceptableArea);
structuringElement = strel('disk', 4);

redObjectsMask = imclose(redObjectsMask, structuringElement);
blueObjectsMask = imclose(blueObjectsMask, structuringElement);
greenObjectsMask = imclose(greenObjectsMask, structuringElement);

%redObjectsMask = cast(redObjectsMask, class(redBand));
%blueObjectsMask = cast(blueObjectsMask, class(greenBand));
%greenObjectsMask = cast(greenObjectsMask, class(blueBand));
       [B,L] = bwboundaries(redObjectsMask,'noholes');
       imshow(label2rgb(L, @jet, [.5 .5 .5]))
       hold on
       for k = 1:length(B)
           boundary = B{k};
           plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2,'Color','r')
       end
       
 
%{
maskedImageR = redObjectsMask .* redBand;
maskedImageG = greenObjectsMask .* greenBand;
maskedImageB = blueObjectsMask .* blueBand;
maskedRcolour = cat(3, maskedImageR,~maskedImageB,~maskedImageG);
maskedGcolour = cat(3, ~maskedImageR,maskedImageB,~maskedImageG);
maskedBcolour = cat(3, ~maskedImageR,~maskedImageB,maskedImageG);

subplot(subplot_columns,subplot_rows,1)
imshow(maskedImageR)
title('Red', 'FontSize', fontsize    );
subplot(subplot_columns,subplot_rows,2)
imshow(maskedImageG)
title('Green', 'FontSize', fontsize );
subplot(subplot_columns,subplot_rows,3)
imshow(maskedImageB)
title('Blue', 'FontSize', fontsize);
subplot(subplot_columns,subplot_rows,3)
imshow(maskedImageB)
title('Red', 'FontSize', fontsize);
subplot(subplot_columns,subplot_rows,4)
imshow(maskedRcolour)

title('Red Colour', 'FontSize', fontsize);
subplot(subplot_columns,subplot_rows,5)
imshow(maskedBcolour)

title('Blue Colour', 'FontSize', fontsize);
subplot(subplot_columns,subplot_rows,6)
imshow(maskedGcolour)
title('Green Colour', 'FontSize', fontsize);

%}