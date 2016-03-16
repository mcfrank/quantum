% grid data in XYt space (3D array). downsamples, also.

function ts = makeGrid(data,dim,gridsize)

% adjust and round the data
data(data==0) = 1;
data = data ./ gridsize;
data = ceil(data);
dim = ceil(dim ./ gridsize);

% convert the data to points in 3d space, with grid reduction
fprintf('gridding data\n');
[m n p] = size(data);

% ts is the image timeseries that we will smooth
ts = zeros([dim(2) dim(1) n]) + eps;

for t = 1:n
  for i = 1:m
    if ~isnan(data(i,t,1)) && ~isnan(data(i,t,2))
      % remember this is in ij format
      ts(data(i,t,2),data(i,t,1),t) = ts(data(i,t,2),data(i,t,1),t) + 1;
    end
  end
end

% now normalize each frame
for t = 1:n
  ts(:,:,t) = ts(:,:,t) ./ sum(sum(ts(:,:,t)));
end