function [ var ] = varfixedbeta( betavar, lambda, efns )
%varfixedbeta
% PURPOSE: Returns the variance of mu_i^(t+\betavar)-mu_i^t for a fixed 
%   betavar, where mu_i^t is the current prior mean
%
% INPUTS: 
% betavar: scalar numeric, number of lookaheads
% lambda: scalar numeric, sampling variance
% efns: scalar numeric, effective number of samples
%
% OUTPUTS: 
% logvar: variance of mu_i^(t+\betavar)-mu_i^t
%
%%
var = (lambda*betavar)/(efns*(efns+betavar));
end

