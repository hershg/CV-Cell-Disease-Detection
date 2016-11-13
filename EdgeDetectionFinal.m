% Author: Hersh Godse

%% Read image, get intensity
% Read in the image, and subset the first z-axis level to get image
% intensity (brightness) independent of color
clear;
f = imread('sickle1.png');
f = im2double(f(:,:,1));

%% Use edge function to get binary image with edges detected
bw = edge(f,'Sobel',.04); %%%%%%% Current threshold: 0.04

%% Clean up image
% bwareopen removes background noise (removes objects with fewer than 50 pixels)
bw = bwareaopen(bw, 50);
% fill any holes, and remove remaining edges of cells that weren't defined
% enough to be  flled in by imfill
bw = imfill(bw,'holes');
bw = bwareaopen(bw, 180);

%% Identify objects in image
% bwconncomp finds all Connected Components (objects) in the binary image
cc = bwconncomp(bw, 4);

%% Calculate area of each object
% regionprops gives area of connected components in cc structure
celldata = regionprops(cc,'Area','Perimeter');

%% Remove objects with fewer than 30 pixels
for i = 1:cc.NumObjects
    if celldata(i).Area < 30
        bw(cc.PixelIdxList{i}) = false;
    end
end
clear i;

cc = bwconncomp(bw, 4); %% Redoing to remove older data of small connected components
celldata = regionprops(cc,'Area','Perimeter'); 

%% Calculate the shape factor for each cell
% Create an array of zeros of length of number of cells
factors = zeros(1,cc.NumObjects);

% for each cell i, calculate the shape factor: (4*pi*Area)/(Perimeter.^2)
for i = 1:cc.NumObjects
    Area = celldata(i).Area;
    Perimeter = celldata(i).Perimeter;
    factors(i) = (4*pi*Area)/(Perimeter.^2);
end
clear Area Perimeter i;

% calculate total area of all cells, and average cell area
totalArea = 0;
for i = 1:cc.NumObjects
    totalArea = totalArea + celldata(i).Area;
end
averageArea = totalArea/(cc.NumObjects);
clear i;

% factorssort is shape factors sorted from smallest to largest
% factorsindex is the index of those factors from smallest to largest
[factorssort, factorsindex] = sort(factors,'ascend');
clear factors;

%% Classify each cell
% Create blank arrays for each cell type
% We will store the indexs of objects in these arrays as we classify
indicesSickle = [];
indicesRedBlood = [];
indicesSchisto = [];
indicesEllipto = [];
indicesOverlap = [];
indicesWhiteBlood = [];

% For each cell i, classify into one of the categories based on 
for i = 1:cc.NumObjects
    Factor = factorssort(i);
    Index = factorsindex(i);
    Area = celldata(Index).Area;
    AreaProp = Area/averageArea;
    F = 0;
    A = 0;
    
    if (Factor <= 0.5)
        F = 1;
    elseif ((0.5 < Factor) && (Factor <= 0.95))
        F = 2;
    elseif (Factor > 0.95)
        F = 3;
    end
     
    if (AreaProp <= 0.25)
        A = 1;
    elseif ((0.25 < AreaProp) && (AreaProp <= 1.3))
        A = 2;
    elseif (AreaProp > 1.3)
        A = 3;
    end
        
    if (A == 1)
        indicesSchisto = [indicesSchisto Index];
    elseif (A == 2)
        if (F == 1)
            indicesSickle = [indicesSickle Index];
        elseif (F == 2)
            indicesEllipto = [indicesEllipto Index];
        elseif (F == 3)
            indicesRedBlood = [indicesRedBlood Index];
        end
    elseif (A == 3)
        if ((F == 1) || (F == 2))
            indicesOverlap = [indicesOverlap Index];
        elseif (F == 3)
            indicesWhiteBlood = [indicesWhiteBlood Index];
        end
    end
end
clear A F i Factor Index Area AreaProp;


% view the cell with given index
cellindex = 23;
onecell = false(size(bw)); 
onecell(cc.PixelIdxList{1}) = true;
imshow(onecell)
clear onecell cellindex;