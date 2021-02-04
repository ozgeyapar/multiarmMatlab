function [ kgi] = cKG1UndisRatio( parameters, mu, sigma, i )
%cKG1UndisRatio
% PURPOSE: Calculates the cKG1 index as benefit to cost ratio, as defined
% in Chick, Gans, Yapar (2020). FPD(2009) defined cKG1 for the case of zero 
% sampling cost. This function implements it for positive sampling cost and 
% no discounting.
% 
% INPUTS: 
% parameters: struct, problem parameters are included as fields (See 
%   ExampleProblemSetup.m for an example of how to generate this struct)
% mu: numerical vector that contains the prior mean vector
% sigma: numerical matrix that contains the prior covariance matrix
% i: numerical scalar, index of the arm whose cKG1 index will be calculated
%
% OUTPUTS: 
% kgi: log of cKG1 index for arm i, normalized for P and I
%
% SUGGESTED WORKFLOW: See ExampleProblemSetup.m for an example of 
% generating the 'parameters' input

%%

    %Convert the problem into linear version
    [~,b,d,Mprime] = TransformtoLinearVersion( mu, sigma, parameters, i );
    %[~,g0] = max(a); %current best alternative
    efnsi = parameters.lambdav(i)/sigma(i,i); %effective number of samples

    if Mprime == 1 %there is no value in sampling, by definition kg takes one sample
       kgi = -log(parameters.c(i))-log(parameters.P);
    else
        %initilize
        temp = zeros(1,Mprime-1);
        betavar = 1; %one-step lookahead
        for l = 1:Mprime-1
            var = varfixedbeta(betavar, parameters.lambdav(i), efnsi );
            logstd = (1/2)*logvarfixedbeta( betavar, parameters.lambdav(i), efnsi );
            logbdiff = log((b(l+1)-b(l)));
            logloss = logPsifunc(abs(d(l+1))/sqrt(var));
            temp(l) = logstd + logbdiff + logloss;
        end
        %Numerically stable way to evaluate log(benefit) = log(sum(exp(temp)))
        tempmax = max(temp);
        logbenefit = tempmax + log(sum(exp(temp-tempmax)));
        %Difference between log(benefit)-log(cost), which is equal to log(benefit/cost)
        kgi = logbenefit-(log(parameters.c(i))-log(parameters.P));
    end
end
