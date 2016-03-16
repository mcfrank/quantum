% corrected 5-18-11 (tom fritzche)

prelim_data = data;
clear data

for c = 1:4
  for m = 1:3
    inc = 1;
    for i = find(include & on_task) % include relative to human coded inclusion judgments

      trial = squeeze(prelim_data{c}{m}(i,:,:));
      x = trial(:,1);
      y = trial(:,2);
      
      % adjust relative to robust regression results
      adj_trial = [(x - x_b{i}(1)) / x_b{i}(2) ...
        (y - y_b{i}(1)) / y_b{i}(2)];

      len = 1:length(adj_trial);
      
      trial = [x y];

      % clip 
      x_ob = adj_trial(:,1) > 1024 | adj_trial(:,1) < 0;
      y_ob = adj_trial(:,2) > 768 | adj_trial(:,2) < 0;
      
      fprintf('%d %d %d %d %d\n',i,c,m,sum(x_ob),sum(y_ob));
      
      adj_trial(x_ob,1) = NaN;
      adj_trial(y_ob,1) = NaN;
      
      % consolidate
      data{c}{m}(inc,len,1) = adj_trial(:,1);
      data{c}{m}(inc,len,2) = adj_trial(:,2);         
      
      inc = inc+1;
    end
  end
end

ages = ages(include & on_task);