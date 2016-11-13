% Author: Hersh Godse
% Using:  http://www.mathworks.com/help/images/examples/color-based-segmentation-using-k-means-clustering.html

%% Pre-configuration:
% Set current folder to file where image is
% Image should be called "hestain.png"

%% Get the image:
he = imread('sickle.png');
%{
% imshow(he), title('H&E image');
  text(size(he,2),size(he,1)+15,...
	 'Image courtesy of Alan Partin, Johns Hopkins University', ...
	 'FontSize',7,'HorizontalAlignment','right');
%}

%% Convert Image from RGB Color Space to L*a*b* Color Space
% See program SegmentationTest for explanation of L*a*b* color space
cform = makecform('srgb2lab');
lab_he = applycform(he,cform);

%% Classify colors in image in L*a*b* via K-Means Clustering
% Clustering tries to separate groups of objects. K-means clustering treats
% every object as having location in space. It finds partitions such that
% objects within each cluster are as close to each other in space and as 
% far away from objects in other clusters in space as possible. It requires
% the number of clusters to partition the image into, and a distance metric
% quantifying how close two objects are to each other.

% Since actual color info is in a*b* space, subset that part of lab_he
% Reshape this ab subset to feed into kmeans function (see line 47-48)
ab = double(lab_he(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);

% For every object in input, kmeans returns index corresponding to a
% cluster. cluster_center gives coordinates of each cluster's centroid.
% Inputs: segment image ab into nColors partitions. Set distance values in
% the clustering as default squared Euclidean distances. Repeat clustering 
% 3 times to avoid local minima(?)
nColors = 2;
[cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                                      'Replicates',2);

%% Label every pixel in the image with its cluster_index.
% Also, reshape the indexes back into image dimensions (undoing line 31-32)
% Display image with different greyscale color for each index
pixel_labels = reshape(cluster_idx,nrows,ncols);
% imshow(pixel_labels,[]), title('image labeled by cluster index');


%% Create images segmenting original image by color
% Using pixel_labels, separate objects in he image by color, making 3 images
% Make empty 1x3 array, 'stack' pixel_labels 3 times
segmented_images = cell(1,nColors);
rgb_label = repmat(pixel_labels,[1 1 nColors]);

% for each color, duplicate the original image, make all parts of the image
% not containing the index we are currently looking for 0(false), leaving
% a segmented image layer behind. Place the nColor image layers in
% segmented_images, and display.
for k = 1:nColors
    color = he;
    color(rgb_label ~= k) = 0;
    segmented_images{k} = color;
end

% subplot(1,2,1), imshow(segmented_images{1}), title('objects in cluster 1');
% subplot(1,2,2), imshow(segmented_images{2}), title('objects in cluster 2');

% num1 and num2 are number of pixels in each layer. Layer with less pixels
% is layer with cells
im1 = he;
im1(rgb_label ~= 1) = 0;
BW1 = im2bw(im1,0.4);
num1 = sum(BW1(:));
im2 = he;
im2(rgb_label ~= 2) = 0;
BW2 = im2bw(im2,0.4);
num2 = sum(BW2(:));

% Save layer of cells (going by above logic) as image 'cells'
if num1 < num2
    cells = BW1;
else
    cells = BW2;
end

% imshow(cells)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bw = cells;
bw = bwareaopen(bw, 400);
% imshow(bw)

% fill gaps
se = strel('disk',2);
% bw = imclose(bw,se);

% fill any holes
bw = imfill(bw,'holes');
bw = imclearborder(bw);
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
RGB_label = label2rgb(labeled, @lines, 'k', 'shuffle');
imshow(RGB_label)

%% Calculate area of each object
% regionprops gives area of connected components in cc structure. Output is
% 1.Area of each cc in pixels, 2. coordinates of the smallest rectangle
% that can be fitted within the cc, 3. coordinates of the center of mass of the cc
graindata = regionprops(cc,'basic');
% graindata(50).Area