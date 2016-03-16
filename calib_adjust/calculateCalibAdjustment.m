% calculateCalibAdjustment.m 
% michael c. frank - 4/28/10
%
% this script takes "data" - a set of eye-tracking data, and--using
% knowledge of where the calibration check stimulus appears--adjusts the
% point of gaze so that it better fits the calibration check. the user is
% then queried as to whether the adjustment was sufficient and whethe it
% should be included in the study. adjustment parameters are also returned
% ("x_b" and "y_b") so that they can be used with
% "applyCalibrationAjustment.m"
%
% the format for the eye-tracking data is simple. it is a cell array of 
% [n x 2] matrices, where n is the number of datapoints collected, and each
% pair of points are x and y values for a particular timestep.
%
% e.g.:
% data{1} = [x_1 y_1; x_2 y_2; x_3 y_3; ... ; x_n y_n];
%
% note this code is easy to generalize to the case where you run the
% calibration check more than once. this is encouraged, we just cut the
% code down to make it simpler to read.

%% constants for analysis

clear all

saccade_time      = 25; % amount of time budgeted to get to the target (500ms)
data_threshold    = 20; % min number of samples for which we allow adjustment (1000ms)
samp_rate         = 50; % 50Hz sampling rate

% --- values for the annulus stimulus, calib_check.avi ---
times = [1 cumsum(repmat([2 .5] * samp_rate,1,11))+1 1475];

pts = [[512 384]; [512 384]; [312 184]; [312 184]; [312 584]; [312 584]; ...
       [712 184]; [712 184]; [712 584]; [712 584]; [512 384]; [512 384]; ...
       [512 384]; [512 384]; [512 584]; [512 584]; [712 364]; [712 364];
       [512 184]; [512 184]; [312 384]; [312 384]; [512 384]; [512 384]];

% ---  values for the star sequence, star_calib.avi ---
% times(:,1)        = [.01 3.00 6.00 9.34]; % the 4 times when star begins to be semi-stationary
% times(:,2)        = [2.0 4.97 8.34 11.34]; % the 4 times when it ends being semi-stationary
% pts(:,1)        = [176 307 810 494]; % the 4 x-coords of the star when stationary
% pts(:,2)        = [133 595 253 330]; % the 4 y-coords of the star when stationary
% 
% times = round(times*samp_rate);

%% here is where you would load your calibration data

load calib_data.mat

%% reshape calibration data

max_data_len = max(cellfun(@(x) size(x,1),calib_data));
calib = nan(length(calib_data),max_data_len,2);

for i = 1:length(calib_data)
  calib(i,1:length(calib_data{i}),:) = calib_data{i}; 
end

%% remove breaks between stationary points

c = 1;
for i = 1:2:length(times)-1
  range = times(i) + saccade_time : times(i+1);
  
  % remove breaks between stationary points 
  all_calib_data(:,c:c+length(range)-1,1) = calib(:,range,1);
  all_calib_data(:,c:c+length(range)-1,2) = calib(:,range,2);

  % create regression tersm for where the target actually is
  calib_pred(c:c+length(range)-1,1) = pts(i,1);
  calib_pred(c:c+length(range)-1,2) = pts(i,2);
  c = c + length(range);
end

%% now perform the robust regression for each and query user
% note, updated 5-18-11

for i = 1:size(all_calib_data,1)
  x  = all_calib_data(i,:,1)';
  y  = all_calib_data(i,:,2)';    
  x_pred = calib_pred(:,1);
  y_pred = calib_pred(:,2);
  
  % if we have enough data to perform a reasonable regression
  if sum(~isnan(y)) > data_threshold
    % do separate x and y robust regressions  
    [x_b{i} x_stats] = robustfit(x_pred,x);
    [y_b{i} y_stats] = robustfit(y_pred,y);

    % this is the slope/intercept adjusted data
    adj = [(x - x_b{i}(1)) / x_b{i}(2) ...
      (y - y_b{i}(1)) / y_b{i}(2)];

    % plot it
    figure(1)
    clf
    subplot(1,2,1)
    hold on    
    plot(x,y,'b.');   
    plot(pts(:,1),pts(:,2),'k+','MarkerSize',20,'LineWidth',3)
    axis([0 1024 0 768])
    title('unadjusted')
    axis ij
    
    subplot(1,2,2)
    hold on
    plot(adj(:,1),adj(:,2),'r.');    
    plot(pts(:,1),pts(:,2),'k+','MarkerSize',20,'LineWidth',3)
    axis([0 1024 0 768])
    title('adjusted')
    axis ij

    % get user input on whether the subject should be included
    include(i) = input([num2str(i) ': Include calib for this subject? [0/1]']);
  else % if there's not enough data    
    include(i) = 0;
    x_b{i} = NaN;
    y_b{i} = NaN;
  end
end

save calib_adjustments.mat include x_b y_b
% now we are left with "x_b" and "y_b," the regression terms for adjusting the
% track and "include," the subjects we want to keep in the study.
