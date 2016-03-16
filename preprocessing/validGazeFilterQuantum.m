% [data, t] = validGazeFilter (prelimData, info [, threshold])
%
% bETk: use validity arrays to filter and combine prelimData (usually from tobii)
% Michael C. Frank
% 5/22/06
% rev with squishing 12/9/06
%
% Takes prelimData (with prelimData.L and prelimData.R as well as .validL/R
% info, and optionally a threshold value (default = 0) and spits back data, 
% a combined monocular gazepoint. Values are averaged when there's binocular
% prelimData but otherwise the eye with good prelimData is used.
%
% second varargin is imageSize to squish to (by taking only that size rect
% from the middle of the image).  this is useful if you are converting
% from a tracker with a bigger field of view.
%
% see also: validGazeFilter

function data = validGazeFilterQuantum(prelimData, squishRect)

fprintf('first round of data processing (validity etc.)\n')

threshold = 0;

validL = prelimData.validL <= threshold;
validR = prelimData.validR <= threshold;

% take only those datapoints which are valid
L = nan(size(prelimData.L));
R = nan(size(prelimData.R));
L(repmat(validL,1,2)) = prelimData.L(repmat(validL,1,2));
R(repmat(validR,1,2)) = prelimData.R(repmat(validR,1,2));

% X and Y are the mean if both eyes exist, otherwise just the one that we have
X = nanmean([L(:,1) R(:,1)],2);
Y = nanmean([L(:,2) R(:,2)],2); 

% clip those datapoints which are outside the frame
X(X > squishRect(1) | X <= 0) = NaN;
Y(Y > squishRect(2) | Y <= 0) = NaN;

% now take out any ts when one eye is NaN;
X(isnan(Y)) = nan(size(X(isnan(Y))));
Y(isnan(X)) = nan(size(Y(isnan(X))));

data = [X Y];
