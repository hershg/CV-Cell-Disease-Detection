% Author: Hersh Godse
% Using:  http://www.mathworks.com/help/images/examples/correcting-nonuniform-illumination.html

%% Pre-configuration:
% Set current folder to file where image is
% Image should be called "fabric.png"

%% Get the image:
fabric = imread('fabric.png');
% figure(1), imshow(fabric), title('fabric');

%% Calculate sample colors in L*a*b color space for each image color
% L*a*b* space consists of luminosity/brightness L* layer, 
% chromaticity a* layer indicating where color falls along red-green axis, 
% and chromaticity b* layer indicating where color falls along blue-yellow axis.
% we want to find small sample region for each color, and calculate region's 
% avg color in a*b* space; will use these color markers to classify each image pixel
load regioncoordinates;

% n colors to segment image by (in this image case, 6)
nColors = 6;

% create empty matrix of dimentions image x, image y, n number of colors
sample_regions = false([size(fabric,1) size(fabric,2) nColors]);

% cycle through the n colors, in each loop change specific layer of sample_regions
% roipoly specifies polygonal region of interest (ROI) in image. returns
% binary image, which we will use as mask for filtering. ROI is object.
% the 2 vectors passed to roipoly in 2nd and 3rd arg create ROI defined
% by those 2 vectors. The 2 vectors specify column and row position,
% respectively, of each point in the ROI. Some points identical to create
% closed shape.
for count = 1:nColors
  c = region_coordinates(:,1,count);
  r = region_coordinates(:,2,count);
  sample_regions(:,:,count) = roipoly(fabric,c,r);
end
% imshow(sample_regions(:,:,2)),title('sample region for red');

% Convert RGB image into an L*a*b* image
lab = applycform(fabric, makecform('srgb2lab'));

% Calculate avg a*,b* value for each ROI from roipoly. These values function 
% as color markers in a*b* space.
L = lab(:,:,1);
a = lab(:,:,2);
b = lab(:,:,3);
color_markers = zeros([nColors, 2]);

% for each of n colors, for every pixel in image cooresponding to those in 
% color's ROI, put average a*/b* color in 1st/2nd column respectively
for count = 1:nColors
  color_markers(count,1) = mean2(a(sample_regions(:,:,count)));
  color_markers(count,2) = mean2(b(sample_regions(:,:,count)));
end

% Avg color of red sample region in a*b* space is
% fprintf('[%0.3f,%0.3f] \n',color_markers(2,1),color_markers(2,2));

%% Classify each pixel using nearest neighbor rule
% now we know a*,b* values for each color, use these to classify pixels of image
% for each pixel of image, get (a*,b*) coordinate. Calculate dist from this
% point to the 6 color marker points, shortest distance tells which color it is
% array containing color labels (0-black,1-red,2-green,3-purple,4-pink,5-yellow)
color_labels = 0:nColors-1;

% Initialize matrices to be used in nearest neighbor classification
a = double(a);
b = double(b);
distance = zeros([size(a), nColors]);

% Classify: for each of n colors, go through each pixel in image, calculate
% distance from pixel's a*,b* values and color marker values
% all distances stored in distance matrix
for count = 1:nColors
  distance(:,:,count) = ( (a - color_markers(count,1)).^2 + ...
                      (b - color_markers(count,2)).^2 ).^0.5;
end

% min inputs: find minimum of distance matrix in 3rd(z) axis. As all n
% distances are stacked in z axis, this finds smallest distance. Outputs:
% first parameter is for actual elements with minimum values, while second
% is for the position in the matrix of the elements. We don't need actual
% element values, so we remove this from output using ~ character
[~, label] = min(distance,[],3);

% now we have position of min elements, but these are from 1:6, while in
% color_labels we defined colors matching to number from 0:5. To make
% values of label matrix match to color they represent in color_labels, do
% the following (in effect, subtracts 1 from each element):
label = color_labels(label);
clear distance;

%% Display results of classification

% create matrix rgb_label (stacks 3 'label' matrixes in z axis) 
rgb_label = repmat(label,[1 1 3]);

% create empty 4D matrix, giving each pixel an nColors assignment spot
segmented_images = zeros([size(fabric), nColors],'uint8');

% for each of the n colors:
for count = 1:nColors
  % create temporary duplicate of image
  color = fabric;
  % wherever the label matrix of the image (rgb_label) doesn't match with
  % the color label we are looking for in this loop iteration (ex: 2 for
  % green, so wherever the label matrix is not 2, make 0). This removes all
  % of the image except for the specific color we are currently looking for
  color(rgb_label ~= color_labels(count)) = 0;
  % store the remaining part of image (only parts with color looking for
  % are left) in the 4th dimension of the matrix (this layer will
  % correspond to the current color we are scanning for)
  segmented_images(:,:,:,count) = color;
  % at end, the image will be split up into n layers, each with one of n colors
end

% Display all of the red portion of the image

subplot(3,2,1), imshow(segmented_images(:,:,:,1))
subplot(3,2,2), imshow(segmented_images(:,:,:,2))
subplot(3,2,3), imshow(segmented_images(:,:,:,3))
subplot(3,2,4), imshow(segmented_images(:,:,:,4))
subplot(3,2,5), imshow(segmented_images(:,:,:,5))
subplot(3,2,6), imshow(segmented_images(:,:,:,6))

% THIS DIDN'T WORK WELL BECAUSE THE ORIGINAL SAMPLES TAKEN WERE BAD, SegmentationTest2 Fixes this