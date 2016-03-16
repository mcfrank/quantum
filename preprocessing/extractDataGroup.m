% quantum script does all the preprocessing to get from raw data to a
% datafile that is used by other scripts

% original from mcf 6/06
% mod for quantum 7/20/08
% updated mcf 8/25/08 to incorporate calibration adjustment 
% worked on 3/16/09 to deal with subject filtering
% updated 12/13/09 with smoothing etc.

clear all;
save_path = '../processed_data/';
ages_path = '../raw_data/';
data_path = '../raw_data/include/';

%% read in data
disp('######### Reading in data #########');

[names ages] = textread([ages_path 'ages_and_codes.csv'],'%s%d','delimiter',',');

tic
for i = 1:length(names)
  fname = [data_path names{i} '.tsv'];
  data{i} = extractDataIndividual(fname);
end
toc

save([save_path 'quantum_raw_data' datestr(now,1)],'data','ages')

%% transform to array data
clear all
disp('######### Smoothing, clipping, and adjusting to array format #########');
load(['../processed_data/quantum_raw_data13-Dec-2009.mat'])

% c = ones(5,3);
for s = 1:length(data)
  for j = 1:5
    for k = 1:3
      if k <= length(data{s}{j}) && ~isempty(data{s}{j}{k})        
        raw{j}{k}{s}.data = data{s}{j}{k};
      else
        raw{j}{k}{s}.data = NaN;
%       c(j,k) = c(j,k) + 1;
      end
    end
  end
end

clear data
for i = 1:5 % five stimuli
  for j = 1:3 % three of each kind of movie
    tic
    disp(['working on ' num2str(i) ' ' num2str(j)]);
    data{i}{j} = makeArray(raw{i}{j});
     data{i}{j} = smoothDataArray(data{i}{j});
    toc
  end
end

save(['../processed_data/quantum_array_data' date '.mat'],'data','ages');

%% exclude on the basis of on-task and calibration performance
clear all
disp('######### Adjusting calibration and excluding #########');
load(['../processed_data/quantum_array_data14-Dec-2009.mat']);

c = 1;
for i = 1:4
  for j = 1:3
    ontasks(c,:) = sum(isnan(data{i}{j}(:,:,1)),2) ./ size(data{i}{j}(:,:,2),2);
    c = c + 1;
  end
end

on_task = mean(ontasks) > .2;

calibAdjust
save(['../processed_data/quantum_adjust_data' date '2'],'include','on_task','x_b','y_b')

%%
% clear all
disp('######### Adjusting calibration and excluding #########');
load(['../processed_data/quantum_array_data14-Dec-2009.mat']);
load(['../processed_data/quantum_adjust_data18-May-20112.mat']);

include = include;

bins = [1:2:29];
clf
set(gca,'FontSize',14)
age_mo = ages / [365/12];
hold on;

hist(age_mo,bins)
h = findobj(gca,'Type','patch');
set(h,'FaceColor',[.75 .75 .75])

hist(age_mo(logical(include)),bins)
h = findobj(gca,'Type','patch');
set(h(1),'FaceColor',[.5 .5 .5])

hist(age_mo(logical(include) & logical(on_task)),bins)
h = findobj(gca,'Type','patch');
set(h(1),'FaceColor',[.25 .25 .25])

axis([0 30 0 40])

legend(h(3:1),{'Tracked','Calibration OK','and contributed data'})
xlabel('age (months)')
ylabel('number of participants')
%%
makeCalibAdjustments
save(['../processed_data/quantum_final_data' date],'data','ages')
