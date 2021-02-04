function [ i] = AllocationcPDELowerTTVS( undissoln, dissoln, parameters, muin, sigmain, p )
%AllocationcPDELowerTTVS
% PURPOSE: Implements the randomized allocation policy called TTVS-Lower in
% Chick, Gans, Yapar (2020). Returns the index of the 'best' arm based 
% on cPDELower with probability 1-p, and returns the index of the second 
% 'best' arm based on cPDELower with probability p.
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
% p: numerical scalar, probability of second best being selected
%
% OUTPUTS: 
% i: index of the arm to be sampled
%
% SUGGESTED WORKFLOW: See ExampleProblemSetup.m for an example of 
% generating the 'parameters' input, and ExamplePolicies.m for an 
% example of how to call this function

%%  
 evi = zeros(1,parameters.M); %preallocation for speed
 if parameters.delta == 1
     for j = 1:parameters.M
         evi(j)=cPDELowerUndis(undissoln, parameters, muin, sigmain, j);
     end
     % if the uniform distribution generates something below p, second
     % best, otherwise the best
     value = rand;
     if value <= p
        if all(evi<=0) %if stopping version wants to stop
            i = AllocationTieBreaker( parameters, 1:parameters.M,  muin, sigmain, parameters.pdetieoption);
        else
            [~,indmax] = max(evi);
            evi(indmax) = -Inf;
            [evimax2, i] = max(evi);
            idx = find(evi == evimax2);   
            if size(idx,2) > 1 %tied for a positive number, use regular tiebreaking
                i = AllocationTieBreaker( parameters, idx,  muin, sigmain, parameters.tieoption);
            end
        end
     else
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
 else
     warning('discounted version is not prepared');
 end
end
