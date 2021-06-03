function [ evi] = cPDELowerUndis( undissol, parameters, mu, sigma, i )
%cPDELowerUndis
% PURPOSE: Calculates the EVI estimated by cPDELower approach for
% undiscounted problem, defined in Chick, Gans, Yapar (2020)
%
% INPUTS: 
% undissol: variable which contains the standardized solution
%   for undiscounted problem. 
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
    [a,b,d,Mprime] = TransformtoLinearVersion( mu, sigma, parameters, i );
    %[~,g0] = max(a); %current best alternative
    if parameters.delta==1
        beta = (parameters.c(i)/parameters.P)^(-1/3) .* parameters.lambdav(i)^(-1/3) .* diff(b).^(1/3);
        gamma = (parameters.c(i)/parameters.P)^(2/3) .* parameters.lambdav(i)^(-1/3) .* diff(b).^(-2/3);
    else
        warning('cannot calculate undiscounted lower bound: discounting rate delta has to be 1');
        return;
    end
    %[ beta,gamma] = CalculateScaleParameters( a, b, d, Mprime, i, parameters );
    efnsi = parameters.lambdav(i)/sigma(i,i); %effective number of samples

    if Mprime == 1 %there is no value in sampling and it is optimal to stop immediately.
        evi = 0;
    else
        evialt = zeros(1,Mprime-1); %preallocation for speed
        for l =1:Mprime-1
            evialt(l)=(b(l+1)-b(l)) * beta(l)^(-1)*PDEGetVals(undissol,-beta(l)*abs(d(l+1)),(efnsi*gamma(l))^(-1));
        end
        evi = parameters.P*max(evialt);
    end
end

% function [ beta,gamma ] = CalculateScaleParameters( a, b, d, Mprime, i , parameters )
% %Scale parameters \beta and \gamma are defined
% %  \beta and \gamma are Mprime-1 vectors
% if parameters.delta==1
%     beta = (parameters.c(i)/parameters.P)^(-1/3) .* parameters.lambdav(i)^(-1/3) .* diff(b).^(1/3);
%     gamma = (parameters.c(i)/parameters.P)^(2/3) .* parameters.lambdav(i)^(-1/3) .* diff(b).^(-2/3);
% else
%     warning('cannot calculate undiscounted lower bound: discounting rate delta has to be 1');
%     return;
% end
% end

 