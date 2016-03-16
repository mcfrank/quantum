% main script for doing density estimates, MCF from freev (circa 6/06)
% first load your data up before you run this script!
% KDE = kernel density estimate (e.g., heatmap, smoothed).

% this particular version 8/18/08
% does group analyses
% this encompasses what makeKDEs-old + KDE_transform used to do

clear all
load('../processed_data/quantum_final_data14-Dec-2009.mat')

%% VARIABLES
gridsize    = 40; % so an NxN pixel square becomes one pixel
dim         = [1024 768]; % screen size
lambda      = 2; % the standard deviation of the spatial kernel (5)
tlambda     = 2; % the standard deviation of the time kernel, note this is asymmetric (5)

gauss = makeGauss(lambda,tlambda); % faster to make your own gaussian

% lambda/tlambda = 10 for gridsize 10, 5 for gridsize 20 (you want smaller
% kernel for bigger gridsize). 3 for gridsize 80

%% MAIN code '

splits = quantile(ages,[.25 .5 .75]);
youngest = ages <= splits(1);
medium = ages >= splits(1) & ages < splits(2);
older = ages >= splits(2) & ages < splits(3);
old = ages >= splits(3);

groups = {'youngest','medium','older','old'};

for g = 1:length(groups) % groups of data
  for c = 1:4 % conditions
    for m = 1:3 % movies in each condition
      fprintf('*** group %d, condition %d, movie %d ***\n',g,c,m);
      
      these_data = data{c}{m}(eval(groups{g}),:,:);
      kde{g}{c}{m} = makeKDE(these_data,dim,gridsize,gauss); % make the KDE, the hard part
      kde{g}{c}{m} = makeGrid(these_data,dim,gridsize);
      entropy(g,c,m) = ent3(kde{g}{c}{m}); % compute entropy, only useful for comparison
            
      ent_fun = @(x) ent3(kde{g}{c}{m}(:,:,x));       
      entropy_bounds(g,c,m,1:2) = quantile(...
        bootstrp(100,ent_fun,1:size(kde{g}{c}{m},3)),...
        [.025 .975]);
    end
  end
end

save(['mats/grid_' num2str(gridsize) '-40-4groups.mat'],'kde')

%% graphs
figure(1)
clf
means = [mean(entropy(1,:,:),3); mean(entropy(2,:,:),3); mean(entropy(3,:,:),3); mean(entropy(4,:,:),3)]';
sem = [stderr(entropy(1,:,:),3); stderr(entropy(2,:,:),3); stderr(entropy(3,:,:),3); stderr(entropy(4,:,:),3)]';
barweb(means,sem)
axis([.5 4.5 12 15])
set(gca,'XTick',1:4,...
  'XTickLabel',{'Faces pure','Faces medium','Faces plus','Objects'});


