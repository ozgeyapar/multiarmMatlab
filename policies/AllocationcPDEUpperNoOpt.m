function [ i ] = AllocationcPDEUpperNoOpt( undissoln, dissoln, parameters, muin, sigmain )
%AllocationcPDEUpperNoOpt
% PURPOSE: Implements the allocation policy cPDEUpper defined in Chick, Gans,
% Yapar (2020) with equal weights. Returns the index of the arm to be 
% sampled from at the next period.
%
% INPUTS:
% undissol: variable which contains the standardized solution
%   for undiscounted problem. SetSolFiles.m generates the standardized
%   solution and PDELoadSolnFiles is used to load it, see 
%   ExamplePolicies.m for an example.
% dissoln: variable which contains the standardized solution
%   for discounted problem. SetSolFiles.m generates the standardized
%   solution and PDELoadSolnFiles is used to load it.
% parameters: struct, problem parameters are included as fields (See 
%   ExampleProblemSetup.m for an example of how to generate this struct)
% muin: numerical vector that contains the prior mean vector
% sigmain: numerical matrix that contains the prior covariance matrix
%
% OUTPUTS: 
% i: index of the arm to be sampled
%
% SUGGESTED WORKFLOW: See ExampleProblemSetup.m for an example of 
% generating the 'parameters' input, and ExampleCallingcPDEs.m for an 
% example of how to call this function

%%
evi = zeros(1,parameters.M); %preallocation for speed
for j = 1:parameters.M
    if parameters.delta == 1
        evi(j)=cPDEUpperUndisNoOpt(undissoln, parameters, muin, sigmain, j);
    elseif parameters.delta < 1 && parameters.delta > 0
        evi(j)=cPDEUpperDis(dissoln, parameters, muin, sigmain, j );
    else
        warning('cannot calculate undiscounted upper bound: discounting rate delta has to be between 0 and 1');
        return;
    end
end
    if all(evi<=0) %if stopping version wants to stop
        i = AllocationTieBreaker( parameters, 1:parameters.M,  muin, sigmain, parameters.pdetieoption);
    else
        [evimax,i] = max(evi);
        idx = find(evi == evimax);   
        if size(idx,2) > 1 %tied for a positive number, use regular tiebreaking
            i = AllocationTieBreaker( parameters, idx,  muin, sigmain, parameters.tieoption);
        end
    end
end
