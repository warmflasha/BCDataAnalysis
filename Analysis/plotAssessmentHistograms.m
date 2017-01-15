function plotAssessmentHistograms(batteries,methodsToUse,subfig,basefigname)
%Makes plots of distribution of all scores for methods to use from the data
%in batteries.

nmethods = length(methodsToUse);
xx = (1:10).*(2:11);

if subfig
    nplot = find(xx > nmethods,1,'first');
end

nbin = max(min(ceil(length(batteries)/20),15),5);

for ii = 1:nmethods
    dat = makeDataFromMethodNames(batteries,methodsToUse(ii));
    dat(isnan(dat) | dat==0) =[];
    dat = removeOutliersFromData(dat);
    if subfig
        subplot(nplot,nplot+1,ii);
    else
        figure;
    end
    hist(dat,nbin);
    if subfig
        title(strrep(methodsToUse{ii},'_',' '));
    end
    if ~subfig && exist('basefigname','var')
        saveas(gcf,[basefigname '_' methodsToUse{ii} '.jpg']);
    end
    
end

if exist('basefigname','var') && subfig
    maximize(gcf);
    saveas(gcf,[basefigname '.jpg']);
end


