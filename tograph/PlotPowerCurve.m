function PlotPowerCurve(result, names, deltas, foldername, figname )
%PlotPowerCurve
% PURPOSE: Plots the probability of correct selection (P(CS)) against the 
% difference between the means of best and second best arms for each policy
% and saves the plot as .fig and .eps files.
%
% INPUTS: 
% result: struct array that contains P(CS) at each period, see PlotFigEC5.m 
%   and SimforAppD1.m for examples of how to create result struct
% names: string vector, names of the policies to be compared, 
%   in the same order as the result file, to be used in plots
% deltas: numerical vector, holds the range of differences between the best
% and second best arms' means to be plotted 
% NUMOFREPS: numerical, number of replications for policies except cPDE
% NUMOFREPScPDE: numerical, number of replications for cPDE, can be
%   different than NUMOFREPS
% foldername: string, directory to be saved for the figure file
% figname: string, name for the figure file
%
% OUTPUTS: Generates a plot and saves it as figurename.fig and 
% figurename.eps.
%
% SUGGESTED WORKFLOW: Used after simulations that compare P(CS) for a range
% of differences between the best and second best arms' means,
% see PlotFigEC5.m and SimforAppD1.m for examples

%%
    NUMOFDELTAS = size(deltas,2);
    NUMOFRULES = size(names,2);
    %merkers to be used in the figure
    marker = {'-o','-+','-x','--*','--s','--d'};
    
    f = figure('Name','PowerCurve');
    hold on
    for i = 1:NUMOFRULES
        yvalues = zeros(1,NUMOFDELTAS);
        for j = 1:NUMOFDELTAS
            yvalues(j) = result.deltarule((i-1)*NUMOFDELTAS+j).PCS;
        end
        plot(deltas,yvalues,marker{i},'MarkerSize',10,'LineWidth',2)
    end
    set(gca,'xlim',[min(deltas) max(deltas)]);
    set(gca,'XTick', deltas);
    set(gca,'ylim',[0 1]);
    xlabel('Difference to Detect');
    ylabel('Power: P(CS)');
    legend(names);
    set(gca,'fontname','times')
    set(gca,'FontSize',24)
    
    %Save figure
    myfigure = strcat(foldername,figname);
    savefig(f, strcat(myfigure, '.fig'));
    saveas(f, myfigure, 'epsc');
end

