%citra = imread('car3.jpg');
%letters = anpr(citra);
function letter = anpr(citra)

%load NewTemplates
%global NewTemplates
warning off %#ok<WNOFF>


[J, rect] = imcrop(citra);
figure,imshow(J);

citra=imresize(J,[400 NaN]); % Resizing the image keeping aspect ratio same.
figure,imshow(citra);

citra_bw=rgb2gray(citra); % Converting the RGB (color) image to gray (intensity).
figure,imshow(citra_bw); 

citra_filt=medfilt2(citra_bw,[3 3]); % Median filtering to remove noise.
figure,imshow(citra_filt);  

se=strel('disk',1);
citra_dilasi=imdilate(citra_filt,se); % Dilating the gray image with the structural element.
figure,imshow(citra_dilasi); 

citra_eroding=imerode(citra_filt,se); % Eroding the gray image with structural element.
figure,imshow(citra_eroding); 

citra_edge_enhacement=imsubtract(citra_dilasi,citra_eroding); % Morphological Gradient for edges enhancement.
figure,imshow(citra_edge_enhacement);

citra_edge_enhacement_double=mat2gray(double(citra_edge_enhacement)); % Converting the class to double.
figure,imshow(citra_edge_enhacement_double); 

citra_double_konv=conv2(citra_edge_enhacement_double,[1 1;1 1]); % Convolution of the double image f
figure,imshow(citra_double_konv); 

citra_intens=imadjust(citra_double_konv,[0.5 0.7],[0 1],0.1); % Intensity scaling between the range 0 to 1.
figure,imshow(citra_intens); 

citra_logic=logical(citra_intens); % Conversion of the class from double to binary.
figure,imshow(citra_logic); 

% Eliminating the possible horizontal lines from the output image of regiongrow
% that could be edges of license plate.
citra_line_delete=imsubtract(citra_logic, (imerode(citra_logic,strel('line',50,0))));
figure,imshow(citra_line_delete); 

% Filling all the regions of the image.
citra_fill=imfill(citra_line_delete,'holes');
figure,imshow(citra_fill),title('After Filling Holes'); 

% Thinning the image to ensure character isolation.
citra_thinning_eroding=imerode((bwmorph(citra_fill,'thin',1)),(strel('line',3,90)));
figure,imshow(citra_thinning_eroding); 

%Selecting all the regions that are of pixel area more than 100.
citra_final=bwareaopen(citra_thinning_eroding,125);
figure,imshow(citra_final); 

%climg = imclearborder(citra_final);
%figure,imshow(climg); 

[J, rect] = imcrop(citra_final);
figure,imshow(J);

citra=imresize(J,[400 NaN]); % Resizing the image keeping aspect ratio same.
figure,imshow(citra);


%BW=imbinarize(citra_bw);
%figure,imshow(BW) , title('Binary image');

%mulimg=immultiply(BW,citra_final);
%figure,imshow(mulimg) , title('Number PLate Extraction');

[labelled jml] = bwlabel(citra);

% Uncomment to make compitable with the previous versions of MATLAB®
% Two properties 'BoundingBox' and binary 'Image' corresponding to these
% Bounding boxes are acquired.

Iprops=regionprops(labelled,'BoundingBox','Image');

%%% OCR STEP
[letter{1:jml}]=deal([]);
[xn yn]=size(citra_final); % <-- citra is the original image matrix
figure, hold on 

[gambar{1:jml}]=deal([]);
for ii=1:jml
    gambar{ii}= double(Iprops(ii).Image)*255;
    bb=Iprops(ii).BoundingBox;
    image([bb(1) bb(1)+bb(3)],[yn-bb(2) yn-bb(2)-bb(4)],gambar{ii});
end
[gambar{1:jml}]=deal([]);


for ii=1:jml
    gambar{ii}= Iprops(ii).Image;
    %letter{ii}=readLetter(gambar);
    figure,imshow(gambar{ii});
end
for ii=1:jml
    text(ii)= OCR(gambar{ii});
    
end
fid = fopen('text.txt', 'wt');

for ii=1:jml
    fprintf(fid,'%s',text(ii));
end
fclose(fid);
winopen('text.txt')
end