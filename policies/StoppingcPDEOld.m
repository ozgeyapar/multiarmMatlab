function [ stop ] = StoppingcPDEOld( parameters, muin, sigmain )
%StoppingcPDEOld
% PURPOSE: Implements the cPDE stopping time defined in Chick, Gans,
% Yapar (2020). Returns 1 for stopping and 0 for continue. It computes
% cPDE for every arm, therefore very slow. StoppingcPDE.m presents a faster
% version, which is recommended.
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
    evi = zeros(1,parameters.M); %preallocation for speed
    for j = 1:parameters.M
        if parameters.delta == 1
            evi(j)=cPDEUndis(parameters, muin, sigmain, j);
            if evi(j) > 0
                stop = 0;
                return;
            end
        elseif parameters.delta < 1 && parameters.delta > 0
            warning('this allocation rule is not defined for discounted problems');
            return;
        else
            warning('cannot calculate undiscounted upper bound: discounting rate delta has to be between 0 and 1');
            return;
        end
    end
    stop = all(evi<=0);
end

