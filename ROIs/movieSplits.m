%% constants
% look at hand looking broken down by what kind of action

clear all
load ../processed_data/quantum_final_data14-Dec-2009.mat

points_files = {'Face_med_','Faces_Plus_'};
smooth_rad = 15;
moviesize = [768 576];
framesize = [1024 768];
adjust = [framesize - moviesize] /2;
movie_lens = 1200;
age_mo = ages / [365/12];

%% MOVIE LOOP

for cond = 1:2
  disp(['condition ' num2str(cond)])

  for trial = 1:3
    fprintf('\ttrial %s\n',num2str(trial))
    
    load(['pts/' points_files{cond} num2str(trial) '_HA']);
    ha = points;
    
    for t = 1:movie_lens
      area{cond}{trial}(t) = 0;

      f = ceil(t/2); % convert to movie frames at 30 fps
      c = ceil(t/1.905); % convert to coded frames at 30 fps

      xp = data{cond+1}{trial}(:,t,1) - adjust(1);
      yp = data{cond+1}{trial}(:,t,2) - adjust(2);

      areas{cond}{trial}(t) = 0;
      inside = zeros(size(data{cond}{trial},1),1);
      points = ha(c);

      for p = 1:length(points.p1s)
        x1 = points.p1s{p}(2) - smooth_rad;
        x2 = points.p2s{p}(2) + smooth_rad;
        y1 = points.p1s{p}(1) - smooth_rad;
        y2 = points.p2s{p}(1) + smooth_rad;

        inside(:,p) = xp >= x1 & xp <= x2 & yp >= y1 & yp <= y2 ...
          & ~isnan(xp) & ~isnan(yp);   
        areas{cond}{trial}(t) = area{cond}{trial}(t) + (x2 - x1) * (y2 - y1) / prod(moviesize);

      end
        
      roi{cond}{trial}(:,t) = double(sum(inside,2)>=1);
      roi{cond}{trial}(isnan(data{cond}{trial}(:,t,1)),t) = NaN;

    end
  end
end

%% movies coded

% note, there are 1-3 frames more on the end that we didn't use
starts = {{[1 109 259 407 513 600],[1 68 169 239 329 403 479 600],[1 70 137 248 422 524 600]},...
        {[1 139 293 441 600],[1 143 301 475 600],[1 120 218 323 444 600]}};
 
% zero means just holding, 1 means picking up or putting, 2 means complex
% action, throwing mixing banging, etc.
actions = {{[0 1 1 1 1],[2 1 0 1 2 2 2],[1 1 2 2 1 0]},...
          {[0 2 0 2],[0 2 2 1],[0 2 2 1 2]}}; 

fid = fopen('~/R/quantum/hand_looks.csv','w');
fprintf(fid,'sub,age,cond,clip,len,action,area,hand.look\n');

cs = [1 1 1;1 1 1];
for cond = 1:2
  for trial = 1:3
    lens = diff(starts{cond}{trial});
    
    for clip = 1:length(lens)
      for sub = 1:size(roi{cond}{trial},1);
        
        len = lens(clip);        
        clip_name = [num2str(cond) '-' num2str(trial) '-' num2str(clip)];
        data = roi{cond}{trial}(sub,...
          starts{cond}{trial}(clip)*2:starts{cond}{trial}(clip+1)*2);
        hand_look = nanmean(data);
        area = mean(areas{cond}{trial}(starts{cond}{trial}(clip)*2:...
          starts{cond}{trial}(clip+1)*2));
        
        if mean(~isnan(data)) < .3,
          hand_look = NaN;
        end
          
        switch actions{cond}{trial}(clip)
          case 0
            action = 'holding';
          case 1
            action = 'pickingputting';
          case 2
            action = 'complex';
        end
        
        fprintf(fid,'%d,%d,%s,%s,%d,%s,%2.2f,%2.4f\n',...
          sub,age_mo(sub),...
          points_files{cond}(1:end-1),...
          clip_name,...
          len,action,area,hand_look);

        a = actions{cond}{trial}(clip) + 1;
        hand_looks{cond,a}(sub,cs(cond,a)) = hand_look;
        
      end
      cs(cond,a) = cs(cond,a) + 1;
    end    
  end
end

fclose(fid);

%% plots

figure(1)
clf

c = 1;
cols = {{'r','r','r'},{'r','r','r'}};
action_names = {'holding actions','picking / putting actions','complex actions'};
panels = {1:5,8:12,17:21};



for i = 1
  for j = 1:3
    subplot(2,12,panels{j})
    cla
    set(gca,'FontSize',12)
    hold on
    ys = nanmean([hand_looks{i,j} hand_looks{2,j}],2);
%     plot(age_mo,ys,[cols{i}{j} '.'])
    
    h(i) = plot(age_mo,ys,'.','Color',cols{i}{j});
    [b bint r rint stats] = regress(ys,[ones(size(age_mo)) age_mo]);
    line([min(age_mo) max(age_mo)],[b(1) + min(age_mo)*b(2) ...
      b(1) + max(age_mo)*b(2)],'Color',cols{i}{j})
    
    if stats(3) < .01, sig = '**'; elseif stats(3) < .05, sig = '*'; else sig = ''; end;   
    
    text(max(age_mo)-4,b(1) + max(age_mo)*b(2) + .03,...
      ['r = ' num2str(sqrt(stats(1)),'%.02f') sig],'Color',cols{i}{j})
%     text(min(age_mo)-2,b(1) + min(age_mo)*b(2) - .03,...
%       legends{i}{j},'Color',cols{i}{j});

    axis([0 30 0 .4])

    if i == 1
      title(['\bf{' action_names{j} '}'])
      
%       if j == 1
%         xlabel('age (months')
        ylabel('proportion looking')
%       end
    end
  
%     if i == 2 & j == 3
%       legend(h(1:2),{'faces medium','faces plus'})
%     end
  
%     if j == 3
      xlabel('age (months)')
%     end
    
    disp(j)
    stats(1) = sqrt(stats(1));
    disp(stats)

    c = c + 1;
  end  
end
  
%% analyze areas

mean_areas{1} = [];
mean_areas{2} = [];
mean_areas{3} = [];


for cond = 1:2
  for trial = 1:3
    lens = diff(starts{cond}{trial});
    
    for clip = 1:length(lens)
      area = mean(areas{cond}{trial}(starts{cond}{trial}(clip)*2:...
          starts{cond}{trial}(clip+1)*2));

      mean_areas{actions{cond}{trial}(clip)+1} = ...
        [mean_areas{actions{cond}{trial}(clip)+1} area];
      
    end
  end
end
