function [ stop ] = StoppingcKG1( parameters, muin, sigmain )
%StoppingcKG1
% PURPOSE: Implements the stopping time that is based on correlated KG1 
% from Frazier, Powell, Dayanik (2009), KG value is calculated as the
% difference between of benefit to cost. Returns 1 for stopping and 0 for
% continue.
%
% INPUTS: 
% parameters: struct, problem parameters are included as fields
% muin: numerical vector that contains the prior mean vector
% sigmain: numerical matrix that contains the prior covariance matrix
%
% OUTPUTS: 
% stop: 1 for stopping and 0 for continue.
%

%%
    kg = zeros(1,parameters.M); %preallocation for speed
    for j = 1:parameters.M
        if parameters.delta == 1
            kg(j) = cKG1Undis( parameters, muin, sigmain, j );
        elseif parameters.delta < 1 && parameters.delta > 0
            kg(j) = cKG1Dis( parameters, muin, sigmain, j );
        else
            warning('cannot calculate undiscounted upper bound: discounting rate delta has to be between 0 and 1');
            return;
        end
    end
    % KG values went through exponential transformation
    stop = all(kg<=1);
end

