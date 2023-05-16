function fmeasure = main(varargin)
%Computes the fmeasure and plots the precision & recall curve
%USAGE:
%   case 1 input argument:
%       fmeasure = main(distance_method)
%       -> computes fmeasure using distance_method given an input file (input.txt)
%
%       case 2 input arguments:
%       fmeasure = main(distance_method, arg2)
%       -> if arg2=='all':computes fmeasure using distance_method of all
%       images
%       -> if arg2=number: computes fmeasure of using distance_method of
%       /number/ randomly selected images
%
%       distance_method: measurement used to obtain the results.
%       Options are:
%           -MAE (distance_method=='mae')
%           -RMAE (distance_method=='rmae')
%           -MSE (distance_method=='mse')

tic %start timer

%% DECLARE VARIABLES
% Directory/file-related variables
Output_filename= 'output.txt';
User_root      = pwd;
Input_filename = 'histogram_database.txt';  %input file

Candidates     = 10;  % Number of candidates to retrieve

avg_pre = zeros(1,Candidates);  % create empty precision array
avg_rec = zeros(1,Candidates);  % create empty recall array

% check for an output file
% (since we rely on writing in append mode, we must make sure the output
% file is empty by deleting it)
if(isempty(dir(Output_filename))==0)
    delete (Output_filename);   
end


if nargin==1
%% CASE: IDS RETRIEVED FROM AN INPUT FILE
    num_queries=20;         % set query #
    distance=varargin{1};   % assign first and only argument to distance
    
    %read input file and store it in in_array
    in_array = readmatrix('input.txt', 'OutputType','string');
    
    %for every query
    for i=1:num_queries
        % obtain query name
        query_name=in_array(i);
        
        % generate candidates using the selected distance and write them into
        % the output file
        algo3(query_name,Output_filename, Input_filename, Candidates, User_root, distance);
       
        % compute precision and recall values
        [precision, recall] = p_r;
        avg_pre = avg_pre+precision;    
        avg_rec = avg_rec+recall;      
    end
     
elseif nargin==2
%% CASE: RANDOMLY GENERATED IDS OR ALL IDS 
    distance=varargin{1};   % assign first argument to distance
    
    %check the second argument and set num_queries accordingly
    if(varargin{2}=='all') 
        num_queries =2000;
    else                   
        num_queries=varargin{2};
    end
    
    for i=1:num_queries
        % if 'all' is selected, all ids will be swept (0...1999)
        if(varargin{2}=='all')
            query_id=i-1;
        % if a number is inputted, that number of ids will be randomly
        % generated
        else
            query_id = random('Discrete Uniform',1999);
        end
        
        % generate file name with the given id
        s =  sprintf('%05d', query_id);
        query_name = strjoin([ "ukbench", s ,".jpg"],'');
        
        % generate candidates using the selected distance and write them into
        % the output file
        algo3(query_name,Output_filename, Input_filename, Candidates, User_root, distance);
        
        % compute precision and recall values
        [precision, recall] = p_r;
        avg_pre = avg_pre+precision;
        avg_rec = avg_rec+recall;
        
    end
end

%% COMPUTE F-MEASURE AND CURVES
% obtain average precision and recall
avg_pre = avg_pre./num_queries;
avg_rec = avg_rec./num_queries;

% compute fmeasure and keep the maximum value
fmeasure= 2 * avg_pre.*avg_rec./(avg_pre+avg_rec);
fmeasure=max(fmeasure);

% delete temporary file
delete 'output_temp.txt'

%% PLOT CURVES
title('Precision & Recall')
xlabel('Recall')
ylabel('Precision')
grid on
hold on
plot(avg_rec, avg_pre, '--*')
xlim([0 1])
ylim([0 1])

t=toc
end

