function GenerateOCFig(result, foldername, filename, includese)
%GenerateOCFig
% PURPOSE: Plots the log(E[OC]) for each allocation policy and saves the 
% plots as .fig and .eps files if asked. Used for 
% simulations that compare allocation policies
% when each is used with the same fixed stopping time.
%
% INPUTS: 
% result: struct array that contains OC at each period
% foldername: string, directory to be saved, -1 if it will not be saved
% filename: string, the name of the figure file if it will be saved
% includese: if 1, the plot includes the +/-1 standard error bars for each
%   allocation policy at each period
% OUTPUTS: Generates a plot and saves it as figurename.fig and 
% figurename.eps if specified.
%
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
        PDEUtilStdizeFigure(f,0.9,20,true); % SEC: Normalize the size of the plot
%        set(gca,'FontSize',36)
%        set(gca,'fontname','times')
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
        PDEUtilStdizeFigure(f,0.9,20,true); % SEC: Normalize the size of the plot
%        set(gca,'FontSize',36)
%        set(gca,'fontname','times')
    end
    if foldername ~= -1
        %Save the figure
        CheckandCreateDir( foldername )
        savefig(f, strcat(foldername, filename, '.fig'));
        saveas(f, strcat(foldername, filename), 'epsc')
    end
end

