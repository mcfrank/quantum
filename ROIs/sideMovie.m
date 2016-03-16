% ROI analysis for quantum
% most recent version makes movies with ROI boxes
% mcf 12/14/09

clear all
load ../processed_data/quantum_final_data14-Dec-2009.mat

points_files = {'Faces_Pure_','Face_med_','Faces_Plus_','objects'};
cond_targets = {{'FA','EY','MO'},{'FA','HA'},{'FA','HA'}};

toplot = 1;
smooth_rad = 15;

moviesize = [768 576];
framesize = [1024 768];
adjust = [framesize - moviesize] /2;

movie_lens = 1200;

set(gca,'Color',[0 0 0],'XTick',[],'YTick',[])

young = ages < median(ages);
old = ages > median(ages);

%% MOVIE LOOP

for cond = 2:3
  disp(['condition ' num2str(cond)])
  targets = cond_targets{cond};
  for trial = 2:3
    fprintf('\ttrial %s\n',num2str(trial))
    for targ = 1:length(targets)
      load(['pts/' points_files{cond} num2str(trial) '_' targets{targ}]);
      eval([targets{targ} '=points;']);     
    end

    for t = 2:2:movie_lens      
      f = ceil(t/2); % convert to movie frames at 30 fps
      c = ceil(t/1.905); % convert to coded frames at 30 fps

      xp = data{cond}{trial}(:,t,1) - adjust(1);
      yp = data{cond}{trial}(:,t,2) - adjust(2);

      if toplot 
        im = imread(['../movie_images/' points_files{cond} num2str(trial) '/' ...
          points_files{cond} num2str(trial) num2str(f,'%03.0f') '.jpg']);
        
        subplot(1,2,1)
        cla
        imagesc(imresize(im,moviesize([2 1])));
        axis([[0 1024] - adjust(1) [0 768] - adjust(2)])
        hold on
        plot(xp(young),yp(young),'b.')
        
        subplot(1,2,2)
        cla
        imagesc(imresize(im,moviesize([2 1])));
        axis([[0 1024] - adjust(1) [0 768] - adjust(2)])
        hold on
        plot(xp(old),yp(old),'b.')
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
            for q = 1:2
              subplot(1,2,q)
              col = zeros(1,3);
              col(targ) = 1;
              rectangle('Position',[x1 y1 x2 - x1 y2 - y1],'EdgeColor',col); 
            end
          end;

          inside{targ}(:,p) = xp >= x1 & xp <= x2 & yp >= y1 & yp <= y2 & ~isnan(xp) & ~isnan(yp);   
          area{targ}{cond}{trial}(t) = area{targ}{cond}{trial}(t) + (x2 - x1) * (y2 - y1) / prod(moviesize);
        end
        
        roi{targ}{cond}{trial}(:,t) = double(sum(inside{targ},2)>=1);
        roi{targ}{cond}{trial}(isnan(data{cond}{trial}(:,t,1)),t) = NaN;
      end
      
      if toplot % more plotting details
        subplot(1,2,1)
        drawnow
        set(gca,'XTick',[],'YTick',[],'Color',[0 0 0]); 
        title('3 - 12 months')
        subplot(1,2,2)
        drawnow
        title('12 - 30 months')
        set(gca,'XTick',[],'YTick',[],'Color',[0 0 0]);         
        m = getframe(gcf);
        imwrite(m.cdata,['movies/' points_files{cond} num2str(trial) '/frame' num2str(t) '.jpg'],'jpg')
      end

    end
  end
end

