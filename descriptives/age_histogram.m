%% age histograms for the three different stages
m = 365/12;

subplot(1,3,1)
set(gca,'FontSize',16)
load ../processed_data/quantum_raw_data16-Mar-2009.mat
h1 = hist(ages/m,0:3:30)
xlabel('age (months)')
ylabel('number of babies')
axis([-1.5 30 0 60])
title(['all data: n=' num2str(length(ages))]);

subplot(1,3,2)
set(gca,'FontSize',16)
load ../processed_data/quantum_ontask_data17-Mar-2009.mat
h2= hist(ages/m,0:3:30)
xlabel('age (months)')
ylabel('number of babies')
axis([-1.5 30 0 60])
title(['on task > 30%: n=' num2str(length(ages))]);

subplot(1,3,3)
set(gca,'FontSize',16)
load ../processed_data/quantum_final_data17-Mar-2009.mat
h3 = hist(ages/m,0:3:30)
xlabel('age (months)')
ylabel('number of babies')
axis([-1.5 30 0 60])
title(['on task > 30% & adjusted calibration: n=' num2str(length(ages))]);

%% 
figure(2)

plot(0:3:30,h3./h1)