function GeneratePowerCurve(results, foldername, filename)
%GeneratePowerCurve
% PURPOSE: Plots a power curve for given deltas (difference between the
% mean of best arm and the second best arm) and policies.
%
% INPUTS: 
% results: struct that contains the simulation results
% foldername: string, directory to be saved, -1 if it will not be saved
% filename: string, the name of the figure file if it will be saved
%
% OUTPUTS: Generates a plot and saves it as figurename.fig and 
% figurename.eps if specified.
%
%%  
    % Initilization
    deltas = [results.deltaval];
    allnames = {results(1).simresults.policy.allrule};
    stopnames = {results(1).simresults.policy.stoprule};
    NUMOFDELTAS = size(results,2);
    NUMOFPOLS =  size(allnames,2);
    NUMOFREPS  = results(1).simresults.nofreps;
    %markers to be used in the figure
    marker = {'-o','-+','-x','--*','--s','--d'};
    
    % Generate the figure
    f = figure('Name','PowerCurve');
    hold on
    for i = 1:NUMOFPOLS
        yvalues = zeros(1,NUMOFDELTAS);
        for j = 1:NUMOFDELTAS
            yvalues(j) = sum([results(j).simresults.policy(i).detailed.CS])/NUMOFREPS;
        end
        plot(deltas,yvalues,marker{i},'MarkerSize',10,'LineWidth',2)
    end
    set(gca,'xlim',[min(deltas) max(deltas)]);
    set(gca,'XTick', deltas);
    set(gca,'ylim',[0 1]);
    xlabel('Difference to Detect');
    ylabel('Power: P(CS)');
    names = strcat(allnames(1:NUMOFPOLS),'-',stopnames(1:NUMOFPOLS));
    legend(names);
    set(gca,'fontname','times')
    set(gca,'FontSize',24)
    
    if foldername ~= -1
        %Save the figure
        CheckandCreateDir( foldername )
        savefig(f, strcat(foldername, filename, '.fig'));
        saveas(f, strcat(foldername, filename), 'epsc')
    end
    

end

