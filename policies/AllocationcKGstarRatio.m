function [ i ] = AllocationcKGstarRatio(  parameters, muin, sigmain )
%AllocationcKGstarRatio
% PURPOSE: Implements the allocation policy cKGstar defined in Chick, Gans,
% Yapar (2020), KG value is calculated as the ratio of benefit 
% to cost. Returns the index of the arm to be sampled from at the next 
% period.
%
% INPUTS: 
% parameters: struct, problem parameters are included as fields (See 
%   ExampleProblemSetup.m for an example of how to generate this struct)
% muin: numerical vector that contains the prior mean vector
% sigmain: numerical matrix that contains the prior covariance matrix
%
% OUTPUTS: 
% i: index of the arm to be sampled
%
% SUGGESTED WORKFLOW: See ExampleProblemSetup.m for an example of 
% generating the 'parameters' input

%%  
    kg = zeros(1,parameters.M); %preallocation for speed
    for j = 1:parameters.M
        %Estimate the EVI of each arm using cKGstar method
        if parameters.delta == 1
            [ ~, kg(j)] = cKGstarUndisRatio( parameters, muin, sigmain, j );
        elseif parameters.delta < 1 && parameters.delta > 0
            kg(j) = cKGstarDisRatio( parameters, muin, sigmain, j );
        else
            warning('cannot calculate undiscounted upper bound: discounting rate delta has to be between 0 and 1');
            return;
        end
    end
    [kgi,i] = max(kg);
    %tie breaker
    idx = find(kg == kgi);
    if size(idx,2) > 1
        i = AllocationTieBreaker( parameters, idx, muin, sigmain, parameters.tieoption);
    end
end
