function algo3(query,output_filename, input_filename, candidates, user_root, distance)
% given a query image, searches the most likely candidates and prints them
% into an output file
%   query: query image filename
%   output_filename: output txt filename
%   candidates: # of candidates that will be retrieved
%   user_root: current directory 
%   distance: distance used for the measurement

%% EXTRACT QUERY ID
s = split(query, "ukbench0");
s = split(s(2), ".jpg");    
query_id = str2num(s(1));   % convert to a scalar

%% OBTAIN ALL COEFFICIENTS AND OPEN THE NECESSARY FILES
input = dlmread(input_filename);

% get the number of images to be queried
num_images = length(input(:,1));

% open output file to write the results
a=fopen([user_root, '/', 'output_temp.txt'],'w');
b = fopen([user_root, '/', output_filename],'a');
if(a==-1||b==-1)
    printf("Couldn't open file \n");
    return
end

%% OBTAIN MOST SIMILAR IMAGES AND WRITE IT INTO THE OUTPUT FILE
distance_array = (1:num_images);
%compute distances of query with all images on database
for i=1:num_images
    distance_array(i) = algo2(query_id, i-1, input, distance);
end

% select the most similar images
[~, Similar_images] = mink(distance_array, candidates);

% write the results into the output file
fprintf(a,'Retrieved list for query image %s \n',query);
fprintf(b,'Retrieved list for query image %s \n',query);
for j=1:candidates
    fprintf(a,'%s\n',sprintf('ukbench%05d.jpg',Similar_images(j)-1));
    fprintf(b,'%s\n',sprintf('ukbench%05d.jpg',Similar_images(j)-1));   
end

fprintf(b,'\n');
% close files
fclose(a);
fclose(b);
