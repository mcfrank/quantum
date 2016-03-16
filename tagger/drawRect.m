function alpha_rect = drawRect(alpha_rect, points, a)


if ~isempty(points.p1s)
  for i = 1:length(points.p1s)
    alpha_rect(points.p1s{i}(1):points.p2s{i}(1),points.p1s{i}(2):points.p2s{i}(2)) = a;
  end
end

% alpha = ones([size(img,1) size(img,2)]);
%   newim(p1s{i}(1):p2s{i}(1), p1s{i}(2):p2s{i}(2), :) = repmat(reshape(cols(i,:), [1 1 3]), sz);
%   sz = [length(p1s{i}(1):p2s{i}(1)), length(p1s{i}(2):p2s{i}(2)) 1];
