function [meandOCatgivenT, sedOCatgivenT] = CalculateandPlotCIofOC( result, NUMOFREPS, NUMOFREPSPDE, names, Tfixed, linS, atgivenT, doplot )
%CalculateandPlotCIofOC
% PURPOSE: Calculate the mean error of difference and standard error of the 
% difference at a given period between the opportunity cost of each
% policy simulated, and plot the mean difference and
% standard error of the difference between each policy pair. Used for 
% simulations that compare allocation policies
% when each is used with the same fixed stopping time.
%
% INPUTS: 
% result: struct array that contains OC at each period, see PlotFig1.m and
%   SimforFig1.m for examples of how to create result struct
% NUMOFREPS: numerical, number of replications for policies except cPDE
% NUMOFREPSPDE: numerical, number of replications for cPDE, can be
%   different than NUMOFREPS
% names: string vector, names of the allocation policies to be compared, 
%   in the same order as the result file, to be used in plots
% Tfixed: numerical, common fixed stopping time used in the simulations
% linS: string array, contains the line types to be used in the graphs if 
%   doplot == 1 
% atgivenT: numerical, calculate the statistics for which period 
% doplot: if 1, returns a set of graphs that plot the mean difference and
%   standard error of the difference between each policy pair
%
% OUTPUTS: 
% meandOCatgivenT: a matrix of mean difference among each allocation policy
%   pair, the order is the same as the order in results file except that
%   cPDE allocation policy is always at the end
% sedOCatgivenT: a matrix of standard error of differences among each 
%   allocation policy pair, the order is the same as the order in results 
%   file except that cPDE allocation policy is always at the end
%
% SUGGESTED WORKFLOW: Used after simulations that compare allocation
% policies are run, see PlotFig1.m and SimforFig1.m for examples  

%%
    NUMOFRULES = size(names,2);
    % Find the index of cPDE allocation rule, if it is available, and seperate
    % it since its number of replications can be different
    if sum(strcmp(vertcat(names), 'cPDE')) >= 1
        cPDEindex = find(strcmp(vertcat(names), 'cPDE'));
        resultcPDE.detailed = result.rule(cPDEindex).detailed;
        result.rule(cPDEindex) = [];
        NUMOFRULES = NUMOFRULES-1;
    end

    % Create a matrix of OC values at each period and at each replication
    OCmatrix = ones(NUMOFRULES,NUMOFREPS,Tfixed+1);
    for rep = 1:NUMOFREPS
        for rulenum=1:NUMOFRULES
            OCmatrix(rulenum,rep,:) = result.rule(rulenum).detailed(rep).OCeach;
        end
    end
    % Create a matrix of differences
    diffOCmatrix = zeros(NUMOFRULES,NUMOFRULES,NUMOFREPS,Tfixed-1);
    for stoppingt = 1:Tfixed+1
        trOCmatrix = OCmatrix(:,:,stoppingt)';
        for i=1:NUMOFREPS 
           diffOCmatrix(:,:,i,stoppingt) = bsxfun(@minus,OCmatrix(:,i,stoppingt),trOCmatrix(i,:));
        end
    end
    % Calculate the mean difference and standard error of differences
    meandOCeach = squeeze(mean(diffOCmatrix,3));
    stdevdOCeach = squeeze(std(diffOCmatrix,0,3));
    sedOCeach = squeeze(stdevdOCeach./sqrt(NUMOFREPS));
    
    % Plot the differences between each allocation policy pair
    if doplot == 1
        for j = 1:NUMOFRULES
            allrules = 1:NUMOFRULES;
            allrules(j)=[];
            figure('Name','Opportunity Cost');
            title(names(j));
            plotnumber = 1;
            for rulenum = allrules
                subplot(4,2,plotnumber)
                plotnumber = plotnumber + 1;
                hold on
                errorbar(squeeze(meandOCeach(j,rulenum,:)),squeeze(sedOCeach(j,rulenum,:)),linS{rulenum})
                refline(0,0)
                legend(names(rulenum));
                xlabel('Period');
                ylabel([names(j),'-',names(rulenum)]);
            end
            %set(gca, 'YScale', 'log')
        end
    end
    
    % Return the statistics at the period given as input
    meandOCatgivenT = meandOCeach(:,:, atgivenT);
    sedOCatgivenT = sedOCeach(:,:, atgivenT);
    
    % if cPDE is available, add the statistics and plots for cPDE to the end
    if sum(strcmp(vertcat(names), 'cPDE')) >= 1
        OCmatrix = OCmatrix(:,1:NUMOFREPSPDE,:);
        for rep = 1:NUMOFREPSPDE
            OCmatrix(NUMOFRULES+1,rep,:) = resultcPDE.detailed(rep).OCeach;
        end
        diffOCmatrix = zeros(NUMOFRULES+1,NUMOFRULES+1,NUMOFREPSPDE,Tfixed-1);
        for stoppingt = 1:Tfixed+1
            trOCmatrix = OCmatrix(:,:,stoppingt)';
            for i=1:NUMOFREPSPDE 
               diffOCmatrix(:,:,i,stoppingt) = bsxfun(@minus,OCmatrix(:,i,stoppingt),trOCmatrix(i,:));
            end
        end
        meandOCeach = squeeze(mean(diffOCmatrix,3));
        stdevdOCeach = squeeze(std(diffOCmatrix,0,3));
        sedOCeach = squeeze(stdevdOCeach./sqrt(NUMOFREPSPDE));

        if doplot == 1
            allrules = 1:NUMOFRULES;
            figure('Name','Opportunity Cost');
            title('cPDE');
            plotnumber = 1;
            for rulenum = allrules
                subplot(4,2,plotnumber)
                plotnumber = plotnumber + 1;
                hold on
                errorbar(squeeze(meandOCeach(j,rulenum,:)),squeeze(sedOCeach(j,rulenum,:)),linS{rulenum})
                refline(0,0)
                legend(names(rulenum));
                xlabel('Period');
                ylabel([names(j),'-',names(rulenum)]);
            end
            %set(gca, 'YScale', 'log')
        end

        meandOCatgivenT(NUMOFRULES+1, :) = meandOCeach(NUMOFRULES+1,1:NUMOFRULES, atgivenT);
        sedOCatgivenT(NUMOFRULES+1, :) = sedOCeach(NUMOFRULES+1,1:NUMOFRULES, atgivenT);
        meandOCatgivenT(:, NUMOFRULES+1) = [meandOCeach(1:NUMOFRULES, NUMOFRULES+1, atgivenT); 0];
        sedOCatgivenT(:, NUMOFRULES+1) = [sedOCeach(1:NUMOFRULES, NUMOFRULES+1, atgivenT); 0];
    end

end

