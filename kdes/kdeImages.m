%% images of kdes

figure(2);
set(gcf,'Renderer','OpenGL')
clf

labels = {'Faces pure','Faces medium','Faces plus','Objects'};
grps = {'<10mo','10-13mo','>13mo'};

frame = 1100:1197;
for g = 1:2
  for c = 1:4
    max_vals(g,c) = max(max(mean(kde{g}{c}{1}(:,:,frame),3)));
  end
end

max_val = max(max(max_vals));

i = 1;
for g = 1:2
  for c = 1:3    
    subplot(3,3,i+3)    
    set(gca,'FontSize',16)
    imagesc(mean(kde{g}{c}{1}(:,:,frame),3),[0 max_val])
    i = i + 1;
    
    if g==3
      xlabel(labels{c});
    end
    
    if c==1 
      ylabel(grps{g});
    end
    
    set(gca,'Box','off','XTick',[],'YTick',[]);
%     rectangle('Position',[ceil(129/gridsize) ceil(97/gridsize) ceil(768/gridsize) ceil(576/gridsize)])
    title([ num2str(entropy(g,c,1),'%2.2f') ' bits'],'FontSize',16);
  end
end

fs = {'Faces_Pure_1_end.jpg','Face_med_1_end.jpg','Faces_Plus_1_end.jpg','objects1_end.jpg'};
for i = 1:3
  subplot(4,3,i)
  im = imread(['ends/' fs{i}],'JPEG');
  lim = zeros(768,1024,3);
  lim(97:672,129:876,:) = im(:,1:748,:);
  lim = uint8(lim);    

  imagesc(lim);
  axis off
end

%% 

for i = 900:1200
  subplot(1,3,1)
  imagesc(kde{1}{1}{1}(:,:,i),[0 max_val])
  axis off
  
  subplot(1,3,2)
  imagesc(kde{2}{1}{1}(:,:,i),[0 max_val])
  axis off
  
  subplot(1,3,3)  
  c = ceil(i / 1.904);
  im = imread(['../movie_images/Faces_Plus_1/Faces_plus_1' num2str(c,'%03.f') '.jpg'],'JPEG');
  lim = zeros(768,1024,3);
  lim(97:672,129:876,:) = im(:,1:748,:);
  lim = uint8(lim);    
  
  imagesc(lim)
  axis off
  drawnow
end