% entropy split by movie coding

clear all

% note, there are 1-3 frames more on the end that we didn't use
starts = {{[1 51 182 292 437 548 600],[1 235 352 434 508 600],[1 168 281 346 400 455 510 600]},...
  {[1 109 259 407 513 600],[1 68 169 239 329 403 479 600],[1 70 137 248 422 524 600]},...
        {[1 139 293 441 600],[1 143 301 475 600],[1 120 218 323 444 600]},...
        {[1 165 406 545 600],[1 137 238 450 600],[1 153 390 490 542 600]}};
 
% zero means just holding, 1 means picking up or putting, 2 means complex
% action, throwing mixing banging, etc.
actions = {{[0 1 1 1 1],[2 1 0 1 2 2 2],[1 1 2 2 1 0]},...
          {[0 2 0 2],[0 2 2 1],[0 2 2 1 2]}}; 

load mats/grid_20-3-2groups.mat
load('../processed_data/quantum_final_data18-May-2011.mat')

%% MAIN code 

entropy = NaN([2 4 18]);

for g = 1:length(kde) % groups of data
  for c = 1:4 % conditions
    l_ind = 1;
    for m = 1:3 % movies in each condition     
      lens = diff(starts{c}{m});
      
      for l = 1:length(lens)
        entropy(g,c,l_ind) = ...
          ent3(kde{g}{c}{m}(:,:,starts{c}{m}(l)*2:starts{c}{m}(l+1)*2)); % compute entropy, only useful for comparison
        l_ind = l_ind + 1;
      end
    end
  end
end

%% graphs
figure(1)
clf

set(gca,'FontSize',14)
grps = {'3mo - 12mo','12mo - 30mo'};

means = [nanmean(entropy(1,:,:),3); nanmean(entropy(2,:,:),3)]';
errs = [stderr(entropy(1,:,:),3); stderr(entropy(2,:,:),3)]';

hold on
h= bar(means);
xs = [.85 1.15; 1.85 2.15; 2.85 3.15; 3.85 4.15];
errorbar(xs,means,errs,'k.','MarkerSize',0.1)
axis([.5 4.5 10 14])
set(gca,'XTick',1:4,...
  'XTickLabel',{'Face Only','Whole person','Multiple People','Objects'});

% colormap(gray) 
set(h(1),'FaceColor',[.25 .25 .25])
set(h(2),'FaceColor',[.75 .75 .75])


legend(grps)
xlabel('condition')
ylabel('bits of entropy')
%% stats 

[h p ci stats] = ttest(squeeze(entropy(1,1,:)),squeeze(entropy(2,1,:)))
[h p ci stats] = ttest(squeeze(entropy(1,2,:)),squeeze(entropy(2,2,:)))
[h p ci stats] = ttest(squeeze(entropy(1,3,:)),squeeze(entropy(2,3,:)))
[h p ci stats] = ttest(squeeze(entropy(1,4,:)),squeeze(entropy(2,4,:)))

%%

ents = reshape(entropy,[1 numel(entropy)])';
grp = reshape(repmat([1:2]',[1 4 18]),[1 numel(entropy)])';
cond = reshape(repmat(1:4,[2 1 18]),[1 numel(entropy)])';
clip = floor(1:.125:18.875)';

grp = grp(~isnan(ents));
cond = cond(~isnan(ents));
clip = clip(~isnan(ents)) + 100*cond;
ents = ents(~isnan(ents));

anovan(ents,[grp cond],'model','full')
%%

fid = fopen('~/R/quantum/ent.csv','w');

fprintf(fid,'ent,grp,clip,cond\n');
for i = 1:length(ents)
  fprintf(fid,'%d,%d,%d,%d\n',ents(i),grp(i),clip(i),cond(i));
end
%%

lens = [];
for i = 1:length(starts)
  for j = 1:3
    lens = [lens diff(starts{i}{j})/30];
  end
end
