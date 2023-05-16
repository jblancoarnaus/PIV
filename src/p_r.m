function [precision, recall] = p_r
%returns the precision and recall values for one given image
%   query_image: queried image for the measurement

%% OBTAIN RETRIEVED IDS
% obtain candidates of the temporary file
out = readmatrix('output_temp.txt', 'OutputType','string');

% extract image ids
for i=1:length(out)
    s = split(out(i), "ukbench0");
    s = split(s(2), ".jpg");
    out_images_id(i) = str2num(s(1));
end

%% COMPUTE PRECISION AND RECALL VALUES
relpos = mod(out_images_id(1),4); % informs of relative position of image
startpos = out_images_id(1) - relpos; % returns the first absolute image id of the 4 image set

TP=0; % true positive count

candidates = length(out_images_id)-1;   % # of candidates

precision = zeros(1, candidates);       % precision empty array
recall = zeros(1, candidates);          % recall empty array 

for i=2:candidates+1
    if (out_images_id(i)== startpos || out_images_id(i)== startpos + 1 || out_images_id(i)== startpos + 2 || out_images_id(i)== startpos + 3)
        % update TP count
        TP= TP+1;   
    end
    % precision: TP/(TP+FP)
    precision(i-1) = TP/(i-1);
    % recall: TP/(TP+FN) 
    recall(i-1) = TP/(4);   % total positives==4 in this experiment
end

end