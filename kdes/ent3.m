% compute entropy quickly over a three-dimensional, smoothed array

function h = ent(dist)

% add a small smoothing factor epsilon
dist = (dist + eps) ./ sum(sum(sum(dist+eps)));
l_dist = log2(dist);
h = -sum(sum(sum(dist .* l_dist)));
