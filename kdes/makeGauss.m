% helper function that makes the asymmetric kernel for the makeKDE function
% to use to smooth. relies on stats toolkit. (mcf 6/06)

function gauss = makeGauss(lambda,tlambda)

% make the gaussian to convolve
fprintf('making gaussian\n');
range = 2*lambda;
trange = 2*tlambda;
gaussdim = range+range+1;
tgaussdim = trange+trange+1;

gauss = zeros(gaussdim,gaussdim,tgaussdim);

% basic gaussian stuff
for i = 1:gaussdim
  for j = 1:gaussdim
    for k = 1:tgaussdim
      gauss(i,j,k) = gauss(i,j,k) + mvnpdf([i j k],...
        [range + 1 range + 1 trange + 1],...
        [lambda 0 0; 0 lambda 0; 0 0 tlambda]);
    end
  end
end

% now get rid of the future
gauss(:,:,trange + 2:end) = 0;
