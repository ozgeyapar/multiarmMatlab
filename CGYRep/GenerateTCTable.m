function [ toCopy ] = GenerateTCTable( result, foldername, filename )
%GenerateTCTable
% PURPOSE: Generates a table that contains the statistical summary of
% simulation results for each policy. 
%
% INPUTS: 
% result: struct array that contains OC at each period
% foldername: string, directory to be saved, -1 if it will not be saved
% filename: string, the name of the figure file if it will be saved
%
% OUTPUTS: Returns a variable that contains the summary statistics 
% in the following order: 
% {'Allocation','Stopping','E[T]', 'S.E', 'E[SC]','S.E','E[OC]','S.E','E[TC]'
% ,'S.E','P(CS)','CPU'}, saves the table as a .mat file if specified.


%%
    NUMOFPPOL = result.nofpols;
    NUMOFREPS  = result.nofreps;
    
    for j = 1:NUMOFPPOL %For each rule pair
        % Expectation and standard error of the mean
        result.policy(j).explastt = mean([result.policy(j).detailed.lastt]); %average length before stopping
        result.policy(j).selastt = mean([result.policy(j).detailed.lastt]); %average length before stopping
        result.policy(j).expsamcost = mean([result.policy(j).detailed.SClast]); %Sampling cost
        result.policy(j).seSC = std([result.policy(j).detailed.SClast])/sqrt(NUMOFREPS);
        result.policy(j).expOC = mean([result.policy(j).detailed.OClast]); %Opportunity cost
        result.policy(j).seOC = std([result.policy(j).detailed.OClast])/sqrt(NUMOFREPS);
        result.policy(j).exptotalcost = mean([result.policy(j).detailed.TClast]); %Sum of sampling and opportunity cost
        result.policy(j).vartotalcost = std([result.policy(j).detailed.TClast])/sqrt(NUMOFREPS);
        result.policy(j).PCS = sum([result.policy(j).detailed.CS])/NUMOFREPS; %probability of correct selection 
        result.policy(j).totalcomptime = sum([result.policy(j).detailed.comptime]); %total time required for computation
    end

    %Summary statistics as a matrix
    cnames = {'Allocation','Stopping','E[T]', 'S.E', 'E[SC]','S.E','E[OC]','S.E','E[TC]','S.E','P(CS)','CPU'};
    c1 = rmfield(result.policy,'detailed');
    c = squeeze(struct2cell(c1));
    toCopy = [cnames;c'];

    % Save if needed
    if foldername ~= -1
        %Save the figure
        CheckandCreateDir( foldername )
        save(strcat(foldertosave, filename, '-table'), 'toCopy')
    end

end

