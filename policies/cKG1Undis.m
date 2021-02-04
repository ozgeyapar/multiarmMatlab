function [ kgi] = cKG1Undis( parameters, mu, sigma, i )
%cKG1Undis
% PURPOSE: Calculates the estimate of EVI for arm i using cKG1 approach of 
% Frazier, Powell, Dayanik (2009). FPD(2009) defined cKG1 for the case of 
% zero sampling cost. This function implements it for positive sampling 
% cost and no discounting.
% 
% INPUTS: 
% parameters: struct, problem parameters are included as fields (See 
%   ExampleProblemSetup.m for an example of how to generate this struct)
% mu: numerical vector that contains the prior mean vector
% sigma: numerical matrix that contains the prior covariance matrix
% i: numerical scalar, index of the arm whose EVI will be calculated
%
% OUTPUTS: 
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

    %initilize
    temp = zeros(1,Mprime-1);
    betavar = 1; %one-step lookahead
    for l = 1:Mprime-1
        var = varfixedbeta(betavar, parameters.lambdav(i), efnsi );
        temp(l)=(b(l+1)-b(l)) * sqrt(var) * Psifunc(abs(d(l+1))/sqrt(var));
    end
    %Exponential kgi
    kgi = exp(sum(temp))/exp(parameters.c(i)/parameters.P);
end
