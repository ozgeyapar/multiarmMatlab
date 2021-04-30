 function [ i ] = AllocationRandom( parameters)
%AllocationRandom
% PURPOSE: Implements the allocation policy that randomly allocates among 
% alternatives, called random in in Chick, Gans, Yapar (2020).
%
% INPUTS: 
% parameters: struct, problem parameters are included as fields (See 
%   ExampleProblemSetup.m for an example of how to generate this struct)
% randtype: randomization type, 1 for uniform, 2 for TTVS
% randprob: randomization probability
%
% OUTPUTS: 
% i: index of the arm to be sampled
%
% SUGGESTED WORKFLOW: See ExampleProblemSetup.m for an example of 
% generating the 'parameters' input

%%
    i = unidrnd(parameters.M);
end
