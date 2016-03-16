% main script for doing density estimates, MCF from freev (circa 6/06)
% first load your data up before you run this script!
% KDE = kernel density estimate (e.g., heatmap, smoothed).

% this particular version 8/18/08
% does group analyses
% this encompasses what makeKDEs-old + KDE_transform used to do

clear all
load('../processed_data/quantum_final_data18-May-2011.mat')

%% VARIABLES
gridsize    = 20; % so an NxN pixel square becomes one pixel
dim         = [1024 768]; % screen size
lambda      = 3; % the standard deviation of the spatial kernel (5)
tlambda     = 3; % the standard deviation of the time kernel, note this is asymmetric (5)

gauss = makeGauss(lambda,tlambda); % faster to make your own gaussian

% lambda/tlambda = 10 for gridsize 10, 5 for gridsize 20 (you want smaller
% kernel for bigger gridsize). 3 for gridsize 80

%% MAIN code '
% load mats/grid_20-40-2groups.mat

splits = quantile(ages,[.5]);
young = ages < splits(1);
% medium = ages > splits(1) & ages < splits(2);
old = ages > splits(1);

groups = {'young','old'};

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

%
save(['mats/grid_' num2str(gridsize) '-3-2groups.mat'],'kde')

%% graphs
figure(1)
clf
set(gca,'FontSize',14)
grps = {'6mo - 12mo','12mo - 30mo'};

n = .06;
hold on
for c = 1:4
  for m = 1:3    
    y1 = entropy(1,c,m);
    y2 = entropy(2,c,m);
    text(c-.125,entropy(1,c,m),num2str(m),'Color',[1 0 0],'FontSize',12)
    text(c+.125,entropy(2,c,m),num2str(m),'Color',[0 0 1],'FontSize',12)
    errorbar(c-.175,y1,y1 - entropy_bounds(1,c,m,1),entropy_bounds(1,c,m,2) - y1,'r');
    errorbar(c+.225,y2,y2 - entropy_bounds(2,c,m,1),entropy_bounds(2,c,m,2) - y2,'b');

    ys = [entropy(1,c,m) entropy(2,c,m)]';
    xs = [ones(size(ys)) [c-.125 c+.125]'];
    b = regress(ys,xs);
    line([c-n c+n],[b(1) + b(2)*(c-n) b(1) + b(2)*(c+n)] ,'Color',[0 0 0],...
      'LineStyle','--')
  end
end

colormap(jet)
% axis([.5 4.5 floor(min(min(min(entropy))))+.5 ceil(max(max(max(entropy))))+.5])

h = plot(0,0,'ro',0,0,'bo');
legend(h,grps,'Location','SouthEast');
set(gca,'XTick',1:4,...
  'XTickLabel',{'Faces pure','Faces medium','Faces plus','Objects'});
set(gca,'YTick',[17.5:.5:19.5])

set(gca,'FontSize',12);
ylabel('entropy (bits)');
xlabel('condition')
  
%% simple plot
clf
means = [mean(entropy(:,1,:),3)'; mean(entropy(:,2,:),3)'; mean(entropy(:,3,:),3)'; mean(entropy(:,4,:),3)']';
sem = [stderr(entropy(:,1,:),3)'; stderr(entropy(:,2,:),3)'; stderr(entropy(:,3,:),3)'; stderr(entropy(:,4,:),3)']';
bar(means')
axis([.5 4.5 12 15])
set(gca,'XTick',1:4,...
  'XTickLabel',{'Faces pure','Faces medium','Faces plus','Objects'});


