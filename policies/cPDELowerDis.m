function [ evi ] = cPDELowerDis( dissol, parameters, mu, sigma, i )
%cPDELowerDis
% PURPOSE: Calculates the EVI estimated by cPDELower approach for
% discounted problem, defined in Chick, Gans, Yapar (2020)
%
% INPUTS: 
% dissoln: variable which contains the standardized solution
%   for discounted problem. SetSolFiles.m generates the standardized
%   solution and PDELoadSolnFiles is used to load it. See
%   AllocationcPDELower.m for more details.
% parameters: struct, problem parameters are included as fields
% mu: numerical vector that contains the prior mean vector
% sigma: numerical matrix that contains the prior covariance matrix
% i: numerical scalar, index of the arm whose EVI will be calculated
%
% OUTPUTS: 
% evi: EVI of arm i estimated using cPDELower approach
%

%%
    %Convert the problem into linear version
    [a,b,~,~] = TransformtoLinearVersion( mu, sigma, parameters, i );
    [~,g0] = max(a); %current best alternative
    if parameters.delta<1 && parameters.delta>0
        beta = parameters.disc^(-1/2) * parameters.lambdav(i)^(-1/2);
        %kappa2 = parameters.disc^(-3/2) * parameters.lambdav(i)^(-1/2) * parameters.c(i)/b(g0);
        kappa = beta * (parameters.c(i)/(parameters.P*b(g0)))*parameters.disc^(-1);% algebraically same as prior commented line, but hopefully more stable
    else
        warning('cannot calculate discounted lower bound: discounting rate delta has to be (0,1)');
        return;
    end
    %[ beta,kappa] = CalculateScaleParameters( a, b, d, Mprime, i , parameters);
    efnsi = parameters.lambdav(i)/sigma(i,i); %effective number of samples

    %Stop or not, for the best alternative, ignore others
    %eviold = b(g0)*beta^(-1)*(PDEGetVals(dissol,beta*a(g0)/b(g0)+kappa,(efnsi*parameters.disc)^(-1))-kappa)-a(g0);
    if b(g0) == 0 
        evi = 0;
    elseif a(g0)==0
        bbetafact = beta/b(g0);
        evi = parameters.P*(PDEGetVals(dissol,kappa,(efnsi*parameters.disc)^(-1)) - kappa) / bbetafact;
    else
        bbetafact = beta*a(g0)/b(g0);
        evi = parameters.P*( (PDEGetVals(dissol,bbetafact+kappa,(efnsi*parameters.disc)^(-1)) - kappa - bbetafact) / bbetafact) * a(g0);
    end

end
% 
% function [ beta,kappa ] = CalculateScaleParameters( a, b, d, Mprime, i, parameters )
% %Scale parameters \beta and \kappa are defined
% %  \beta and \kappa are scalars
% [~,g0] = max(a); %current best alternative
% 
% if parameters.delta<1 && parameters.delta>0
%     beta = parameters.disc^(-1/2) * parameters.lambdav(i)^(-1/2);
%     %kappa2 = parameters.disc^(-3/2) * parameters.lambdav(i)^(-1/2) * parameters.c(i)/b(g0);
%     kappa = beta * (parameters.c(i)/(parameters.P*b(g0)))*parameters.disc^(-1);% algebraically same as prior commented line, but hopefully more stable
% else
%     warning('cannot calculate discounted lower bound: discounting rate delta has to be (0,1)');
%     return;
% end
% end


