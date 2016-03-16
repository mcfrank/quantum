% does a cross-recurrence plot based on euclidean distance (as in between
% two gaze arrays)

% calculates rr: the percentage of possible recurrence
%            rw: the mean recurrence distance 

% mcf, circa 6/06

% add an extra 4th argument to plot

function [rr rw] = eucrp(a,b,info,varargin)

% this is the eta value, around which we calculate rw (it's a threshold of
% timesteps on both sides)
if nargin > 4, eta = varargin{2}; else eta = 3; end;

dmax = sqrt(info.imageSize(1).^2 + info.imageSize(2).^2); % ./ info.pixelsPerDegree; % max distance apart
[sax, say] = size(a);
[sbx, sby] = size(b);
length = min(sax, sbx);

% do the actual calculations
ax = a(1:length,1);
ay = a(1:length,2);
bx = b(1:length,1);
by = b(1:length,2);
im = zeros(length, length);
axs = repmat(ax,1,length);
ays = repmat(ay,1,length);
bxs = repmat(bx',length,1);
bys = repmat(by',length,1);
dx = (axs - bxs).^2;
dy = (ays - bys).^2;

im = sqrt(dx + dy); 
% im = im ./ info.pixelsPerDegree; % do it in degrees

% do we do euclidean distance?  or do we use a threshold to make a
% recurrence plot?

if nargin > 3
    threshold = varargin{1};
    im = im < threshold; % threshold is in degrees % no it isn't
else
    im = im ./ dmax; % normalize otherwise
end;

% calculate rws
for i = 1:size(im,1)
    rws(i) = nansum(im(i,max(i-eta,1):min(i+eta,end)));
    possible_rws(i) = nansum(~isnan(im(i,max(i-eta,1):min(i+eta,end))));
end;

% normalize the number of rr points by the number of potential
% recurrent points
if nansum(nansum(~isnan(im))) == 0, rr = NaN; rw = NaN; else
    rr = nansum(nansum(im)) / nansum(nansum(~isnan(im)));
    rw = nanmean(rws ./ possible_rws);
end;

% if there's an extra argument, plot it!
if nargin > 5
    h = varargin{3};
    %set(h,'FontSize',1);
    image(((1-im).*64)); %,'Parent',h);
    axis xy;
    axis image;
    box on;
%     colormap('copper');
%     set(h,'TickLength',[0 0],'YTick',0,'XTick',0);
end;