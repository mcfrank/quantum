
clear all
load kdes_grid_50.mat

conds = ['Faces_Pure_', 'Face_med_', 'Faces_Plus_', 'objects'];

%% calculate entropies

for cond = 1:4
    for inst = 1:3
        for i = 1:length(kde{1}{cond}{inst})
            fent{cond}{inst}(i,1) = ent3(kde{1}{cond}{inst}(:,:,i));
            fent{cond}{inst}(i,2) = ent3(kde{2}{cond}{inst}(:,:,i));
            fent{cond}{inst}(i,3) = ent3(kde{3}{cond}{inst}(:,:,i));
        end
    end
end

fent_smoothed = runmean(fent,30);

%% plot one figure for each instance of each condition

for cond = 1:4
    for inst = 1:3
        figure();
        clf;
        set(gca,'FontSize',16)
        hold on
        %plot(fent,'--');
        legend('< 12mo','12 - 17mo','> 17mo')
        plot(fent_smoothed)
        axis([0 1200 5 8])
        xlabel('timesteps')
        ylabel('entropy (bits)')
        title([conds(cond) inst])
    end
end

%% analyze

