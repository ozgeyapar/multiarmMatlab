function [ alphas, evi] = cPDEUpperUndisOpt( undissol, parameters, mu, sigma, i )
%cPDEUpperUndisOpt
% PURPOSE: Calculates the EVI estimated by cPDEUpper approach with optimized 
% weights for undiscounted problem, defined in Chick, Gans, Yapar (2020)
%
% INPUTS: 
% undissol: variable which contains the standardized solution
%   for undiscounted problem. SetSolFiles.m generates the standardized
%   solution and PDELoadSolnFiles is used to load it. See
%   AllocationcPDEUpperOpt.m for more details.
% parameters: struct, problem parameters are included as fields 
% mu: numerical vector that contains the prior mean vector
% sigma: numerical matrix that contains the prior covariance matrix
% i: numerical scalar, index of the arm whose EVI will be calculated
%
% OUTPUTS: 
% alphas: optimal weights to allocate sampling cost among arms
% evi: EVI of arm i estimated using cPDEUpper approach
%

%%
    [a,b,d,Mprime] = TransformtoLinearVersion( mu, sigma, parameters, i ); %Convert the problem into linear version
    %[~,g0] = max(a); %current best alternative
    if parameters.delta==1
        beta = (parameters.c(i)/parameters.P)^(-1/3) .* parameters.lambdav(i)^(-1/3) .* diff(b).^(1/3);
        gamma = (parameters.c(i)/parameters.P)^(2/3) .* parameters.lambdav(i)^(-1/3) .* diff(b).^(-2/3);
    else
        warning('cannot calculate undiscounted upper bound: discounting rate delta has to be 1');
        return;
    end
    %[ beta,gamma] = CalculateScaleParameters( a, b, d, Mprime, i , parameters); %Calculate beta and gamma values for each alternative
    efnsi = parameters.lambdav(i)/sigma(i,i); %effective number of samples

    if Mprime == 1 %there is no value in sampling and it is optimal to stop immediately.
        evi = 0;
        alphas = [];
    elseif Mprime == 2
        l=1;
        evi=(b(l+1)-b(l)) * beta(l)^(-1)*PDEGetVals(undissol,-beta(l)*abs(d(l+1)),(efnsi*gamma(l))^(-1));
        evi = parameters.P*evi;
        alphas = [];
    else 
        fun = @(alpha) sum(arrayfun(@(l) (b(l+1)-b(l)) * alpha(l)^(1/3) * beta(l)^(-1)*PDEGetVals(undissol,-(alpha(l)^(-1/3))*beta(l)*abs(d(l+1)),(efnsi*gamma(l)*alpha(l)^(2/3))^(-1)),1:(Mprime-1)));
        alpha0 = ones(1,Mprime-1)*(1/(Mprime-1)); %starting point for the function 
        lb = zeros(1,Mprime-1) + eps + 1e-6; %alpha > 0, epsilon plus default TolCon to ensure strict 
        ub = ones(1,Mprime-1) - eps - 1e-6; %alpha < 1
        A = []; %no inequality constraint
        b = []; %no inequality constraint
        Aeq = ones(1,Mprime-1); %sum of alphas = 1
        beq = [1]; %sum of alphas = 1
        %options = optimoptions('fmincon','MaxIterations',10);
        options = optimoptions('fmincon','algorithm','sqp','MaxIterations',8, 'Display', 'off');
        nonlcon = [];
        [alphas, evi] = fmincon(fun,alpha0,A,b,Aeq,beq,lb,ub,nonlcon,options);
        evi = parameters.P*evi;
    end
end
% 
% function [ beta,gamma ] = CalculateScaleParameters( a, b, d, Mprime, i ,parameters )
% %Scale parameters \beta and \gamma are defined
% %  \beta and \gamma are Mprime-1 vectors
% if parameters.delta==1
%     beta = (parameters.c(i)/parameters.P)^(-1/3) .* parameters.lambdav(i)^(-1/3) .* diff(b).^(1/3);
%     gamma = (parameters.c(i)/parameters.P)^(2/3) .* parameters.lambdav(i)^(-1/3) .* diff(b).^(-2/3);
% else
%     warning('cannot calculate undiscounted upper bound: discounting rate delta has to be 1');
%     return;
% end
% end
