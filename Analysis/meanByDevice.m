function [mdat, edat, counter] = meanByDevice(batteries,methodsToUse)
% Take mean of data for all methods listed in methodsToUse. 
% For n methods returns an nx3 array with columns for phone, iPad, browser.



for jj = 0:2
filteredBatteries = batteries([batteries.deviceType] == jj);
for ii = 1:length(methodsToUse)
        dat = makeDataFromMethodNames(filteredBatteries,methodsToUse(ii));
        dat = removeOutliersFromData(dat); % Remove outliers
        mdat(ii,jj+1) = meannonan(dat);
        edat(ii,jj+1) = stdnonan(dat);
        counter(ii,jj+1) = length(dat);
end
end
