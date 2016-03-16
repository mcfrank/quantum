%% constants
% look at hand looking broken down by what kind of action

clear all
load ../processed_data/quantum_final_data18-May-2011.mat

points_files = {'Faces_Pure_'};
cond_targets = {{'EY','MO'}};
smooth_rad = 15;
moviesize = [768 576];
framesize = [1024 768];
adjust = [framesize - moviesize] /2;
movie_lens = 1200;
age_mo = ages / [365/12];

%% MOVIE LOOP

for cond = 1
  disp(['condition ' num2str(cond)])
  targets = cond_targets{cond};
  for trial = 1:3
    fprintf('\ttrial %s\n',num2str(trial))
    for targ = 1:length(targets)
      load(['pts/' points_files{cond} num2str(trial) '_' targets{targ}]);
      eval([targets{targ} '=points;']);     
    end

    for t = 1:movie_lens
      f = ceil(t/2); % convert to movie frames at 30 fps
      c = ceil(t/1.905); % convert to coded frames at 30 fps

      xp = data{cond}{trial}(:,t,1) - adjust(1);
      yp = data{cond}{trial}(:,t,2) - adjust(2);

      for targ = 1:length(targets)
        area{targ}{cond}{trial}(t) = 0;
        inside{targ} = zeros(size(data{cond}{trial},1),1);
        points = eval([targets{targ} '(c);']);
        
        for p = 1:length(points.p1s)
          x1 = points.p1s{p}(2) - smooth_rad;
          x2 = points.p2s{p}(2) + smooth_rad;
          y1 = points.p1s{p}(1) - smooth_rad;
          y2 = points.p2s{p}(1) + smooth_rad;

          inside{targ}(:,p) = xp >= x1 & xp <= x2 & yp >= y1 & yp <= y2 & ~isnan(xp) & ~isnan(yp);   
          area{targ}{cond}{trial}(t) = area{targ}{cond}{trial}(t) + (x2 - x1) * (y2 - y1) / prod(moviesize);
        end
        
        roi{targ}{cond}{trial}(:,t) = double(sum(inside{targ},2)>=1);
        roi{targ}{cond}{trial}(isnan(data{cond}{trial}(:,t,1)),t) = NaN;
      end
    end
  end
end


%% movies coded

% note, there are 1-3 frames more on the end that we didn't use
starts = {{[1 51 182 292 437 548 600],[1 235 352 434 508 600],[1 168 281 346 400 455 510 600]}};
 
% 0 means no mouth, 1 means mouth involved
actions = {{[1 1 0 1 0 1],[1 1 1 0 0],[0 0 1 0 1 1 1]}};       

fid = fopen('~/R/quantum/face_looks.csv','w');
fprintf(fid,'sub,age,clip,len,action,roi,area.look,area\n');

cs = [1 1; 1 1];

for cond = 1:2
  for trial = 1:3
    lens = diff(starts{1}{trial});

    for clip = 1:length(lens)
      for sub = 1:size(roi{cond}{1}{trial},1);

        len = lens(clip);        
        clip_name = [num2str(trial) '-' num2str(clip)];
        data = roi{cond}{1}{trial}(sub,...
          starts{1}{trial}(clip)*2:starts{1}{trial}(clip+1)*2);
        area_look = nanmean(data);

        if mean(~isnan(data)) < .3,
          area_look = NaN;
        end

        switch actions{1}{trial}(clip)
          case 0
            action = 'no mouth';
          case 1
            action = 'with mouth';
        end

        switch cond
          case 1
            roi_name = 'eyes';
          case 2
            roi_name = 'mouth';
        end

        this_area = mean(area{cond}{1}{trial}(starts{1}{trial}(clip)*2:...
          starts{1}{trial}(clip+1)*2));
      
        fprintf(fid,'%d,%d,%s,%d,%s,%s,%2.4f,%2.2f\n',...
          sub,age_mo(sub),...
          clip_name,...
          len,action,roi_name,area_look,this_area);

        a = actions{1}{trial}(clip) + 1;
        area_looks{cond,a}(sub,cs(cond,a)) = area_look;

      end

%       eye_areas{trial}(clip) = mean(area{1}{1}{trial}(starts{1}{trial}(clip)*2:...
%         starts{1}{trial}(clip+1)*2));
%       mouth_areas{trial}(clip) = mean(area{2}{1}{trial}(starts{1}{trial}(clip)*2:...
%         starts{1}{trial}(clip+1)*2));

      cs(cond,a) = cs(cond,a) + 1;
    end    
  end
end

fclose(fid);

%%

figure(1)
clf

c = 1;
cols = {{'m','m'},{'b','b'}};
action_names = {'no mouth expression','talking/smiling'};
legends = {{'eyes','eyes'},{'mouth','mouth'}};
for i = 1:2
  for j = 1:2
    subplot(2,1,j)
    set(gca,'FontSize',12)
    hold on
    ys = nanmean([area_looks{i,j}],2);
%     plot(age_mo,ys,[cols{i}{j} '.'])
    
    plot(age_mo,ys,'.','Color',cols{i}{j});
    h(i,j) = plot(nan,nan,'.-','Color',cols{i}{j});
    [b bint r rint stats] = regress(ys,[ones(size(age_mo)) age_mo]);
    line([min(age_mo) max(age_mo)],[b(1) + min(age_mo)*b(2) ...
      b(1) + max(age_mo)*b(2)],'Color',cols{i}{j})
    
    if stats(3) < .01, sig = '**'; elseif stats(3) < .05, sig = '*'; else sig = ''; end;   
    
    text(max(age_mo)-4,b(1) + max(age_mo)*b(2) + .02 + .04*(1-(i-1)),...
      ['r = ' num2str(sqrt(stats(1)),'%.02f') sig],'Color',cols{i}{j})
    text(min(age_mo)-2,b(1) + min(age_mo)*b(2) + .03,...
      legends{i}{j},'Color',cols{i}{j});

    axis([0 30 0 .8])

    if i == 1
      title(['\bf{' action_names{j} '}'])
      
      if j == 1
%         xlabel('age (months')
        ylabel('proportion looking')
      end
    end
  
%     if i == 2 & j == 3
%       legend(h(1:2),{'faces medium','faces plus'})
%     end
  
    if j == 2
      xlabel('age (months)')      
    end
    
%     if j == 1 & i == 2
%       legend(h(:,1),{'eyes','mouths'})
%     end
    
    disp(j)
    stats(1) = sqrt(stats(1));
    disp(stats)

    c = c + 1;
  end  
end
  
%% AREA analysis
% targ cond trial
ea1 = []; ea0 = []; ma1 = []; ma0 = [];
for i = 1:3
  ea1 = [ea1 eye_areas{i}(logical(actions{1}{i}))];
  ea0 = [ea0 eye_areas{i}(~logical(actions{1}{i}))];
  ma1 = [ma1 mouth_areas{i}(logical(actions{1}{i}))];
  ma0 = [ma0 mouth_areas{i}(~logical(actions{1}{i}))];
end