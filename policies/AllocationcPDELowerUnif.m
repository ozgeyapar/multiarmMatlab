function [ i] = AllocationcPDELowerUnif( undissoln, dissoln, parameters, muin, sigmain, p )
%AllocationcPDELowerUnif
% PURPOSE: Implements the randomized allocation policy which returns the 
% index of the 'best' arm based on cPDELower with probability 1-p, and 
% randomly returns an index using uniform distribution with probability p. 
% Policy is defined in Chick, Gans, Yapar (2020).
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
% generating the 'parameters' input, and ExamplePolicies.m for an 
% example of how to call this function

%%    
    value = rand;
    if value <= p
        [ i ] = unidrnd(parameters.M);
    else
        evi = zeros(1,parameters.M); %preallocation for speed
        for j = 1:parameters.M
            if parameters.delta == 1
                evi(j)=cPDELowerUndis(undissoln, parameters, muin, sigmain, j);
            elseif parameters.delta < 1 && parameters.delta > 0
                evi(j)=cPDELowerDis(dissoln, parameters, muin, sigmain, j );
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
end
