 function [ i ] = AllocationRandom( parameters)
%AllocationRandom
% PURPOSE: Implements the allocation policy that randomly allocates among 
% alternatives, called random in in Chick, Gans, Yapar (2020).
%
% INPUTS: 
% parameters: struct, problem parameters are included as fields 
% randtype: randomization type, 1 for uniform, 2 for TTVS
% randprob: randomization probability
%
% OUTPUTS: 
% i: index of the arm to be sampled
%

%%
    i = unidrnd(parameters.M);
end
