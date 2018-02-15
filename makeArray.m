function d = makeArray(raw)

for i = 1:length(raw)
  lens(i) = length(raw{i}.data);
end

d = nan(length(raw),max(lens),2);

for i = 1:length(raw)
  if ~isempty(raw{i}.data) && numel(raw{i}.data) > 1
    d(i,1:lens(i),1) = raw{i}.data(:,1);
    d(i,1:lens(i),2) = raw{i}.data(:,2);
  else % add null role
    d(i,:,:) = NaN;
  end
end