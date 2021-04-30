function [ i] = AllocationIndESPcapB( undissol, parameters, mu, sigma, randtype, randprob )
%AllocationIndESPcapB
% PURPOSE: Implements the allocation policy that is based on ESP_B
% from Chick and Frazier (2012), which is designed for independent
% arms. Returns the index of the arm to be sampled from at the next period.
%
% INPUTS: 
% undissol: variable which contains the standardized solution
%   for undiscounted problem. SetSolFiles.m generates the standardized
%   solution and PDELoadSolnFiles is used to load it, see 
%   ExamplePolicies.m for an example.
% parameters: struct, problem parameters are included as fields (See 
%   ExampleProblemSetup.m for an example of how to generate this struct)
% mu: numerical vector that contains the prior mean vector
% sigma: numerical matrix that contains the prior covariance matrix
% randtype: randomization type, 1 for uniform, 2 for TTVS
% randprob: randomization probability
%
% OUTPUTS: 
% i: index of the arm to be sampled
%
% SUGGESTED WORKFLOW: See ExampleProblemSetup.m for an example of 
% generating the 'parameters' input, and ExamplePolicies.m for an example
% of how to call this function

%%
    if parameters.delta == 1
        % if the uniform distribution generates something below randprob, randomize
        value = rand;
        if value <= randprob && randtype == 1 %%Uniform
            [ i ] = unidrnd(parameters.M);
        elseif value <= randprob && randtype == 2 % TTVS
            evi = zeros(1,parameters.M);
            for i = 1:parameters.M
                beta = (parameters.c(i)/parameters.P)^(-1/3) .* parameters.lambdav(i)^(-1/3);
                gamma = (parameters.c(i)/parameters.P)^(2/3) .* parameters.lambdav(i)^(-1/3);
                efnsi = parameters.lambdav(i)/sigma(i,i);
                [maxofothers,ind] = max([mu(1:i-1);mu(i+1:length(mu))]);
                temp = PDEGetVals(undissol,-beta*(abs(mu(i)-parameters.I(i)/parameters.P-maxofothers+parameters.I(ind)/parameters.P)),(gamma*efnsi)^(-1));
                evi(i) = temp/beta;
            end
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
            evi = zeros(1,parameters.M);
            for i = 1:parameters.M
                beta = (parameters.c(i)/parameters.P)^(-1/3) .* parameters.lambdav(i)^(-1/3);
                gamma = (parameters.c(i)/parameters.P)^(2/3) .* parameters.lambdav(i)^(-1/3);
                efnsi = parameters.lambdav(i)/sigma(i,i);
                [maxofothers,ind] = max([mu(1:i-1);mu(i+1:length(mu))]);
                temp = PDEGetVals(undissol,-beta*(abs(mu(i)-parameters.I(i)/parameters.P-maxofothers+parameters.I(ind)/parameters.P)),(gamma*efnsi)^(-1));
                evi(i) = temp/beta;
            end
            if all(evi<=0) %if stopping version wants to stop
                i = AllocationTieBreaker( parameters, 1:parameters.M,  mu, sigma, parameters.pdetieoption);
            else
                [evimax,i] = max(evi);
                idx = find(evi == evimax);   
                if size(idx,2) > 1 %tied for a positive number, use regular tiebreaking
                    i = AllocationTieBreaker( parameters, idx,  mu, sigma, parameters.tieoption);
                end
            end
        end
    else
        warning('AllocationIndESPb is only applicable to undiscounted problem');
        return;
    end

end

