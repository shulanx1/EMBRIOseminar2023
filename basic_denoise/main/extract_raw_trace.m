function raw_f = extract_raw_trace(img, label)

if nargin < 2, label = 'ROI'; end
h = figure; imshow(stretch(img));
title(sprintf('Please select the ROI for %s', label))
p = drawrectangle('Label',label,'Color','m');
ydim = p.Position(4);
x1 = 1;
x2 = size(img, 2);

raw_f = zeros(ceil(ydim), size(img, 2));
for i = 1:ceil(ydim)    
    x = [x1, x2]; 
    y = [p.Position(2)+i-1, p.Position(2)+i-1];                
    raw_f(i, :) = improfile(img,x,y);    
end
raw_f = mean(raw_f, 1);
close(h)
end