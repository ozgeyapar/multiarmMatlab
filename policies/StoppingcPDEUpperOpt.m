function [ stop ] = StoppingcPDEUpperOpt( undissoln, dissoln, parameters, muin, sigmain )
%StoppingcPDEUpperOpt
% PURPOSE: Implements the stopping time cPDEUpper defined in Chick, Gans,
% Yapar (2020) with optimized weights. Returns 1 for stopping and 0 for
% continue.
%
% INPUTS: 
% undissol: variable which contains the standardized solution
%   for undiscounted problem. SetSolFiles.m generates the standardized
%   solution and PDELoadSolnFiles is used to load it, see 
%   ExamplePolicies.m for an example.
% dissoln: variable which contains the standardized solution
%   for discounted problem. SetSolFiles.m generates the standardized
%   solution and PDELoadSolnFiles is used to load it.
% parameters: struct, problem parameters are included as fields
% muin: numerical vector that contains the prior mean vector
% sigmain: numerical matrix that contains the prior covariance matrix
%
% OUTPUTS: 
% stop: 1 for stopping and 0 for continue.
%

%%
    evi = zeros(1,parameters.M); %preallocation for speed]
    for j = 1:parameters.M
        if parameters.delta == 1
            [~,evi(j)]=cPDEUpperUndisOpt(undissoln, parameters, muin, sigmain, j);
            if evi(j) > 0
                stop = 0;
                return;
            end
        elseif parameters.delta < 1 && parameters.delta > 0
            evi(j)=cPDEUpperDis(dissoln, parameters, muin, sigmain, j );
            if evi(j) > 0
                stop = 0;
                return;
            end
        else
            warning('cannot calculate undiscounted upper bound: discounting rate delta has to be between 0 and 1');
            return;
        end
    end
    stop = all(evi<=0);
end

