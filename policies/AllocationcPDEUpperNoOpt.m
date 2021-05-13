function [ i ] = AllocationcPDEUpperNoOpt( undissoln, dissoln, parameters, muin, sigmain, randtype, randprob)
%AllocationcPDEUpperNoOpt
% PURPOSE: Implements the allocation policy cPDEUpper defined in Chick, Gans,
% Yapar (2020) with equal weights. Returns the index of the arm to be 
% sampled from at the next period.
%
% INPUTS:
% undissol: variable which contains the standardized solution
%   for undiscounted problem.
% dissoln: variable which contains the standardized solution
%   for discounted problem.
% parameters: struct, problem parameters are included as fields
% muin: numerical vector that contains the prior mean vector
% sigmain: numerical matrix that contains the prior covariance matrix
% randtype: randomization type, 1 for uniform, 2 for TTVS
% randprob: randomization probability
%
% OUTPUTS: 
% i: index of the arm to be sampled

%%
    evi = zeros(1,parameters.M); %preallocation for speed
    for j = 1:parameters.M
        if parameters.delta == 1
            evi(j)=cPDEUpperUndisNoOpt(undissoln, parameters, muin, sigmain, j);
        elseif parameters.delta < 1 && parameters.delta > 0
            evi(j)=cPDEUpperDis(dissoln, parameters, muin, sigmain, j );
        else
            warning('cannot calculate undiscounted upper bound: discounting rate delta has to be between 0 and 1');
            return;
        end
    end
     [ i ] = AllocationBasedonEVI( evi, 1, parameters, muin, sigmain, randtype, randprob);

end
