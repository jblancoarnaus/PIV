function algoHSV(coefficients, nbins, quantization)
%outputs histogram_database.txt file, which contains the approximation
%coefficients used to compare images
%   coefficients: # of haar coefficients kept
%   nbins: # of bins used for the hsv histogram
%   quantization: choose whether first the quantization is:
%       -linear (quantization=='linear')
%       -logarithmic (quantization=='log')

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
    hsvImage = rgb2hsv(img); %convert values RGB->HSV
    
    %generate coefficients for every image
    [quantized_coefficients] = generateHSVhist(hsvImage, coefficients, nbins, quantization);   

    %print coefficients into histogram_database.txt
    fprintf(fileID,'%d ', quantized_coefficients);
    fprintf(fileID,'\n');

end
%close file and return to the main directory
fclose(fileID);
cd(dir)