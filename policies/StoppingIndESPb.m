function [ stop] = StoppingIndESPb( parameters, mu, sigma )
%StoppingcKG1Ratio
% PURPOSE: Implements the stopping time that is based on ESP_b
% from Chick and Frazier (2012), which is designed for independent
% arms. Returns 1 for stopping and 0 for continue.
%
% INPUTS: 
% parameters: struct, problem parameters are included as fields (See 
%   ExampleProblemSetup.m for an example of how to generate this struct)
% muin: numerical vector that contains the prior mean vector
% sigmain: numerical matrix that contains the prior covariance matrix
%
% OUTPUTS: 
% stop: 1 for stopping and 0 for continue.
%
% SUGGESTED WORKFLOW: See ExampleProblemSetup.m for an example of 
% generating the 'parameters' input

%%
    if parameters.delta == 1
        cont = false(1,parameters.M);
        for i = 1:parameters.M
            beta = (parameters.c(i)/parameters.P)^(-1/3) .* parameters.lambdav(i)^(-1/3);
            gamma = (parameters.c(i)/parameters.P)^(2/3) .* parameters.lambdav(i)^(-1/3);
            efnsi = parameters.lambdav(i)/sigma(i,i);
            [maxofothers,ind] = max([mu(1:i-1);mu(i+1:length(mu))]);
            temp = CFApproxBoundW((gamma*efnsi)^(-1));
            cont(i) = temp > abs(mu(i)-parameters.I(i)/parameters.P-maxofothers+parameters.I(ind)/parameters.P)*beta;
        end
        %display(cont);
        stop = all(cont==0);
    else
        warning('StoppingIndESPb is only applicable to undiscounted problem');
        return;
    end
end

