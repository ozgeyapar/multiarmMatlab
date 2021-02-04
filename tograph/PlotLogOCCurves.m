function PlotLogOCCurves( result, names, includese, NUMOFREPS, NUMOFREPScPDE, Tfixed, linS, figurename)
%PlotLogOCCurves
% PURPOSE: Plots the log(E[OC]) for each allocation policy and saves the 
% plots as .fig and .eps files. Used for 
% simulations that compare allocation policies
% when each is used with the same fixed stopping time.
%
% INPUTS: 
% result: struct array that contains OC at each period, see PlotFig1.m and
%   SimforFig1.m for examples of how to create result struct
% names: string vector, names of the allocation policies to be compared, 
%   in the same order as the result file, to be used in plots
% includese: if 1, the plot includes the +/-1 standard error bars for each
%   allocation policy at each period
% NUMOFREPS: numerical, number of replications for policies except cPDE
% NUMOFREPScPDE: numerical, number of replications for cPDE, can be
%   different than NUMOFREPS
% Tfixed: numerical, common fixed stopping time used in the simulations
% linS: string array, contains the line types to be used in the graphs if 
%   doplot == 1 
% figurename: string, directory and the name of the figure file
%
% OUTPUTS: Generates a plot and saves it as figurename.fig and 
% figurename.eps.
%
% SUGGESTED WORKFLOW: Used after simulations that compare allocation
% policies are run, see PlotFig1.m and SimforFig1.m for examples  

%%
    NUMOFRULES = size(names,2);
    
    % include standard error bars, and there is cPDE allocation policy
    if includese == 1 && any(strcmp(names, 'cPDE'))
        %find the index of cPDE since its number of replications can be
        %different
        cPDEindex = find(strcmp(vertcat(names), 'cPDE'));
        f = figure('Name','log(Opportunity Cost)');
        hold on
        for j = 1:NUMOFRULES %for all policies
            if j == cPDEindex %if cPDE, use the number of replications for cPDE
                meanOCeach = mean(reshape([result.rule(j).detailed.OCeach],[Tfixed+1,NUMOFREPScPDE])',1);
                SEOCeach = std(reshape([result.rule(j).detailed.OCeach],[Tfixed+1,NUMOFREPScPDE])',0,1)./sqrt(NUMOFREPScPDE);
                meanOCupper = meanOCeach + SEOCeach;
                logmeanOCeach = log10(meanOCeach);
                logmeanOCupper = log10(meanOCupper);
                errorbar(logmeanOCeach,logmeanOCupper-logmeanOCeach,linS{j},'LineWidth',2, 'MarkerSize',10)
            else %if not cPDE, use the regular number of replications
                meanOCeach = mean(reshape([result.rule(j).detailed.OCeach],[Tfixed+1,NUMOFREPS])',1);
                SEOCeach = std(reshape([result.rule(j).detailed.OCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
                meanOCupper = meanOCeach + SEOCeach;
                logmeanOCeach = log10(meanOCeach);
                logmeanOCupper = log10(meanOCupper);
                errorbar(logmeanOCeach,logmeanOCupper-logmeanOCeach,linS{j},'LineWidth',2, 'MarkerSize',10) 
            end
        end
        %set(gca, 'YScale', 'log');
        set(gca,'xlim',[0 Tfixed+1]);
        xlabel('Sample size');
        ylabel('log_{10}(E[OC])');
        legend(names);
        set(gca,'FontSize',36)
        set(gca,'fontname','times')
    % don't include standard error bars, and there is cPDE allocation policy
    elseif includese == 0 &&  any(strcmp(names, 'cPDE'))
        %find the index of cPDE since its number of replications can be
        %different
        cPDEindex = find(strcmp(vertcat(names), 'cPDE'));
        f = figure('Name','log(Opportunity Cost)');
        hold on
        for j = 1:NUMOFRULES
            if j == cPDEindex %if cPDE, use the number of replications for cPDE
                meanOCeach = mean(reshape([result.rule(j).detailed.OCeach],[Tfixed+1,NUMOFREPScPDE])',1);
                logmeanOCeach = log10(meanOCeach);
                plot(logmeanOCeach,linS{j},'LineWidth',2)
            else %if not cPDE, use the regular number of replications
                meanOCeach = mean(reshape([result.rule(j).detailed.OCeach],[Tfixed+1,NUMOFREPS])',1);
                logmeanOCeach = log10(meanOCeach);
                plot(logmeanOCeach,linS{j},'LineWidth',2,'MarkerSize',10) 
            end
        end 
        %set(gca, 'YScale', 'log');
        set(gca,'xlim',[0 Tfixed+1]);
        xlabel('Sample size');
        ylabel('log_{10}(E[OC])');
        legend(names);
        set(gca,'FontSize',36)
        set(gca,'fontname','times')
    % include standard error bars, and there is not a cPDE allocation policy
    elseif includese == 1
        f = figure('Name','log(Opportunity Cost)');
        hold on
        for j = 1:NUMOFRULES
            X = reshape([result.rule(j).detailed.OCeach],[Tfixed+1,NUMOFREPS])';
            meanOCeach = mean(X,1);
            SEOCeach = std(X,0,1)./sqrt(NUMOFREPS);
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
    % don't include standard error bars, and there is not a cPDE allocation policy
    else
        % figure log
        f = figure('Name','log(E(Opportunity Cost))');
        hold on
        for j = 1:NUMOFRULES
            meanOCeach = mean(reshape([result.rule(j).detailed.OCeach],[Tfixed+1,NUMOFREPS])',1);
%             if includese == 1
%                seOCeach = std(reshape([result.rule(j).detailed.OCeach],[Tfixed+1,NUMOFREPS])',1)/sqrt(NUMOFREPS);
%                logseOCeach = log10(seOCeach);
%             end
            logmeanOCeach = log10(meanOCeach);
            plot(logmeanOCeach,linS{j},'LineWidth',2, 'MarkerSize',10)
            %errorbar(logmeanOCeach,logseOCeach, linS{j}, 'LineWidth',1)
        end
        set(gca,'xlim',[0 Tfixed+1]);
        xlabel('Sample size');
        ylabel('log_{10}(E[OC])');
        legend(names);
        set(gca,'fontname','times')
        set(gca,'FontSize',36)
    end

    %Save the figure
    savefig(f, strcat(figurename, '.fig'));
    saveas(f, figurename, 'epsc')

end

