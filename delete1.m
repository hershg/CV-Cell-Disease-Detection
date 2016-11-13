I = imread('sickle.png');
I = im2double(f(:,:,1));
C = corner(I);
imshow(I);
hold on
plot(C(:,1), C(:,2), 'r*');