% Author: Hersh Godse

%% Pre-configuration:
% Set current folder to file where image is
% Image should be called "coins.png"

%% Get the image:
A = imread('coins.png');
imshow(A)

%% Get circles
% Input: A is image to scan, finding circles with 15 ? r ? 30
% Output variables: center, radius, 
[centers, radii, metric] = imfindcircles(A,[15 30]);

centersStrong5 = centers(1:5,:);
radiiStrong5 = radii(1:5);
metricStrong5 = metric(1:5);

viscircles(centersStrong5, radiiStrong5,'EdgeColor','b');