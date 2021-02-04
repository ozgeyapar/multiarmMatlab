function [ optbeta, kgi] = cKGstarUndis( parameters, mu, sigma, i )
%cKGstarUndis
% PURPOSE: Calculates the estimate of EVI for arm i using cKG* approach
% for positive sampling cost and no discounting, defined in 
% Chick, Gans, Yapar (2020)
% 
% INPUTS: 
% parameters: struct, problem parameters are included as fields (See 
%   ExampleProblemSetup.m for an example of how to generate this struct)
% mu: numerical vector that contains the prior mean vector
% sigma: numerical matrix that contains the prior covariance matrix
% i: numerical scalar, index of the arm whose EVI will be calculated
%
% OUTPUTS: 
% optbeta: optimal fixed lookahead
% kgi: exp(EVI) of arm i estimated using cKG1 approach, normalized for P
%   and I. Take the log and rescale to get the actual EVI.
%
% SUGGESTED WORKFLOW: See ExampleProblemSetup.m for an example of 
% generating the 'parameters' input

%%
    %Convert the problem into linear version
    [~,b,d,Mprime] = TransformtoLinearVersion( mu, sigma, parameters, i );
    %[~,g0] = max(a); %current best alternative
    efnsi = parameters.lambdav(i)/sigma(i,i); %effective number of samples

    LOWVAL = 0;     % require at least 2^0 = 1 step look ahead
    HIVAL = 7;      % check lookahead up to 2^HIVAL steps aheads
    NUMCHECKS = 20; % check 20 values of increment
    betavec = 2.^(LOWVAL:((HIVAL-LOWVAL)/NUMCHECKS):HIVAL);
    %betavec = (2.^LOWVAL:1:2.^HIVAL); %used to check every possible discrete value

    %initilize
    temp = zeros(1,Mprime-1);
    %sampling once to start
    optbeta=1;
    betavar=1;
    %kg value for a single observation
    for l = 1:Mprime-1
        var = varfixedbeta(betavar, parameters.lambdav(i), efnsi );
        temp(l)=(b(l+1)-b(l)) * sqrt(var) * Psifunc(abs(d(l+1))/sqrt(var));
    end
    %exponential calculation to avoid substraction
    kgi = exp(sum(temp))/exp(parameters.c(i)/parameters.P);
    %iterate through other values
    for iter = 2:length(betavec)
       for l = 1:Mprime-1
            var = varfixedbeta(betavec(iter), parameters.lambdav(i), efnsi );
            temp(l)=(b(l+1)-b(l)) * sqrt(var) * Psifunc(abs(d(l+1))/sqrt(var));      
       end
       curr = exp(sum(temp))/exp(parameters.c(i)*betavec(iter)/parameters.P); 
       if curr > kgi 
           optbeta = betavec(iter);
           kgi = curr;
       end
    end
end
