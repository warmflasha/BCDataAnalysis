function compareMeansTwoDatasets(batteries1,batteries2,methodsToUse,labels,subfig,basefigname)

nmethods = length(methodsToUse);
xx = (1:10).*(2:11);

if subfig
    nplot = find(xx > nmethods,1,'first');
end

for ii = 1:nmethods
    [m1, e1] = meanAndStdOfDataFromMethodName(batteries1,methodsToUse(ii));
    [m2, e2] = meanAndStdOfDataFromMethodName(batteries2,methodsToUse(ii));
    if subfig
        subplot(nplot,nplot+1,ii);
    else
        figure;
    end
    
    bar([m1, m2]); hold on; 
    errorbar(1:2,[m1, m2],[e1, e2],'k.','LineWidth',2.5); hold off;
    if exist('labels','var')
        set(gca,'XtickLabel',labels);
        set(gca,'XtickLabelRotation',45);
    end
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


function [m1, e1] = meanAndStdOfDataFromMethodName(batteries,methname)
dat1 = makeDataFromMethodNames(batteries,methname);
dat1(isnan(dat1) | dat1==0) =[];
dat1 = removeOutliersFromData(dat1);
m1 = mean(dat1);
e1 = std(dat1)/sqrt(length(dat1));