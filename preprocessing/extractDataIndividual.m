%% function to read in tobii files for quantum
% original mcf 6/06
% mod for quantum 7/08
% mod to incorporate calibration check stuff from ak 8/25/08
% made it much faster and easier 3/15/09

function data = extractDataIndividual(filename)

%filename = '../raw_data/include/L18.tsv'

%% first read in the data 
fprintf('baby: %s\n',filename);

% load the files into a big struct
[pdata,movie] = readQuantumTobiiFile(filename);
fdata = validGazeFilterQuantum(pdata,[1024 768]);

%% now extract the data from each condition
conds = {'Faces_Pure_','Face_med_','Faces_Plus_','objects'};

for c = 1:length(conds)
  for m = 1:3
    movie_name = [conds{c} num2str(m) '.avi'];
    movie_index = strcmp(movie,movie_name);   
    data{c}{m} = fdata(movie_index,:);
  end
end

%% get calibration and split
movie_index = strcmp(movie,'calib.avi');   
data{c}{m} = fdata(movie_index,:);

breaks = [1 find(diff(movie_index)~=0)'];

if numel(breaks) > 1
  for i = 1:round(length(breaks)/2)
    range = breaks(((i-1)*2) + 1):breaks(i*2);
    data{5}{i} = fdata(range,:);
  end
end