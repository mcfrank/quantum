% checks for ROI corners outside frame

for file = {'Faces_Plus_1_FA.mat' 'Faces_Pure_1_FA.mat' 'Faces_Pure_3_EY.mat' 'Face_med_1_FA.mat' 'Faces_Plus_1_HA.mat' 'Faces_Pure_1_HA.mat' 'Faces_Pure_3_FA.mat' 'Face_med_1_HA.mat' 'Faces_Plus_2_FA.mat' 'Faces_Pure_2_EY.mat' 'Faces_Pure_3_MO.mat' 'Face_med_2_HA.mat' 'Faces_Plus_3_FA.mat' 'Faces_Pure_2_FA.mat' 'Face_med_3_FA.mat' 'Faces_Plus_3_HA.mat' 'Faces_Pure_2_HA.mat' 'Face_med_3_HA.mat' 'Faces_Pure_1_EY.mat' 'Faces_Pure_2_MO.mat'}
    eval(sprintf('load pts/%s', char(file)))
    fprintf('file: %s\n', char(file))
    for i=1:length(points)
        for j=1:length(points(i).p1s)
            if points(i).p1s{j}(1) < 0
                fprintf('x1 < 0. i = %d\n', i)
            end
            if points(i).p1s{j}(2) < 0
                fprintf('y1 < 0. i = %d\n', i)
            end
            if points(i).p2s{j}(1) > 576
                fprintf('x2 > 576. i = %d\n', i)
            end
            if points(i).p2s{j}(2) > 720
                fprintf('y2 > 720. i = %d\n', i)
            end
        end
    end
end