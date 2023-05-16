function [obtained_dist] = algo2(id1,id2,data_matrix, distance)
% returns the distance between two images
%   id1: id of the first image
%   id2: id of the second image
%   data_matrix: matrix containing all the values of histogram_database.txt
%   distance: distance used for the measurement

%% OBTAIN ID1 AND ID2 COEFFICIENTS
hist1 = data_matrix(id1+1, :);
hist2 = data_matrix(id2+1, :);
dist_sum = 0;
N = length(hist1);

%% COMPUTE DISTANCE GIVEN THE USER INPUT
switch distance

    case 'rmae'
        for i=1:N
            dist_sum = dist_sum +sqrt(abs((hist1(i)-hist2(i))));  % "RMAE"
        end
    case 'mse'
        for i=1:N
            dist_sum = dist_sum +(hist1(i)-hist2(i)).^2;          % MSE
        end
    case 'mae'
        for i=1:N
            dist_sum = dist_sum +abs((hist1(i)-hist2(i)));        % MAE
        end
end

dist_sum = dist_sum/N;
obtained_dist = dist_sum;

end

