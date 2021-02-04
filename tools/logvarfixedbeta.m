function [ logvar ] = logvarfixedbeta( betavar, lambda, efns )
%logvarfixedbeta
% PURPOSE: Returns the log of the variance of mu_i^(t+\betavar)-mu_i^t
% for a fixed betavar, where mu_i^t is the current prior mean
%
% INPUTS: 
% betavar: scalar numeric, number of lookaheads
% lambda: scalar numeric, sampling variance
% efns: scalar numeric, effective number of samples
%
% OUTPUTS: 
% logvar: log of the variance of mu_i^(t+\betavar)-mu_i^t
%
%%
logvar = log(lambda)+log(betavar)-(log(efns)+log(efns+betavar));
end

