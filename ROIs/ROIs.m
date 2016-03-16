% ROI analysis for quantum
% most recent version makes movies with ROI boxes
% mcf 12/14/09

clear all
load ../processed_data/quantum_final_data18-May-2011.mat

points_files = {'Faces_Pure_','Face_med_','Faces_Plus_','objects'};
cond_targets = {{'FA','EY','MO'},{'FA','HA'},{'FA','HA'}};

toplot = 0;
smooth_rad = 15;

moviesize = [768 576];
framesize = [1024 768];
adjust = [framesize - moviesize] /2;

movie_lens = 1200;

set(gca,'Color',[0 0 0],'XTick',[],'YTick',[])

%% MOVIE LOOP

for cond = 1:3
  disp(['condition ' num2str(cond)])
  targets = cond_targets{cond};
  for trial = 1:3
    fprintf('\ttrial %s\n',num2str(trial))
    for targ = 1:length(targets)
      load(['pts/' points_files{cond} num2str(trial) '_' targets{targ}]);
      eval([targets{targ} '=points;']);     
    end

    for t = 1:movie_lens
      cla
      f = ceil(t/2); % convert to movie frames at 30 fps
      c = ceil(t/1.905); % convert to coded frames at 30 fps

      xp = data{cond}{trial}(:,t,1) - adjust(1);
      yp = data{cond}{trial}(:,t,2) - adjust(2);

      if toplot 
        im = imread(['../movie_images/' points_files{cond} num2str(trial) '/' ...
          points_files{cond} num2str(trial) num2str(f,'%03.0f') '.jpg']);
        imagesc(imresize(im,moviesize([2 1])));

        axis([[0 1024] - adjust(1) [0 768] - adjust(2)])
        hold on
        plot(xp,yp,'b.')
      end

      for targ = 1:length(targets)
        area{targ}{cond}{trial}(t) = 0;
        inside{targ} = zeros(size(data{cond}{trial},1),1);
        points = eval([targets{targ} '(c);']);
        
        for p = 1:length(points.p1s)
          x1 = points.p1s{p}(2) - smooth_rad;
          x2 = points.p2s{p}(2) + smooth_rad;
          y1 = points.p1s{p}(1) - smooth_rad;
          y2 = points.p2s{p}(1) + smooth_rad;

          if toplot, % plot the rectangle
            col = zeros(1,3);
            col(targ) = 1;
            rectangle('Position',[x1 y1 x2 - x1 y2 - y1],'EdgeColor',col); 
          end;

          inside{targ}(:,p) = xp >= x1 & xp <= x2 & yp >= y1 & yp <= y2 & ~isnan(xp) & ~isnan(yp);   
          area{targ}{cond}{trial}(t) = area{targ}{cond}{trial}(t) + (x2 - x1) * (y2 - y1) / prod(moviesize);
        end
        
        roi{targ}{cond}{trial}(:,t) = double(sum(inside{targ},2)>=1);
        roi{targ}{cond}{trial}(isnan(data{cond}{trial}(:,t,1)),t) = NaN;
      end
      
      if toplot % more plotting details
        drawnow
        set(gca,'XTick',[],'YTick',[],'Color',[0 0 0]); 
        m = getframe;
        imwrite(m.cdata,['movies/' points_files{cond} num2str(trial) '/frame' num2str(t) '.jpg'],'jpg')
      end

    end
  end
end

%% PLOTTTING 
clf
age_mo = ages / [365/12];

for cond = 1:3
  for targ = 1:length(cond_targets{cond})
    for trial = 1:3
      looking{targ}{cond}(:,trial) = nanmean(roi{targ}{cond}{trial},2);
    end
    
    on_task = nansum(~isnan(roi{targ}{cond}{1}),2) + ...
      nansum(~isnan(roi{targ}{cond}{2}),2) + ...
      nansum(~isnan(roi{targ}{cond}{3}),2);
    on_target = nansum(roi{targ}{cond}{1},2) + ...
      nansum(roi{targ}{cond}{2},2) + nansum(roi{targ}{cond}{3},2);
    looking_all{targ}{cond} = on_target ./ on_task;   
    
    looking_all{targ}{cond}(on_task / 3600 < .3) = NaN; 
  end
end

figure(1)
clf
legends = {{'faces','eyes','mouths'},{'faces','hands'},{'faces','hands'}};
cols = {[0 0 0],[1 0 0],[1 0 1],[0 0 1]};
cond_titles = {'Face Only','Whole Person','Multiple People'};
c = {[1 3 4],[1 2],[1 2]};

panels = {1:5,8:12,17:21};
for i = 1:3
  clear h
  subplot(2,12,panels{i})
  set(gca,'FontSize',12)
  hold on
  
  for j = 1:length(cond_targets{i})
%     sys = nanmean(looking{j}{i},2);
    ys = looking_all{j}{i};
    
    h(j) = plot(age_mo,ys,'.','Color',cols{c{i}(j)});
    [b bint r rint stats] = regress(ys,[ones(size(age_mo)) age_mo]);
    line([min(age_mo) max(age_mo)],[b(1) + min(age_mo)*b(2) ...
      b(1) + max(age_mo)*b(2)],'Color',cols{c{i}(j)})
    
    if stats(3) < .01, sig = '**'; elseif stats(3) < .05, sig = '*'; else sig = ''; end;   
    
    text(max(age_mo)-4,b(1) + max(age_mo)*b(2) - .06,...
      ['r = ' num2str(sqrt(stats(1)),'%.02f') sig],'Color',cols{c{i}(j)})
    text(min(age_mo)-2,b(1) + min(age_mo)*b(2) - .03,...
      legends{i}{j},'Color',cols{c{i}(j)});
    
    fprintf('%s %s\n',cond_titles{i},legends{i}{j})
    stats(1) = sqrt(stats(1));
    disp(stats)
  end
  
 
%   
%   if i == 1
    xlabel('age (months)')  
    ylabel('percentage looking')
%   end
  axis([0 30 0 1])
  
  title(cond_titles{i})
end