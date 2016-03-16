% cross-recurrence analysis

load quantum_data_all.mat;
reorderBabies;

conds = {'Faces_Pure', 'Face_med', 'Faces_Plus', 'objects'};
 
info = sub_info{1}; % provides screen size / pixel info
% info.pixelsPerDegree = 58; % this might be totally wrong
threshold = 100; % pixel threshold
eta = 10; % timestep threshold

correlations = zeros(length(babies), length(babies), 4, 3, 2);

for baby=1:length(babies)
    for cond=1:4
        for inst=1:3
            for other_baby = 1:length(babies)
                if (baby == other_baby)
                    % don't compare same baby with himself
                    rr = NaN;
                    rw = NaN;
                elseif correlations(other_baby, baby, cond, inst, 1) ~= 0
                    % if this comparison has already been done, copy the numbers
                    rr = correlations(other_baby, baby, cond, inst, 1);
                    rw = correlations(other_baby, baby, cond, inst, 2);
                else
                    % otherwise, calculate the cross-recurrence
                    [rr rw] = eucrp(babies{baby}{cond}{inst}, ...
                        babies{other_baby}{cond}{inst}, info, threshold, eta);
                end
                correlations(baby, other_baby, cond, inst, 1) = rr;
                correlations(baby, other_baby, cond, inst, 2) = rw;
            end
        end
        avgs(baby, cond, 1) = nanmean(nanmean(correlations(baby, :, cond, :, 1)));
        avgs(baby, cond, 2) = nanmean(nanmean(correlations(baby, :, cond, :, 2)));
        ages(baby, 1) = baby_info(baby).age;
        ages(baby, 2) = 1;
    end
end

%%
save('crossRecurrenceData.mat', 'correlations', 'avgs', 'ages');

colors = 'brgk';
figure()
for cond=1:4
    plot(ages(:, 1), avgs(:, cond, 1), [colors(cond) '.']);
    hold on
    [coeffs, confIntervals, resids, residIntervals, stats] = regress(avgs(:, cond, 1), ages);
    rsquare = stats(1); F = stats(2); p = stats(3); err = stats(4);
    for i=1:max(ages)
        lineYs(i) = i*coeffs(1) + coeffs(2);
    end
    plot([1:max(ages)], lineYs, colors(cond));
    xlabel('Age (days)')
    ylabel('Average Cross-Recurrence')
    title('Cross-Recurrence versus Age')
    legend(conds)
end