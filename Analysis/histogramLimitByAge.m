function [ydat, xdat] = histogramLimitByAge(batteries,agelim,methodsToUse)
% This function plots line graphs w SEM, binning the data by age for each assessment.
% It is set up to make a 3x3 panel figure.
% It does the following processing steps: filtering, removing outliers, and normalization.

ages = [batteries.age];
filteredBatteries = batteries(ages >=agelim(1) & ages < agelim(2));


% Read inputs



for ii = 1:length(methodsToUse)
        dat = makeDataFromMethodNames(filteredBatteries,methodsToUse(ii));
        dat = removeOutliersFromData(dat); % Remove outliers
        subplot(2,3,ii);[ydat{ii}, xdat{ii}] =  hist(dat,8); %
        bar(xdat{ii},ydat{ii});
        title([strrep(methodsToUse(ii),'_',' ') '.   n=' int2str(length(dat)) '.']);
end
