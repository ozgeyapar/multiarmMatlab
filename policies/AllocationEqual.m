 function [ i ] = AllocationEqual( parameters, t )
%AllocationEqual
% PURPOSE: Implements the allocation policy that equally allocates among 
% alternatives in round robin fashion, called equal in in Chick, Gans, Yapar
% (2020).
%
% INPUTS: 
% parameters: struct, problem parameters are included as fields (See 
%   ExampleProblemSetup.m for an example of how to generate this struct)
% t: numerical scalar, current period, to keep track of the round robin order
%
% OUTPUTS: 
% i: index of the arm to be sampled
%
% SUGGESTED WORKFLOW: See ExampleProblemSetup.m for an example of 
% generating the 'parameters' input

%%
    i = mod(t+1, parameters.M);
    if i == 0
        i = parameters.M;
    end
end
