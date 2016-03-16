clear all
load('../processed_data/quantum_final_data14-Dec-2009.mat')
load mats/grid_80-2groups.mat

%% variables

c = 1;
m = 1;
conds = {'Faces_Pure_','Face_med_','Faces_Plus_','objects'};

groups = {'6mo - 12mo','12mo - 30mo'};
splits = quantile(ages,[.5]);
young = ages < splits(1);
old = ages > splits(1);

age_grp = young+old*2;
sq_size = 4;


%% make movie
figure(1)
axis off

for c = 2
  tic
  disp(['condition ' conds{c}])
  mkdir(['movies/' conds{c} ]);

  for i = 1:600
    fprintf('%d ',i);
    if mod(i,15) == 0, fprintf('\n'); end
    
    for g = 1:2
      subplot(1,2,g)
      
      % first plot movie
      f_img = zeros(768,1024,3);
      f_img(97:672,129:896,:) = imread(['../movie_images/' conds{c}  num2str(m) '/' conds{c} ...
        num2str(m) num2str(i,'%03.0f')],'jpg');

      alphamap = imresize(kde{g}{c}{1}(:,:,i*2),[768 1024],'bicubic');

      for j = 1:3
        f_img(:,:,j) = f_img(:,:,j) .* alphamap * 7;
      end

      imagesc(uint8(f_img))
      axis off
      title(groups{g},'FontSize',16);
    end

    drawnow
    imwrite(uint8(f_img),['movies/' conds{c}  '/frame_' num2str(i) '.jpg'],'jpg')
  end
  fprintf('\n')
  toc
end