function plotTestRetest(outTest,trial1,trial2,methodsToUse,subfig,basefigname)

firstTrial = cellfun(@(x) x(trial1), outTest,'UniformOutput',false);
firstTrial = [firstTrial{:}];
secondTrial = cellfun(@(x) x(trial2), outTest,'UniformOutput',false);
secondTrial = [secondTrial{:}];

nmethods = length(methodsToUse);
xx = (1:10).*(2:11);
if subfig
    nplot = find(xx > nmethods,1,'first');
end


for ii = 1:nmethods
    dat1 = makeDataFromMethodNames(firstTrial,methodsToUse(ii));
    dat2 = makeDataFromMethodNames(secondTrial,methodsToUse(ii));
    dat = [dat1, dat2];
    dat = removeOutliersFromDataMatrix(dat,3);
    dat = removeOutliersFromDataMatrix(dat,3);
    
    if subfig
        subplot(nplot,nplot+1,ii);
    else
        figure;
    end
    plot(dat(:,1),dat(:,2),'r.','MarkerSize',16);
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


end
