% uses a gaussian kernel to smooth XYt data
% does this by gridding data in XYt space (3D array). downsamples, also.
% then uses convn to make a convolution with a pre-provided gaussian
% kernel. finally, normalizes by frame. 
%
% inputs:
% - data is the data, described in makeKDEs.m
% - dim is the dimensions of the screen
% - gridsize is the screen size
% - gauss is the gaussian kernel you use (have to generate this with
%   makeGauss.m)
%
% (MCF 6/06)

function kde = makeKDE(data,dim,gridsize,gauss)

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

% now do the hard part (convolution)
fprintf('convolving\n');
tic; kde = convn(ts, gauss, 'same'); toc;

% now normalize each frame
for t = 1:n
  kde(:,:,t) = kde(:,:,t) ./ sum(sum(kde(:,:,t)));
end