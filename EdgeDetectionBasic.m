% Author: Hersh Godse
% Using:  https://cs.uwaterloo.ca/~jorchard/cs473/video_lectures/L22_Edge_Detection/L22_Edge_Detection.html
%         https://www.dropbox.com/s/cu5hycqfjihhfgv/L22%20Edge%20Detection.pdf?dl=0

%% Read image, get intensity
% Read in the image, and subset the first z-axis level to get image
% intensity (brightness) independent of color
clear;
f = imread('sickle.png');
f = double(f(:,:,1));
%imshow(f,[])

%% Calculate changes in image intensity between pixels
% For edge detection, we look for abrupt changes in intensity between pixels.
% If we plot intensity against x-axis or y-axis, when there is high slope,
% there is large change in intensity. 

% We can calculate the change in intensity at a pixel as follows: call 
% current pixel j. Get intensity of pixel j+1, subtract from pixel i-1, 
% and divide by 2 (dividing because j+1 - j-1 is intensity difference over
% two pixels, but we want intensity difference over one pixel). Thus,
% change in intensity dIdx = [I(x+1) - I(x-1)]/2

% Using above logic, for each pixel in image matrix f, take intensity of
% the physically left pixel (circshift(f,[0 -1])) and subtract from right
% pixel (circshift(f,[0 1])), then divide by two. This calculates change in
% intensity along x-axis
dfdx = (circshift(f,[0 -1]) - circshift(f,[0 1])) / 2;
% imshow(dfdc,[])

% Use a similar process, calculate change in intensity along y-axis
dfdy = (circshift(f,[-1 0]) - circshift(f,[1 0])) / 2;
% imshow(dfdr,[])

%% Calculate and show intensity magnitude -> Edge detection
% dfdx is x component of each pixel's intensity vector; dydx is y component
% use Pythagorean theorem to calculate intensity vector's magnitude from
% dfdx and dfdy, store as intensity_mag
intensity_mag = sqrt(dfdx.^2 + dfdy.^2);

% Display all the intensity magnitudes. An intenser white color corresponds 
% to a more dramatic change in intensity in the image
subplot(1,2,1), imshow(intensity_mag,[])

dfdx = (circshift(f,[0 -2]) - circshift(f,[0 2])) / 2;
% imshow(dfdc,[])

% Use a similar process, calculate change in intensity along y-axis
dfdy = (circshift(f,[-2 0]) - circshift(f,[2 0])) / 2;
% imshow(dfdr,[])

%% Calculate and show intensity magnitude -> Edge detection
% dfdx is x component of each pixel's intensity vector; dydx is y component
% use Pythagorean theorem to calculate intensity vector's magnitude from
% dfdx and dfdy, store as intensity_mag
intensity_mag = sqrt(dfdx.^2 + dfdy.^2);

% Display all the intensity magnitudes. An intenser white color corresponds 
% to a more dramatic change in intensity in the image
subplot(1,2,2), imshow(intensity_mag,[])