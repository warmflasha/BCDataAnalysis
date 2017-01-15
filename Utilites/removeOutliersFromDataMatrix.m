function dat = removeOutliersFromDataMatrix(dat,thresh,alldat)
%function to remove outliers from data. 
% dat is a vector containing the data
% thresh gives number of std's away to remove  
% can provide a as vector [threshhi, threshlow] (default [3, 3]),
% if single number provided, used for both hi and low.

if ~exist('thresh','var') || isempty(thresh)
    thresh = [3 3];
end

if length(thresh) == 1
    thresh = [thresh thresh];
end
if exist('alldat','var')    
    mdat = meannonan(alldat);
    sdat = stdnonan(alldat);
    toohigh = dat > mdat+thresh(1)*sdat;
    toolow = dat < mdat - thresh(2)*sdat;
    toremove = any([toohigh toolow],2);
else
mdat = meannonan(dat);
sdat = stdnonan(dat);
toohigh = any(bsxfun(@gt,dat,mdat + thresh(1)*sdat),2);
toolow = any(bsxfun(@lt,dat,mdat - thresh(2)*sdat),2);
toremove = toohigh | toolow;
end
dat(toremove,:) = [];