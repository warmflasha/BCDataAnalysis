function plotSensitivitySpecifity(batteries,methodsToUse)
% This function plots histrograms by assessment.
% It is set up to make a 3x3 panel figure.
% It can compare up to two histograms on the same axes.
% It does the following processing steps: filtering, removing outliers, and normalization.


nItemsToCompare = length(batteries);
for ii = 1:length(methodsToUse)
    

    subplot(2,3,ii);
    for jj = 1:nItemsToCompare
        dat{jj} = makeDataFromMethodNames(batteries{jj},methodsToUse(ii));
        dat{jj} = removeOutliersFromData(dat{jj}); % remove outliers
        dat{jj}(isnan(dat{jj}) | dat{jj} == 0) =[];
    end
    
    dmin = min(cat(1,dat{:}));
    dmax = max(cat(1,dat{:}));
    dstep = (dmax-dmin)/20;
    allthresh = dmin:dstep:dmax;
    for jj = 1:numel(allthresh)
        
        thresh = allthresh(jj);
        if meannonan(dat{2}) > meannonan(dat{1})
            trueposfrac(jj) = sumnonan(dat{2} > thresh)/length(dat{2});
            truenegfrac(jj) = sumnonan(dat{1} < thresh)/length(dat{1});
        else
            trueposfrac(jj) = sumnonan(dat{2} < thresh)/length(dat{2});
            truenegfrac(jj) = sumnonan(dat{1} > thresh)/length(dat{1});
        end
    end

    plot(allthresh,trueposfrac,'b.-','MarkerSize',18,'LineWidth',3);
    hold on;
    plot(allthresh,truenegfrac,'r.-','MarkerSize',18,'LineWidth',3);
        title(strrep(methodsToUse{ii},'_',' '),'FontSize',24);
    xlabel('Threshold','FontSize',36);
    ylabel('Sensitivity or Specifity (%)','FontSize',24);
    set(gca,'FontSize',24);
    set(gca, 'box', 'off')
    xlim([dmin dmax]);
    set(gca,'YTick',0:0.25:1);
    
    if ii == 1
        legend({'Sensitivity','Specificity'},'FontSize',16);
    end
    

end