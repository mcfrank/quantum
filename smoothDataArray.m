% ed vul originally spring 07
% via bilateral filter algorithm

function smooth_data = smoothereese(data)

scales = 3;
iscales = 30;

tic;
nb = size(data,1);
for baby = 1:nb    
  fprintf('%d ',baby);
  allxds =  data(baby,:, 1);
  allyds =  data(baby,:, 2);

  [x1 x2] = meshgrid(allxds, allxds);
  iw = exp(-(x1-x2).^2./(2.*iscales.^2));
  iwa = 1; %((x1-x2)<100);
  [x1 x2] = meshgrid(allyds, allyds);
  iw2 = exp(-(x1-x2).^2./(2.*iscales.^2));
  iwa2 = 1; %((x1-x2)<100);
  [t1 t2] = meshgrid((1:length(allxds)), (1:length(allxds)));
  dw = exp(-(t1-t2).^2./(2.*scales.^2));

  tw = iwa.*iwa2.*iw .* iw2 .* dw;

  goodx = find(~isnan(allxds));
  goody = find(~isnan(allyds));

  smx = nan(1, length(allxds));
  smy = nan(1, length(allyds));
  smx(goodx) = sum(tw(goodx,goodx) .* repmat(allxds(goodx)',1, length(allxds(goodx))), 1) ./ sum(tw(goodx,goodx), 1);
  smy(goody) = sum(tw(goody,goody) .* repmat(allyds(goody)',1, length(allyds(goody))), 1) ./ sum(tw(goody,goody), 1);

  smooth_data(baby,:,1) = smx;
  smooth_data(baby,:,2) = smy;
end

fprintf('\t* smoothing in %2.2g sec\n', toc);
