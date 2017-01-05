function dat = removeOutliersFromData(dat,thresh)
%function to remove outliers from data. 
% dat is a vector containing the data
% thresh gives number of std's away to remove  
% can provide a as vector [threshhi, threshlow] (default [3, 3]),
% if single number provided, used for both hi and low.

if ~exist('thresh','var')
    thresh = [3 3];
end

if length(thresh) == 1
    thresh = [thresh thresh];
end

mdat = mean(dat);
sdat = std(dat);

toohigh = dat > mdat + thresh(1)*sdat;
toolow = dat < mdat - thresh(2)*sdat;

dat(toohigh | toolow) = [];