function [ i] = AllocationIndESPb( parameters, mu, sigma, randtype, randprob )
%AllocationIndESPb
% PURPOSE: Implements the allocation policy that is based on ESP_b
% from Chick and Frazier (2012), which is designed for independent
% arms. Returns the index of the arm 
% to be sampled from at the next period.
%
% INPUTS: 
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
% generating the 'parameters' input

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
                temp = CFApproxBoundW((gamma*efnsi)^(-1));
                evi(i) = temp - (abs(mu(i)-parameters.I(i)/parameters.P-maxofothers+parameters.I(ind)/parameters.P))*(beta);
            end
            [~,indmax] = max(evi);
            evi(indmax) = -Inf;
            [evimax2, i] = max(evi);
            idx = find(evi == evimax2);   
            if size(idx,2) > 1 %tied for a positive number, use regular tiebreaking
                i = AllocationTieBreaker( parameters, idx,  muin, sigmain, parameters.tieoption);
            end
        else
            evi = zeros(1,parameters.M);
            for i = 1:parameters.M
                beta = (parameters.c(i)/parameters.P)^(-1/3) .* parameters.lambdav(i)^(-1/3);
                gamma = (parameters.c(i)/parameters.P)^(2/3) .* parameters.lambdav(i)^(-1/3);
                efnsi = parameters.lambdav(i)/sigma(i,i);
                [maxofothers,ind] = max([mu(1:i-1);mu(i+1:length(mu))]);
                temp = CFApproxBoundW((gamma*efnsi)^(-1));
                evi(i) = temp - (abs(mu(i)-parameters.I(i)/parameters.P-maxofothers+parameters.I(ind)/parameters.P))*(beta);
            end
            [evimax,i] = max(evi);
            idx = find(evi == evimax);   
            if size(idx,2) > 1 %tied for a positive number, use regular tiebreaking
                i = AllocationTieBreaker( parameters, idx,  muin, sigmain, parameters.tieoption);
            end
        end
    else
        warning('AllocationIndESPb is only applicable to undiscounted problem');
        return;
    end

end

