function [ i ] = AllocationcKG1Ratio(parameters, muin, sigmain, randtype, randprob )
%AllocationcKG1Ratio
% PURPOSE: Implements the allocation policy that is based on correlated KG1 
% from Frazier, Powell, Dayanik (2009), KG value is calculated as the ratio
% of benefit to cost. Returns the index of the arm to be sampled from at 
% the next period.
%
% INPUTS: 
% parameters: struct, problem parameters are included as fields (See 
%   ExampleProblemSetup.m for an example of how to generate this struct)
% muin: numerical vector that contains the prior mean vector
% sigmain: numerical matrix that contains the prior covariance matrix
% randtype: randomization type, 1 for uniform, 2 for TTVS
% randprob: randomization probability
%
% OUTPUTS: 
% i: index of the arm to be sampled
%
% SUGGESTED WORKFLOW: See ExampleProblemSetup.m for an example of 
% generating the 'parameters' input

%%
    % if the uniform distribution generates something below randprob, randomize
    value = rand;
    if value <= randprob && randtype == 1 %%Uniform
        [ i ] = unidrnd(parameters.M);
    elseif value <= randprob && randtype == 2 % TTVS
        kg = zeros(1,parameters.M); %preallocation for speed
        %Estimate the EVI of each arm using cKG method
        for j = 1:parameters.M
            if parameters.delta == 1
                kg(j) = cKG1UndisRatio( parameters,muin, sigmain, j );
            elseif parameters.delta < 1 && parameters.delta > 0
                kg(j) = cKG1DisRatio( parameters,muin, sigmain, j );
            else
                warning('cannot calculate undiscounted upper bound: discounting rate delta has to be between 0 and 1');
                return;
            end
        end
        [~,indmax] = max(kg);
        kg(indmax) = -Inf;
        [kgmax2, i] = max(kg);
        idx = find(kg == kgmax2);   
        if size(idx,2) > 1 %use regular tiebreaking
            i = AllocationTieBreaker( parameters, idx,  muin, sigmain, parameters.tieoption);
        end
    else
        kg = zeros(1,parameters.M); %preallocation for speed
        %Estimate the EVI of each arm using cKG method
        for j = 1:parameters.M
            if parameters.delta == 1
                kg(j) = cKG1UndisRatio( parameters,muin, sigmain, j );
            elseif parameters.delta < 1 && parameters.delta > 0
                kg(j) = cKG1DisRatio( parameters,muin, sigmain, j );
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

end
