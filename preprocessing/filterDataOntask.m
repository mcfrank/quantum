% filter data by how many trials they contributed etc.

clear all
load ../processed_data/quantum_raw_data16-Mar-2009.mat
%% do filtering

for i = 1:length(data)
  for j = 1:4
    for k = 1:3
      if size(data{i}{j}{k},1) > 100
        ontask(i,j,k) = sum(isnan(data{i}{j}{k}(:,1)))/size(data{i}{j}{k},1);
      else
        ontask(i,j,k) = 0;
      end
    end
  end
end

%% define criterion
crit = .3;
ontask_by_sub = mean(mean(ontask(:,1:4,:),3),2);
include = ontask_by_sub>crit;

%% plot it
hist(ages(ontask_by_sub>crit)/30,0:3:36)
set(gca,'XTick',0:3:36)

title(num2str(sum(ontask_by_sub>crit)));

%% exclude them and save
data = data{include};
ages = ages(include);

save(['../processed_data/quantum_ontask_data' datestr(now,1)],'data','ages')

