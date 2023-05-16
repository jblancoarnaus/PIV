function [aprox_coef] = generateHSVhist(hsvImage, coefficients, nbins, quantization)
%generates the quantized haar coefficients of a hsv histogram of nbins, 
%which has been previously quantized linearly (quantization=='linear') or 
%nonlinearly (quantization=='log')
%   hsvImage: matrix containing hsv values of a given image
%   coefficients: # of haar coefficients kept
%   quantization: choose whether first the quantization is:
%       -linear (quantization=='linear')
%       -logarithmic (quantization=='log')

%% DECLARE VARIABLES
% select bit amount accordingly
switch nbins
    case 256
        h_levels = 16;                                   % # of hue levels
        s_levels = 4;                                    % # of saturation levels
        v_levels = 4;                                    % # of value levels
    case 128
        h_levels = 8;                                    % # of hue levels
        s_levels = 4;                                    % # of saturation levels
        v_levels = 4;                                    % # of value levels
    case 64
        h_levels = 8;                                    % # of hue levels
        s_levels = 2;                                    % # of saturation levels
        v_levels = 4;                                    % # of value levels
    case 32
        h_levels = 8;                                    % # of hue levels
        s_levels = 2;                                    % # of saturation levels
        v_levels = 2;                                    % # of value levels
    case 16
        h_levels = 4;                                    % # of hue levels
        s_levels = 2;                                    % # of saturation levels
        v_levels = 2;                                    % # of value levels
end
h_bits = log2(h_levels);                                   % # of hue bits
s_bits = log2(s_levels);                                   % # of saturation bits
v_bits = log2(v_levels);                                   % # of value bits
total_bits = h_bits+s_bits+v_bits;                       % total bits

hsvHist = zeros(nbins,1);                 % HSV histogram array

bits_per_hist_level = 8; % #bits to quantize the # of pixels of a histogram level (0..255)

haarHist=zeros(1,coefficients); % haar coefficients array

%% GENERATE HISTOGRAM  
[numRows, numCols, ~] = size(hsvImage); % retrieve height and width of the image
total_pixels = numRows*numCols;         % obtain total pixels

% The histogram (in the HSV color space) values are extracted %
for col = 1 : numCols
    for row = 1 : numRows
            %hsvImage has values that range from 0 to 1. We must adapt
            %their dynamic range to a value between 0 ... h/s/v_levels-1 
            hBin = ceil(hsvImage(row, col, 1) * (h_levels-1));  % adapt hue range 
            sBin = ceil(hsvImage(row, col, 2) * (s_levels-1));  % adapt saturation range 
            vBin = ceil(hsvImage(row, col, 3) * (v_levels-1));  % adapt value range 

            % each pixel value is a value that contains information about
            % the three histogram bins (h,s,v):
            % The 4 most significant bits are the hue
            % The 2 following bits are the saturation
            % The 2 least significant bits are the value

           pixel = 2^(total_bits-h_bits)*hBin+2^(total_bits-h_bits-s_bits)*sBin+vBin;
            
            % Add 1 to the value of the pixel
            % since matlab indexes start at 1 and our values range from 0 to level-1, 
            % a unit is added to the array index to make up for that
            hsvHist(pixel+1) = hsvHist(pixel+1)+1;  
            
    end
end

%% LINEAR/NONLINEAR QUANTIZATION
% Normalize histogram values
hsvHist = hsvHist/total_pixels; %Returns values between 0 and 1

% According to the user's selection, the quantization will be linear or
% nonlinear
switch quantization
    case 'linear'
        % Linear quantization of coefficients
        qHist = round(hsvHist/max(hsvHist)*(pow2(bits_per_hist_level)-1));
    case 'log'
        % Logarithmic quantization
        hsvHist_log = 10*log10(hsvHist+10^-5);
        % obtain max value of histogram and quantize linearly 
        % due to the logarithm and our normalised values, hsvHist_log
        % contains <0 values, which makes the linear quantization is a bit tricky
        % (the lowest value is sustracted, which will set it to 0 and
        % increase the 'less negative' ones accordingly ->(hsvHist_log-min(hsvHist_log))
        qHist = round((hsvHist_log-min(hsvHist_log))/max(hsvHist_log-min(hsvHist_log))*(pow2(bits_per_hist_level)-1));
end

%% HAAR COEFFICIENTS RETRIEVAL
% if the coefficients are higher (an unreasonable decision) or equal to the # of histogram bins,
% haar won't be used, since it would decrease the # of haar coefficients
if(coefficients>=nbins)
    haarHist = qHist;
else
    %last_j = num_histogram_bins-num_histogram_bins/coefficients-1
    %first_j = 1
    %j increment = num_histogram_bins/coefficients = iter
    index = 1;  % index to fill the resulting array
    last_j=nbins-nbins/coefficients-1;
    iter = nbins/coefficients; % amount of values that have to be 
    %accumulated (eg: for 128 coefficients, two sums will be accumulated in each
    %bin -> 1+2, 3+4, ...127+128)
    
    %iterates through the entire quantized histogram with iter skips
    for j=1:iter:last_j
        %performs the local sums
        for count=1:iter
            haarHist(index)= haarHist(index)+qHist(count+j);    %store valeus into haarHist(index)
        end
        index = index+1;    %gets increased every iter times
    end
end

%% LINEAR QUANTIZATION
% linear quantization of the coefficients
aprox_coef = round(haarHist/max(haarHist)*(pow2(bits_per_hist_level)-1));

end