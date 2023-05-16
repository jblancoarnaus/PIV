function algo1(nbins)
%outputs histogram_database.txt file, which contains the monochrome 
%histograms used to compare images
%  nbins: # of bins of the histograms

%% DECLARE VARIABLES
dir = pwd;      %set directory to the current one
cd(dir);     
cd("database")  %go to the directory of the image database
N = 2000;       %# of images

%% READ IMAGES AND WRITE THEM INTO THE OUTPUT FILE
fileID = fopen('../histogram_database.txt','w');
for id = 0:N-1
    %obtain image name and retrieve its file
    num = sprintf('%05d', id);
    nameim = strcat('ukbench', num , '.jpg');
    
    img = imread(nameim);   %read image    
    imgrey = rgb2gray(img); %obtain grayscale image
    h = round(imhist(imgrey, nbins));   %obtain histogram h
    
    %print bins into histogram_database.txt
    fprintf(fileID,'%d ',h);
    fprintf(fileID,'\n');
end
%close file and return to the main directory
fclose(fileID);
cd('..')