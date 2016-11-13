% Author: Hersh Godse
% Using:  http://www.mathworks.com/help/images/examples/correcting-nonuniform-illumination.html

%% Pre-configuration:
% Set current folder to file where image is
% Image should be called "rice1.png"

%% Get the image:
I = imread('695.jpg');
imshow(I)

%{
%% Calculate background of image using imopen (morphological opening)
%%%%%%%%%%%%%%%%%%%%%%%%%%UNDERSTAND SYNTAX%%%%%%%%%%%%%%%%%%%%%%%%%%
background = imopen(I,strel('disk',15));

% Display the background approximation as a surface
%%%%%%%%%%%%%%%%%%%%%%%%%%UNDERSTAND SYNTAX%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
surf(double(background(1:8:end,1:8:end))),zlim([0 255]);
ax = gca;
ax.YDir = 'reverse'; 

%% Remove the calculated background from the image
I2 = I - background;
imshow(I2)
%}

%% Alternatively, use imtophat
% Calculates morphological opening and removes from image:
%%%%%%%%%%%%%%%%%%%%%%%%%%UNDERSTAND SYNTAX%%%%%%%%%%%%%%%%%%%%%%%%%%
I2 = imtophat(I,strel('disk',15));
% imshow(I2)

%% Convert image from RGB format to grayscale
% Do this because later processing requires grayscale images
% As can see in workspace variables, RGB image has three layers (R,G,B),
% whereas grayscale image has one layer (compare I2,I3 variable dimensions)
I3 = rgb2gray(I2);
% imshow(I3)

%% Increase contrast of image
I4 = imadjust(I3);
imshow(I4)

%% Threshold image, convert to binary file (only black, white)
% graythresh computes global threshold, which we use to convert image with
% grayscale intensity to a binary image with im2bw
% Then, bwareopen removes background noise (removes objects with fewer than 50 pixels)
level = graythresh(I4);
bw = im2bw(I4,level);
bw = bwareaopen(bw, 50);
imshow(bw)

%% Identify objects in image
% bwconncomp finds all Connected Components (objects) in the binary image
% The accuracy of bwconncomp depend on size of objects, connectivity parameter 
% (4/8 for 2D image), and if objects are touching (could be labeled as one object)
% Outputs: 1.connectivity of connected components, 2.size of scanned image,
% 3.number of detected objects, 4.array of length(number of objects), kth
% element is vector with pixels in kth object
cc = bwconncomp(bw, 4);
% Print connected components structure
% cc
% Print array containing pixels in objects
% cc.PixelIdxList
% Print pixels in 5th object
% cc.PixelIdxList{5}

%% Examine one object
grain = false(size(bw)); % Create 2D matrix of size of bw, false to make all black
grain(cc.PixelIdxList{12}) = true; % In matrix, make true wherever pixel of object detected
% imshow(grain); % Show image, false/0 -> background; true/1 -> object

%% View all objects
% A label matrix is matrix of same size as input matrix. Input matrix has
% 1s to represent pixels where an object is, 0s to represent bkgnd. In
% label matrix, all pixels of different cc/object are given the same,
% unique label (all pixels in cc 1 are stored as 1, in cc 2 as 2, ...)
% We will now create a label matrix from output of bwconncomp using labelmatrix
labeled = labelmatrix(cc);
% whos labeled

% Convert label matrix into RGB image. @summer references set of colors
% Matlab will use to color each object in the label matrix. 'shuffle' will
% make matlab randomly assign colors to objects. The RGB triplet sets
% color for bkgnd
RGB_label = label2rgb(labeled, @summer, [.863 .529 1], 'shuffle');
% imshow(RGB_label)

%% Calculate area of each object
% regionprops gives area of connected components in cc structure. Output is
% 1.Area of each cc in pixels, 2. coordinates of the smallest rectangle
% that can be fitted within the cc, 3. coordinates of the center of mass of the cc
graindata = regionprops(cc,'basic');
% graindata(50).Area

%% Calculate area-based statistics
% subset graindata to just get the area calculations
grainareas = [graindata.Area];
% Find smallest and largest grains (gets pixel area and index in array)
[min_area, idxmin] = min(grainareas);
[max_area, idxmax] = max(grainareas);
grain2 = false(size(bw));
grain2(cc.PixelIdxList{idxmin}) = true;
grain2(cc.PixelIdxList{idxmax}) = true;
% imshow(grain2);

%% Create histogram of areas
%{
nbins = 20;
figure, hist(grainareas, nbins)
title('Histogram of Rice Grain Area')
xlabel('Pixel Area of Closed Objects')
ylabel('Number Closed Objects in Bin')
%}