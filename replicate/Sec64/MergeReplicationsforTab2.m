function [ toCopy ] = MergeReplicationsforTab2( policy, priorcode, numofreps, foldername)
%MergeReplicationsforTab2
% PURPOSE: SimforTab2 saves each simulation replication for a policy as a 
% .mat file. This function merges all replications into a single .mat file,
% and calculates the summary statistics. Works for the problem defined in
% Section 6.4 of correlated multiarm paper.
%
% INPUTS: 
% policy: string that contain the name of the policy used, eg. 'cKG1-cKGstar',
% priorcode: string, 'GPR','robust' or 'tilted'
% numofreps: number, number of replications run
% foldername: string, folder name to save the .mat file
% Examples for how to call are in MargeandGenerateTable2.m
%
% OUTPUTS: 1) Generates a .mat file that includes details of each simulation 
% replication, 2) returns a variable that contains the summary statistics 
% in the following order: 
% {'Allocation Rule','Stopping Rule','E[Sampling Cost]','Standard error',
% 'E[Opportunity Cost]','Standard error','E[Total Cost]','Standard error',
% 'Prob. of Correct Selection','Total Computation Time','E[T]','E[Reward]',
% 'Standard Error', 'EVPI', 'Prob of stopping at t=0', 'Prob of reaching 
% t=3000', 'Frac of low  early'};
%
% WORKFLOW: Called in MergeandGenerateTable2.m, after calling SimforTab2.m

%%
filename = strcat('mergedTC-Dose-',priorcode,'-',num2str(numofreps),'reps-', policy);
for i = 1:numofreps
    load(strcat(foldername,'dose-',priorcode,'-sampleeach-', policy,'-repnum-',num2str(i),'.mat'))
    if ~isfield(result.rule.detailed, 'alt')
        result.rule.detailed.alt = 0;
    end
    if ~isfield(result.rule.detailed, 'stoppedatbound')
        result.rule.detailed.stoppedatbound = result.rule.detailed.lastt >= 3000;
    end
    if ~isfield(result.rule.detailed, 'stoppedimm')
        result.rule.detailed.stoppedimm = result.rule.detailed.lastt == 0;
    end
    mergedTC.parameters = result.parameters;
    mergedTC.rule.detailed(i) = result.rule.detailed;
    mergedTC.rule.allrule = result.rule.allrule;
    mergedTC.rule.stoprule = result.rule.stoprule;
end
mergedTC.nofrules = 1;
mergedTC.nofreps = numofreps;
mymat = strcat(foldername,filename,'.mat'); 
save(mymat,'mergedTC'); 

%Add Summary Statistics
[ mergedTC ] = SimulationSummary( mergedTC );
mergedTC.rule.probstoppedimm = sum([mergedTC.rule.detailed.stoppedimm])/numofreps; 
mergedTC.rule.probstoppedatbound = sum([mergedTC.rule.detailed.stoppedatbound])/numofreps; 
fracoflowerbefore20 = zeros(1,numofreps);
for i = 1:numofreps
    if mergedTC.rule.detailed(i).lastt >= 20
        fracoflowerbefore20(i) = sum(mergedTC.rule.detailed(i).alt(1:20) <= 11)/20;
    elseif mergedTC.rule.detailed(i).lastt > 0
        lasttval = mergedTC.rule.detailed(i).lastt;
        fracoflowerbefore20(i) = sum(mergedTC.rule.detailed(i).alt(1:lasttval) <= 11)/lasttval;
    else
        fracoflowerbefore20(i) = NaN;
    end
end
mergedTC.rule.fracoflowerbefore20 = mean(fracoflowerbefore20 ,'omitnan');

%Summary statistics as a matrix
c1 = rmfield(mergedTC.rule,'detailed');
c = squeeze(struct2cell(c1));
toCopy = c';

end