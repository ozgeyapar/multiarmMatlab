function [ a,b,d,Mprime ] = TransformtoLinearVersion( mu, sigma, parameters, i )
%TransformtoLinearVersion
% PURPOSE: Converts expected maximum of posterior means to the form of 
% a{g(0)}+\b{g(0)} Z_i^T + \sum_{l=1}^{Mprime-1} (b{l+1}-b{l}) (-|d{l}|+Z_i^T)^+
% where g(0) is the current maximum and Z_i^T is a random variable
%
% INPUTS: 
% mu, sigma: prior mean vector and prior covariance matrix
% parameters: parameter set of the problem, see ExampleProblemSetup.m for
%   an example of how to set parameters
% i: the alternative we sample from
%
% OUTPUTS: 
% a: intercept vector
% b: slope vector
% d: intersection points vector
% Mprime: the number of undominated alternatives 
%
% Since Matlab does not allow array indices to start from 0, d_l in the
% Chick, Gans, Yapar (2020) is d_(l+1) in the code.
%%

    a = mu - parameters.I./parameters.P;
    b = (sigma(:,i)/sigma(i,i));

    [a,b]=SortAlternatives(a,b);
    [d,S]=AffineBreakpoints(a,b);
    d = d([1,S+1]);
    Mprime=length(S);
    a = a(S);
    b = b(S);
end

