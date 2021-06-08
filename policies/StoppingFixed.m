function [ stop ] = StoppingFixed(Tfixed, t)
%StoppingFixed
% PURPOSE: Implements the fixed stopping time, the fixed sample size is 
% defined in parameters input as Tfixed. Returns 1 for stopping and 0 for 
% continue.
%
% INPUTS: 
% Tfixed: The period at which the fixed stopping rule stops
% t: numerical scalar, current period
%
% OUTPUTS: 
% stop: 1 for stopping and 0 for continue.


%%
if t<Tfixed
    stop = 0;
else
    stop = 1;
    
end

