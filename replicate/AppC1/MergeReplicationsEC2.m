function [ toCopy ] = MergeReplicationsEC2( policy, alpha, numofreps, foldername)
%MergeReplicationsEC2
% PURPOSE: SimforTabEC2 saves each simulation replication for a policy as a 
% .mat file. This function merges all replications into a single .mat file,
% and calculates the summary statistics. Works for the problem defined in
% Appendix C.1 of correlated multiarm paper, numerator of zeta value can be
% changed
%
% INPUTS: 
% policy: string that contain the name of the policy used, eg. 'cKG1-cKGstar',
% alpha: string, numerator of the zeta value used in the experiment,
% numofreps: number, number of replications run
% foldername: string, folder name to save the .mat file
% Examples for how to call are in MergeandGenerateTableEC2.m
%
% OUTPUTS: 1) Generates a .mat file that includes details of each simulation 
% replication, 2) returns a variable that contains the summary statistics 
% in the following order: 
% {'Allocation Rule','Stopping Rule','E[Sampling Cost]','Standard error',
% 'E[Opportunity Cost]','Standard error','E[Total Cost]','Standard error',
% 'Prob. of Correct Selection','Total Computation Time','E[T]','E[Reward]',
% 'Standard Error', 'EVPI'};
%
% WORKFLOW: Called in MergeandGenerateTableEC2.m, after calling SimforTabEC2.m

%%
filename = strcat('merged-80alt-',num2str(alpha),'-p4-1to',num2str(numofreps),'-', policy);
for i = 1:numofreps
    load(strcat(foldername,'80alt-TC-alpha',num2str(alpha),'-p4-', policy,'-repnum-',num2str(i),'.mat'))
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

%Summary statistics as a matrix
c1 = rmfield(mergedTC.rule,'detailed');
c = squeeze(struct2cell(c1));
toCopy = c';

end

