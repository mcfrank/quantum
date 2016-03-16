load quantum_data_all.mat

looking = zeros(1, 1200);

for i=1:length(babies) % each i is a baby
    for j=1:length(babies{i}) % each j is a condition
        for k=1:length(babies{i}{j})
          % each k is a 20-second clip
          % 2-column matrix of eye positions
          % each column of k is a coordinate (x,y)
            this_trial = babies{i}{j}{k};
            if isempty(this_trial)
                continue
            end
            for timestep=1:min(length(this_trial), 1200)
              if ~isnan(this_trial(timestep, 1));
                looking(timestep) = looking(timestep) + 1;
              end
            end            
        end
    end
end

% plot the data
figure(1)
plot(looking)
xlabel('Number of Timesteps into Video')
ylabel('Number of Occurrences of Looking')