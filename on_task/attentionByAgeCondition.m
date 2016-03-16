clear all
load('../processed_data/quantum_data_adjusted15-Dec-2008.mat')

ages = [cellfun(@(x) x.age,info)];

for i=1:length(data)
    for j=1:length(data{i})
        for k=1:length(data{i}{j})
            this_trial = data{i}{j}{k};
            looking(i,j,k) = sum(~isnan(this_trial(:,2)))/length(this_trial);
        end
    end
end

%%

color = {'b','r','g','k'};
cvals = {[0 0 1],[1 0 0],[0 1 0 ],[0 0 0]};
means_subs = nanmean(looking,3);

%% bar graph of looking time by condition

means_conditions = nanmean(nanmean(looking,3));
stderrs_conditions = std(nanmean(looking,3))/sqrt(length(data));

figure(1)
errorbar(1:4, means_conditions, stderrs_conditions)
axis([0 5 .5 1]);
xlabel('Faces Pure,      Face med,      Faces Plus,      objects');
ylabel('Proportion looking');

% this does the same thing as next part, but less generalized
% figure(2)
% 
% plot(ages/30,means_subs(:,1),'b.',...
%     ages/30,means_subs(:,2),'r.',...
%     ages/30,means_subs(:,3),'g.',...
%     ages/30,means_subs(:,4),'k.')

%% plots of looking time vs age, one for each condition

figure(2)
clf
set(gca,'FontSize',16)
hold on


for i = 1:4
  h(i) = plot(ages/30,means_subs(:,i),[color{i} '.']);
  
  % this part needs the stats toolbox
  [b,bint,r,rint,stats] = regress(means_subs(:,i),[ones(length(ages),1) ages'/30]);
    % y = a + bx
  line([3 28],[b(1) + (3*b(2)) b(1) + (28*b(2))],'Color',cvals{i})
end

legend(h,'faces pure','faces med','faces plus','objects')
axis([ 0 30 0 1])
xlabel('age (months)')
ylabel('percent looking')