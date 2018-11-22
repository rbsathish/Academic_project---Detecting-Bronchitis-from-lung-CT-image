
%%Preprocessing the Lung ct image:
      clc;
  myFolder = 'C:\Users\naveen\Desktop\newdata';
if ~isdir(myFolder)
errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
uiwait(warndlg(errorMessage));
return;
end
filePattern = fullfile(myFolder, '*.jpg');
bmpFiles = dir(filePattern);
for k = 1:length(bmpFiles)
baseFileName = bmpFiles(k).name;
fullFileName = fullfile(myFolder, baseFileName);
fprintf(1, 'Now reading %s\n', fullFileName);
imageArray = imread(fullFileName);
%imshow(imageArray);  % Display image.
%drawnow; % Force display to update immediately.
     %% convert image to gray level
        grayImage = rgb2gray(imageArray);
            %figure;
            %imshow(grayImage);
            %title('input image');
     
     %% applying wiener filter to image.
            afterWiener = wiener2(grayImage,[3 3]);
            %figure;
            %imshow(afterWiener); title('After Wiener applyied ');
     %% applying wiener filter for deblurring
            %afterDeblur = deconvwnr(afterWiener,[3 3]);
            %figure, imshow(afterDeblur);
 %%  
 %%laplacian
        %% create laplacian filter. 
              H = fspecial('laplacian');
        %% apply laplacian filter. 
              lap = imfilter(grayImage,H);
              %figure;
              %imshow(lap); title('Edge detected using laplacian');
%%    
%%edge enhancement to subtract the wiener and laplacian
        edgeenhanced = afterWiener - lap;
        %figure;
        %imshow(edgeenhanced);
        %title('Edge Enhanced Image');
%%    
%%applying optimal thresholding 
        otsu = graythresh(edgeenhanced);
        BW = imbinarize(edgeenhanced,otsu);
        %figure;
        %imshow(BW);
        %title('Binary Image');
  
 %% applying cavity in binary image
       %%filling all holes
            filled = imfill(BW, 'holes');
            %imshow(filled);
            %title('All holes filled')
       %%Identify the hole pixels using logical operators:
            holes = filled & ~BW;
            %imshow(holes);
            %title('Hole pixels identified');
       %Use bwareaopen on the holes image to eliminate small holes:
            bigholes = bwareaopen(holes, 200);
            %figure;
            %imshow(bigholes);
            %title('binary image with background'); 
%%
%%Background removal         
            %%Specify the initial contour and display it.
                mask = zeros(size(bigholes));
                mask(25:end-25,25:end-25) = 1;
                %figure;
                %imshow(mask);
                %title('Initial Contour Location');
            %%Segment the image using the default method and 300 iterations.
                bw = activecontour(bigholes,mask,300);
            %%Display the result.
                %figure;
                %imshow(bw);
                %title('Segmented Image');
            %%
            %complement the image to remove background
            bw2 = imcomplement(bw);
            %imshowpair(bw,bw2);
            %imshow(bw2);
            %title('background removed');
%%
%Find connected components in binary image
        CC = bwconncomp(bw2);
        %figure;
        %imshow(CC); 
        %title('conected components')
%   CC = struct with fields:
        %Connectivity: 8
        %ImageSize: [256 256]
        %NumObjects: 88
        %PixelIdxList: {1×88 cell}
%Determine which is the largest component in the image and erase it (set all the pixels to 0)
        numPixels = cellfun(@numel,CC.PixelIdxList);
        [biggest,idx] = max(numPixels);
        bw2(CC.PixelIdxList{idx}) = 1000;
%Display the image, noting that the largest component happens to be the two consecutive f's in the word different.
        %figure;
        %imshow(bw2);
%%
        %superimpose
           % segment = imfuse(bw2,grayImage,'montage');
           % figure;
           % imshow(segment);   
           % title('Segmented Lungs');
            
            %%
            %roi
            rc = imclearborder(bw2);
            %figure;
            %imshow(rc);   
            %title('rc');
            
            roi = bwareaopen(rc, 50);
            %figure;
            %imshow(roi);
            %title('roi');
            %%
            %feature extraction 
 %geometric 
 %All = regionprops(roi,'All');
 
 %Area = regionprops(roi,'Area');
 %MajorAxisLength = regionprops(roi,'MajorAxisLength');
 %MinorAxisLength = regionprops(roi,'MinorAxisLength');
 %Eccentricity = regionprops(roi,'Eccentricity');
 %Orientation = regionprops(roi,'Orientation');
 %ConvexArea = regionprops(roi,'ConvexArea');
 %FilledArea = regionprops(roi,'FilledArea');
 %EulerNumber = regionprops(roi,'EulerNumber');
 %Equivdiameter = regionprops(roi,'Equivdiameter');
 %Solidity = regionprops(roi,'Solidity');
 %Extent = regionprops(roi,'Extent');
 %Perimeter = regionprops(roi,'Perimeter');
  
 geo = regionprops('table',roi,'Area','MajorAxisLength','MinorAxisLength','Eccentricity','Orientation','ConvexArea','FilledArea','EulerNumber','Equivdiameter','Solidity','Extent','Perimeter');
 if height(geo)>0
     g(k,:)=geo(1,:);
 else
     g(k,:) = {nan};
 end
 %save file
%writetable(geo,'1.csv');
%%
 %%
 %texture features GLCM
 %tex = graycoprops(roi,'all');
 %save file
 %writetable(tex,'texture.csv');
 
 %stats = GLCM_features1(roi,'all');
 %%
 %%glcm off set calculation
 
 %offsets = [0 D; -D D;-D 0;-D -D];
 offsets = [0 1; -1 1;-1 0;-1 -1];
 %offsets = [ 0 1; 0 2; 0 3; 0 4;...
  %          -1 1; -2 2; -3 3; -4 4;...
   %         -1 0; -2 0; -3 0; -4 0;...
    %        -1 -1; -2 -2; -3 -3; -4 -4];
 
 %[glcms, SI] = graycomatrix(roi,'Offset',offsets);
 glcm = graycomatrix(roi,'Offset',offsets);
 
 %whos 
%tex = graycoprops(glcm);
%y = struct2table(tex);
%texx{:}{1} = (glcm.Contrast)';
%
GLCMNEW = GLCMFeatures(glcm);

texture(k,:) = struct2table(GLCMNEW);

%s = ({GLCMNEW.autoCorrelation , GLCMNEW.clusterProminence })';

%ttt = ({texture.autoCorrelation , texture.clusterProminence })';

%autocorrelation = (texture.autoCorrelation)';

%y = (GLCMNEW.autoCorrelation)';

%ttt = ({texture.autoCorrelation , texture.clusterProminence , texture.clusterShade , texture.contrast, texture.correlation, texture.differenceEntropy, texture.differenceVariance, texture.dissimilarity, texture.energy, texture.entropy, texture.homogeneity, texture.informationMeasureOfCorrelation1, texture.informationMeasureOfCorrelation2, texture.inverseDifference, texture.maximumProbability, texture.sumAverage, texture.sumEntropy, texture.sumOfSquaresVariance, texture.sumVariance })';

%y = ttt';


end
A=[g,texture];
writetable(A,'extractedfeatures.csv');
%%
%svm
