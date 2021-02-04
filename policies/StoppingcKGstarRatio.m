function [ stop ] = StoppingcKGstarRatio( parameters, muin, sigmain )
%StoppingcKGstarRatio
% PURPOSE: Implements the stopping time that is cKGstar defined in Chick, Gans,
% Yapar (2020), KG value is calculated as the ratio of benefit 
% to cost. Returns 1 for stopping and 0 for continue.
%
% INPUTS: 
% parameters: struct, problem parameters are included as fields (See 
%   ExampleProblemSetup.m for an example of how to generate this struct)
% muin: numerical vector that contains the prior mean vector
% sigmain: numerical matrix that contains the prior covariance matrix
%
% OUTPUTS: 
% stop: 1 for stopping and 0 for continue.
%
% SUGGESTED WORKFLOW: See ExampleProblemSetup.m for an example of 
% generating the 'parameters' input

%%
    kg = zeros(1,parameters.M); %preallocation for speed
    for j = 1:parameters.M
        if parameters.delta == 1
            [  ~, kg(j)] = cKGstarUndisRatio( parameters, muin, sigmain, j ) ;
        elseif parameters.delta < 1 && parameters.delta > 0
            [  ~, kg(j)]  = cKGstarDisRatio( parameters, muin, sigmain, j );
        else
            warning('cannot calculate undiscounted upper bound: discounting rate delta has to be between 0 and 1');
            return;
        end
    end
    %kg value is in log
    stop = all(kg<=0);
end

