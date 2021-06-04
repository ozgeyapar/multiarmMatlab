function GenerateOCTCSCFig(result, foldername, filename)
%GenerateOCTCSCFig
% PURPOSE: Plots the E[OC], E[SC] and E[TC] for the first policy in the
% result input
%
% INPUTS: 
% result: struct array that contains the simulation results
% foldername: string, directory to be saved, -1 if it will not be saved
% filename: string, the name of the figure file if it will be saved
%
% OUTPUTS: Generates a plot and saves it as figurename.fig and 
% figurename.eps if specified.
%
%%
    NUMOFREPS  = result.nofreps;
    Tfixed = size(result.policy(1).detailed(1).SCeach,2) - 1;
    % If Tfixed is too large, do not plot all points
    if Tfixed > 1000
        Tstoplot = [1,100:100:Tfixed];
    else
        Tstoplot = [1,10:10:Tfixed];
    end
    f = figure;
    hold on

    meanOCeach = mean(reshape([result.policy(1).detailed.OCeach],[Tfixed+1,NUMOFREPS])',1);
    SEOCeach = std(reshape([result.policy(1).detailed.OCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
    meanOCupper = meanOCeach + SEOCeach;
    logmeanOCeach = log10(meanOCeach);
    logmeanOCupper = log10(meanOCupper);
    %plot(logmeanOCeach,'--r','LineWidth',2, 'MarkerSize',10)
    errorbar(Tstoplot,logmeanOCeach(Tstoplot),logmeanOCupper(Tstoplot)-logmeanOCeach(Tstoplot),'--r','LineWidth',2, 'MarkerSize',10)

    meanTCeach = mean(reshape([result.policy(1).detailed.TCeach],[Tfixed+1,NUMOFREPS])',1);
    SETCeach = std(reshape([result.policy(1).detailed.TCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
    meanTCupper = meanTCeach + SETCeach;
    logmeanTCeach = log10(meanTCeach);
    logmeanTCupper = log10(meanTCupper);
    %plot(logmeanTCeach,'-k','LineWidth',2, 'MarkerSize',10)
    errorbar(Tstoplot,logmeanTCeach(Tstoplot),logmeanTCupper(Tstoplot)-logmeanTCeach(Tstoplot),'-k','LineWidth',2, 'MarkerSize',10)

    meanSCeach = mean(reshape([result.policy(1).detailed.SCeach],[Tfixed+1,NUMOFREPS])',1);
    SESCeach = std(reshape([result.policy(1).detailed.SCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
    meanSCupper = meanSCeach + SESCeach;
    logmeanSCeach = log10(meanSCeach);
    logmeanSCupper = log10(meanSCupper);
    plot(Tstoplot,logmeanSCeach(Tstoplot),'-.b','LineWidth',2, 'MarkerSize',10)
    
    %errorbar(Tstoplot,logmeanSCeach(Tstoplot),logmeanSCupper(Tstoplot)-logmeanSCeach(Tstoplot),'-.b','LineWidth',2, 'MarkerSize',10)

    %set(gca, 'YScale', 'log');
    hold off;
    set(gca,'xlim',[0 Tfixed]);
    xlabel('Sample size');
    ylabel('log_{10}($)');
    legend('E[OC]','E[TC]','E[SC]');
    set(gca,'FontSize',36)
    set(gca,'fontname','times')
    PDEUtilStdizeFigure(f,0.9,20,true); % SEC: Normalize the size of the plot
    
    if foldername ~= -1
        %Save the figure
        CheckandCreateDir( foldername )
        savefig(f, strcat(foldername, filename, '.fig'));
        saveas(f, strcat(foldername, filename), 'epsc')
    end
end

