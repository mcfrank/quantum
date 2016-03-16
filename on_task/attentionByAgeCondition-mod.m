clear all
load quantum_data_all.mat
%load ages8-04.mat
for i=1:116
    ages(i) = info(i).age;
end

for i=1:length(babies)
    for j=1:length(babies{i})
        for k=1:length(babies{i}{j})
            this_trial = babies{i}{j}{k};
            looking(i,j,k) = sum(~isnan(this_trial(:,2)))/length(this_trial);
        end
    end
end

%% bar graph of looking time by condition

means_conditions = nanmean(nanmean(looking,3));
stderrs_conditions = std(nanmean(looking,3))/sqrt(36);

figure(1)
axis([0,5,0,1]);
xlabel('Pure, Medium, Plus, Objects')
title('Looking Time by Condition')
errorbar(1:4, means_conditions, stderrs_conditions)

%%

color = {'b','r','g','k'};
cvals = {[0 0 1],[1 0 0],[0 1 0 ],[0 0 0]};
means_subs = nanmean(looking,3);

%% plots of looking time vs age, one for each condition

figure(2)
plot(ages/30,means_subs(:,1),'b.',...
    ages/30,means_subs(:,2),'r.',...
    ages/30,means_subs(:,3),'g.',...
    ages/30,means_subs(:,4),'k.')

%%

figure(3)
clf
set(gca,'FontSize',16)
hold on


for i = 1:4
  h(i) = plot(ages/30,means_subs(:,i),[color{i} '.']);
  [b,bint,r,rint,stats] = regress(means_subs(:,i),[ones(36,1) ages/30]);
  
  % y = a + bx
  line([3 28],[b(1) + (3*b(2)) b(1) + (28*b(2))],'Color',cvals{i})
end

legend(h,'faces pure','faces med','faces plus','objects')
axis([ 0 30 0 1])
xlabel('age (months)')
ylabel('percent looking')