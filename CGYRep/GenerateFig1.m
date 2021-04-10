function GenerateFig1(result, figurename, includese)
%GENERATEFIG1 Summary of this function goes here
%   Detailed explanation goes here
%%
    NUMOFPPOL = result.nofpols;
    NUMOFREPS  = result.nofreps;
    Tfixed = size(result.policy(1).detailed(1).SCeach,2) - 1;
    names = {result.policy.allrule};
    linS = {'-+r','--k','-xm','-og','-sr','-dm','-^g','->k','-.b'};
    % include standard error bars, and there is cPDE allocation policy
    if (includese == 1)
        f = figure;
        hold on
        for j = 1:NUMOFPPOL %for all policies
            meanOCeach = mean(reshape([result.policy(j).detailed.OCeach],[Tfixed+1,NUMOFREPS])',1);
            SEOCeach = std(reshape([result.policy(j).detailed.OCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
            meanOCupper = meanOCeach + SEOCeach;
            logmeanOCeach = log10(meanOCeach);
            logmeanOCupper = log10(meanOCupper);
            errorbar(logmeanOCeach,logmeanOCupper-logmeanOCeach,linS{j},'LineWidth',2, 'MarkerSize',10) 
        end
        %set(gca, 'YScale', 'log');
        set(gca,'xlim',[0 Tfixed+1]);
        xlabel('Sample size');
        ylabel('log_{10}(E[OC])');
        legend(names);
        set(gca,'FontSize',36)
        set(gca,'fontname','times')
    else % don't include standard error bars
        f = figure;
        hold on
        for j = 1:NUMOFPPOL
            meanOCeach = mean(reshape([result.policy(j).detailed.OCeach],[Tfixed+1,NUMOFREPS])',1);
            logmeanOCeach = log10(meanOCeach);
            plot(logmeanOCeach,linS{j},'LineWidth',2,'MarkerSize',10) 
        end 
        %set(gca, 'YScale', 'log');
        set(gca,'xlim',[0 Tfixed+1]);
        xlabel('Sample size');
        ylabel('log_{10}(E[OC])');
        legend(names);
        set(gca,'FontSize',36)
        set(gca,'fontname','times')
    end

    %Save the figure
    savefig(f, strcat(figurename, '.fig'));
    saveas(f, figurename, 'epsc')
end

