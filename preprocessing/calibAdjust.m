%% constants for analysis
star_saccade_time = 30; % amount of time budgeted to get to the star (500ms)
data_threshold    = 60; % min number of samples for which we allow adjustment (1000ms)
samp_rate         = 60; % 60Hz samplign rate
calib_len         = 684; % length of calibration sequence (in samples)

times(:,1)        = [.01 3.00 6.00 9.34]; % the 4 times when star begins to be stationary
times(:,2)        = [2.0 4.97 8.34 11.34];
stars(:,1)        = [176 307 810 494]; % the 4 x-coords of the star when stationary
stars(:,2)        = [133 595 253 330]; 

times = round(times*samp_rate);

%% reshape calibration data

calib = data{5}{1}(:,1:calib_len,:);
calib(:,calib_len+1:2*calib_len,:) = data{5}{2}(:,1:calib_len,:);
calib(:,(calib_len*2)+1:3*calib_len,:) = data{5}{3}(:,1:calib_len,:);


%% remove movements, consolidate data, create predictors

c = 1;
for j = 1:3
  for i = 1:4
    range = times(i,1)+star_saccade_time : times(i,1)+118;
    range = range + ((j-1)*calib_len);
    calib_data(:,c:c+length(range)-1,1) = calib(:,range,1);
    calib_data(:,c:c+length(range)-1,2) = calib(:,range,2);

    calib_pred(c:c+length(range)-1,1) = stars(i,1);
    calib_pred(c:c+length(range)-1,2) = stars(i,2);
    c = c + length(range);
  end
end

%% perform individual robust regressions 
% corrected 5-18-11 (tom fritzche)

for i = 1:size(calib,1)
  x  = calib_data(i,:,1)';
  y  = calib_data(i,:,2)';  
  
  x_pred = calib_pred(:,1);
  y_pred = calib_pred(:,2);
  
  if sum(~isnan(y)) > data_threshold
    [x_b{i} x_stats] = robustfit(x_pred,x);
    [y_b{i} y_stats] = robustfit(y_pred,y);
    
    adj = [(x - x_b{i}(1)) / x_b{i}(2) ...
      (y - y_b{i}(1)) / y_b{i}(2)];
      
    % plot it
    figure(1)
    clf
    hold on
    plot(x,y,'b.');
    plot(adj(:,1),adj(:,2),'r.');
    plot(stars(:,1),stars(:,2),'k+','MarkerSize',20,'LineWidth',3)
    axis([0 1024 0 768])
    axis ij

    % get user input
    commandwindow
    home
    include(i) = input('Include calib for this subject? ') - 1;
  else
    include(i) = 0;
    x_b{i} = NaN;
    y_b{i} = NaN;
  end
end

