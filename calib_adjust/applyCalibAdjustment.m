% applyCalibAdjustment.m 
% michael c. frank - 4/28/10
%
% this script is very schematic, because it's hard to know what format the
% data for a particular study will be in. basically, it takes the "include"
% and "x_b"/"y_b" variables from "calculateCalibAdjustment.m" and applies
% them to a dataset contained in "raw_data," outputting "adj_data."

%% constants for analysis

clear all

x_bound = 1024; % screen width in pixels
y_bound = 768;  % screen height in pixels

%% here is where you would load your raw data

% as before, raw data should be in a cell array of [n x 2] matrices of x,y
% coordinates, named raw_data:
%
% raw_data{1} = [x_1 y_1; x_2 y_2; x_3 y_3; ... ; x_n y_n];
load raw_data.mat
load calib_adjustments.mat

%% go through and adjust and consolidate all data
% note, updated 5-18-11

inc = 1;
for i = find(include) % include relative to human coded inclusion judgments
  trial = raw_data{i};
  x = trial(:,1);
  y = trial(:,2);

  % adjust relative to robust regression results
  adj_trial = [(x - x_b{i}(1)) / x_b{i}(2) ...
    (y - y_b{i}(1)) / y_b{i}(2)];
  len = 1:length(adj_trial);

  % clip so that the adjusted trial doesn't go outside of screen bounds
  x_ob = adj_trial(:,1) > x_bound | adj_trial(:,1) < 0;
  y_ob = adj_trial(:,2) > y_bound | adj_trial(:,2) < 0;

  % print how many got clipped, this is a good marker that something has
  % gone wrong if a lot of points get clipped.
  fprintf('%d %d %d\n',i,sum(x_ob),sum(y_ob));

  adj_trial(x_ob,1) = NaN;
  adj_trial(y_ob,1) = NaN;

  % consolidate into final dataset
  adj_data{inc} = adj_trial;
 
  inc = inc + 1;
end

fprintf('%d subjects excluded.\n',length(include)-sum(include));
