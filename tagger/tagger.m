% get label points.
% tagger by EV fall 06, lightly modified MCF summer 08

close all
clear all
warning off;

%% ---- GET INPUTS ----
fprintf('\nLabeling what?');
fprintf('\n1: Faces');
fprintf('\n2: Mouths');
fprintf('\n3: Eyes');
fprintf('\n4: Hands');
fprintf('\n5: Calibration Star\n');
ll = input('..?   ');
switch (ll)
  case 1
    fprintf('labeling FACES\n\n');
    prefix = 'FA';
  case 2
    fprintf('labeling MOUTHS\n\n');
    prefix = 'MO';
  case 3
    fprintf('labeling EYES\n\n');
    prefix = 'EY';
  case 4
    fprintf('labeling HANDS\n\n');
    prefix = 'HA';
  case 5
    fprintf('labeling CALIBRATION STAR\n\n');
    prefix = 'CA';
  otherwise
    fprintf('labeling OTHER\n\n');
    prefix = 'OT';
end

ld = input('Load progress file? [1|0] ');
if ld
    pfilename = input('Enter continued filename: ', 's');
    load(['pts/' pfilename '_' prefix '.mat']);
    progress = [1 length(points)];
else
    pfilename = input('Enter new filename: ', 's');
    progress = [1 1];
end
   
quit = false;
if(prod(progress) ~= 1)
    resume = true;
else
    resume = false;
end

moviedir = input('What directory are the movies in?: ','s');

% avifn = ls(moviedir);
% ls command doesn't seem to work for this
% change the list below to represent the actual movie names
% (whatever's in the directory)
% avifn = ['calib.avi', 'Face_med_1.avi', 'Face_med_2.avi', 'Face_med_3.avi', ...
%     'Faces_Plus_1.avi', 'Faces_Plus_2.avi', 'Faces_Plus_3.avi', ...
%     'Faces_Pure_1.avi', 'Faces_Pure_2.avi', 'Faces_Pure_3.avi', ...
%     'objects1', 'objects2', 'objects3'];
avifn = input('What is the movie filename? ', 's');
nf = size(avifn, 1);

fprintf(['\n\n*** instructions ***\n' ...
  'enter = no new ROI\n' ...
  'space = set point\n' ...
  'ss = same as last time\n' ...
  'qq = quit and save\n' ...
  '` (the `~ key) = start this ROI over (if you made an error in first point)\n\n']);
%  'esc = undo last ROI\n' ...

% "progress" is a variable that allows us to keep track of where we are in
% the tagging process. format: progress = [movie frame];

%% ---- RUN THE TAGGER ----

try % TRY/CATCH SO THAT WE SAVE DATA NO MATTER WHAT
  for mvidx = [progress(1):nf] % for all movies
    % --- LOAD MOVIE ---
    progress(1) = mvidx; 

    filename = strtrim(avifn(mvidx,:));
    fprintf('\nLoading file: %s ....... ', filename);
    tic;
    mv = aviread([moviedir '/' filename]);
    %eval(['load videos.mat ' filename]);
    %mv = eval(filename);
    %eval(['clear ' filename]);
    fprintf(' File loaded! (t: %0.5g s)', toc);
    nframes = length(mv);
    if(resume == true)
        load(['pts/' pfilename '_' prefix '.mat']);
        progress(2) = length(points);
        resume = false;
    else
        progress(2) = 1;
    end

    quit = false;
    
    % --- LOOP OVER FRAMES ---
    frame = progress(2);
    while frame <= nframes && quit == false % for each frame
      % --- TAG THIS FRAME ---
      progress(2) = frame;

      collecting = 1;
      pt = 0;
      clear resp;
      
      while collecting
        img = mv(frame).cdata;
        h = imagesc(uint8(img));
        alpha_rect = ones([size(img,1) size(img,2)]);
        
        if pt 
          alpha_rect = drawRect(alpha_rect, points(frame), .25);
        elseif frame > 1
          alpha_rect = drawRect(alpha_rect, points(frame-1), .75);          
        else
        end

        set(h,'AlphaData',alpha_rect);

        [points(frame).p1s{pt+1} points(frame).p2s{pt+1} resp{pt+1}] = getRect;
        
        if(resp{pt+1} == 0)
          collecting = 0;
          points(frame).p1s = {points(frame).p1s{1:pt}};
          points(frame).p2s = {points(frame).p2s{1:pt}};
        elseif(resp{pt+1} == -1)
          pt = pt - 1;
          if pt == 0
              points(frame).p1s = {};
              points(frame).p2s = {};
          else
              points(frame).p1s = {points(frame).p1s{1:pt}};
              points(frame).p2s = {points(frame).p2s{1:pt}};
          end
        elseif(resp{pt+1} == -2)
          collecting = false;
          quit = true;

          save(['pts/' pfilename '_' prefix '.mat'], 'points');
          save(pfilename, 'progress');
          return;
        elseif(resp{pt+1} == 1)
          pt = pt + 1;
        elseif(resp{pt+1} == 2)
          if frame > 1
            points(frame) = points(frame-1)       
            collecting = 0;
          else
            fprintf('cannot be the same: first frame!\n');
            points(frame).p1s{end} = [];
            points(frame).p2s{end} = [];
          end
        end        
      end
      
      fprintf('\nDone frame [%d/%d], Movie [%d/%d]', frame, nframes, mvidx, nf);
      frame = frame + 1;

      if quit == true
        fprintf('quitting and saving!\n')
      end      
    end

    save(['pts/' pfilename '_' prefix '.mat'], 'points');
    save(pfilename, 'progress');
    fprintf('saved');
    close all
  end
catch
  rethrow(lasterror);
  save(['pts/' pfilename '_' prefix '.mat'], 'points');
  save(pfilename, 'progress');
  fprintf('saved');
end
    