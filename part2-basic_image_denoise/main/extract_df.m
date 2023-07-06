function df = extract_df(f, dt, win)
% compute df/f from the raw fluorescence trace
% f: raw fluorescence
% dt: line rate (s)
% win: time window of baseline fluoresence (s), default to be the first 10 ms 
if nargin < 3, win = [0, 0.01]; end
baseline = mean(f(ceil(win(1)/dt)+1:ceil(win(2)/dt)));
df = (f-baseline)/baseline;
end