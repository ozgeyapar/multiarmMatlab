function [ evi ] = cPDEUpperDis( dissol,parameters,  mu, sigma, i )
%cPDEUpperDis
% PURPOSE: Calculates the EVI estimated by cPDEUpper approach for
% discounted problem, defined in Chick, Gans, Yapar (2020)
%
% INPUTS: 
% dissoln: variable which contains the standardized solution
%   for discounted problem. SetSolFiles.m generates the standardized
%   solution and PDELoadSolnFiles is used to load it. See
%   AllocationcPDEUpper.m for more details.
% parameters: struct, problem parameters are included as fields (See 
%   ExampleProblemSetup.m for an example of how to generate this struct)
% mu: numerical vector that contains the prior mean vector
% sigma: numerical matrix that contains the prior covariance matrix
% i: numerical scalar, index of the arm whose EVI will be calculated
%
% OUTPUTS: 
% evi: EVI of arm i estimated using cPDEUpper approach
%
% SUGGESTED WORKFLOW: See ExampleProblemSetup.m for an example of 
% generating the 'parameters' input, and see AllocationcPDEUpper.m for
% examples on how to call this function

%%
    %Convert the problem into linear version
    [a,b,d,Mprime] = TransformtoLinearVersion( mu, sigma, parameters, i );
    [~,g0] = max(a); %current best alternative
    if parameters.delta<1 && parameters.delta>0
        beta = parameters.disc^(-1/2) * parameters.lambdav(i)^(-1/2);
        %    kappa = parameters.disc^(-3/2) * parameters.lambdav(i)^(-1/2) * parameters.c(i)/b(g0);
        kappa = beta * (parameters.c(i)/(b(g0)*parameters.P))*parameters.disc^(-1); 
    else
        warning('cannot calculate discounted lower bound: discounting rate delta has to be (0,1)');
        return;
    end
    %[ beta,kappa] = CalculateScaleParameters( a, b, d, Mprime, i, parameters );
    efnsi = parameters.lambdav(i)/sigma(i,i); %effective number of samples

    if Mprime == 1 %one alternative, sample or not, exact solution
        %eviold = b(g0)*beta^(-1)*(PDEGetVals(dissol,beta*a(g0)/b(g0)+kappa,(efnsi*parameters.disc)^(-1))-kappa)-a(g0) ;
        if b(g0) == 0
            evi = 0;
        elseif a(g0)==0
            bbetafact = beta/b(g0);
            evi = parameters.P*((PDEGetVals(dissol,kappa,(efnsi*parameters.disc)^(-1)) - kappa) / bbetafact);
        else
            bbetafact = beta*a(g0)/b(g0);
            evi = parameters.P*((PDEGetVals(dissol,bbetafact+kappa,(efnsi*parameters.disc)^(-1)) - kappa - bbetafact) / bbetafact) * a(g0);
        end
    else
        evialt = zeros(1,Mprime-1); %preallocation for speed
        for l =1:Mprime-1
            evialt(l)=(b(l+1)-b(l)) * beta^(-1) * PDEGetVals(dissol,-beta*abs(d(l+1)),(efnsi*parameters.disc)^(-1));
        end
        %eviold = b(g0)*beta^(-1)*(PDEGetVals(dissol,beta*a(g0)/b(g0)+kappa,(efnsi*parameters.disc)^(-1))-kappa)-a(g0)+sum(evialt);
        if b(g0) ==0 
            evi = parameters.P*sum(evialt);
        elseif a(g0)==0
            bbetafact = beta/b(g0);
            evi = parameters.P*((PDEGetVals(dissol,kappa,(efnsi*parameters.disc)^(-1)) - kappa) / bbetafact + sum(evialt));
        else
            bbetafact = beta*a(g0)/b(g0);
            evi = parameters.P*((PDEGetVals(dissol,bbetafact+kappa,(efnsi*parameters.disc)^(-1)) - kappa - bbetafact) / bbetafact + sum(evialt)/a(g0)) * a(g0);
        end
    end
end

% function [ beta,kappa ] = CalculateScaleParameters( a, b, d, Mprime, i, parameters )
% %Scale parameters \beta and \kappa are defined
% %  \beta and \kappa are scalars
% [~,g0] = max(a); %current best alternative
% 
% if parameters.delta<1 && parameters.delta>0
%     beta = parameters.disc^(-1/2) * parameters.lambdav(i)^(-1/2);
%     %    kappa = parameters.disc^(-3/2) * parameters.lambdav(i)^(-1/2) * parameters.c(i)/b(g0);
%     kappa = beta * (parameters.c(i)/(b(g0)*parameters.P))*parameters.disc^(-1); 
% else
%     warning('cannot calculate discounted lower bound: discounting rate delta has to be (0,1)');
%     return;
% end
% end
% 
