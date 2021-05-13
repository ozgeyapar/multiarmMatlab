 function [ i ] = AllocationVariance( parameters, muin, sigmain )
%AllocationVariance
% PURPOSE: Implements the allocation policy that allocates to the 
% alternative with the lowest effective number of samples (or greatest 
% variance if sampling variances are equal), called variance in Chick, 
% Gans, Yapar (2020).
%
% INPUTS: 
% parameters: struct, problem parameters are included as fields 
% muin: numerical vector that contains the prior mean vector
% sigmain: numerical matrix that contains the prior covariance matrix
%
% OUTPUTS: 
% i: index of the arm to be sampled
%

%%
    efns = zeros(1,parameters.M); %preallocation for speed
    for j = 1:parameters.M
        efns(j) = parameters.lambdav(j)/sigmain(j,j);
    end
    [efnsmin,i] = min(efns);
    %tie breaker
    idx = find(efns == efnsmin);
    if size(idx,2) > 1
        i = AllocationTieBreaker( parameters, idx,  muin, sigmain, parameters.tieoption);
    end
end
