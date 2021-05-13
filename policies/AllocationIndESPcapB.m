function [ i] = AllocationIndESPcapB( undissol, parameters, mu, sigma, randtype, randprob )
%AllocationIndESPcapB
% PURPOSE: Implements the allocation policy that is based on ESP_B
% from Chick and Frazier (2012), which is designed for independent
% arms. Returns the index of the arm to be sampled from at the next period.
%
% INPUTS: 
% undissol: variable which contains the standardized solution
%   for undiscounted problem.
% parameters: struct, problem parameters are included as fields 
% mu: numerical vector that contains the prior mean vector
% sigma: numerical matrix that contains the prior covariance matrix
% randtype: randomization type, 1 for uniform, 2 for TTVS
% randprob: randomization probability
%
% OUTPUTS: 
% i: index of the arm to be sampled
%

%%
    if parameters.delta == 1
        evi = zeros(1,parameters.M);
        for i = 1:parameters.M
            beta = (parameters.c(i)/parameters.P)^(-1/3) .* parameters.lambdav(i)^(-1/3);
            gamma = (parameters.c(i)/parameters.P)^(2/3) .* parameters.lambdav(i)^(-1/3);
            efnsi = parameters.lambdav(i)/sigma(i,i);
            [maxofothers,ind] = max([mu(1:i-1);mu(i+1:length(mu))]);
            temp = PDEGetVals(undissol,-beta*(abs(mu(i)-parameters.I(i)/parameters.P-maxofothers+parameters.I(ind)/parameters.P)),(gamma*efnsi)^(-1));
            evi(i) = temp/beta;
        end
        [ i ] = AllocationBasedonEVI( evi, 1, parameters, mu, sigma, randtype, randprob);
    else
        warning('AllocationIndESPb is only applicable to undiscounted problem');
        return;
    end

end

