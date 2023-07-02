function [raw_f, Cn, A ]= extract_raw_trace_video(img, N)
Cn = std(img, [], 3);
FOV = [size(Cn, 1), size(Cn, 2)];
if nargin < 2, N = 1; end
h = figure(1); imshow(stretch(Cn));
title(sprintf('Please select the ROI'))
raw_f = zeros(N, size(img, 3));
A = sparse(N, FOV(1)*FOV(2));
for i = 1:N
    p = drawcircle('Label',sprintf('ROI%d', i),'Color','m');
    theta = 0:pi/8:2*pi-(pi/8);
    rho = p.Radius*ones(1,16);
    [x,y] = pol2cart(theta,rho);
    
    coor = [round(x) + p.Center(1)*ones(1, 16);round(y) + p.Center(2)*ones(1, 16)];
    A(i,:) = spatial_contour(coor', FOV, Cn, 0.2);
    raw_f(i,:) = ROI_fluorescence(img, A(i,:));
end
end