function [ stop ] = StoppingFixed(Tfixed, t)
%StoppingFixed
% PURPOSE: Implements the fixed stopping time, the fixed sample size is 
% defined in parameters input as Tfixed. Returns 1 for stopping and 0 for 
% continue.
%
% INPUTS: 
% parameters: struct, problem parameters are included as fields (See 
%   ExampleProblemSetup.m for an example of how to generate this struct)
% t: numerical scalar, current period
%
% OUTPUTS: 
% stop: 1 for stopping and 0 for continue.
%
% SUGGESTED WORKFLOW: See ExampleProblemSetup.m for an example of 
% generating the 'parameters' input

%%
if t<Tfixed
    stop = 0;
else
    stop = 1;
    
end

