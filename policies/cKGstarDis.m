function [ optbeta, kgi] = cKGstarDis( parameters, mu, sigma, i )
%cKGstarDis
% PURPOSE: Calculates the estimate of EVI for arm i using cKG* approach
% for positive sampling cost and positive discounting, defined in 
% Chick, Gans, Yapar (2020)
% 
% INPUTS: 
% parameters: struct, problem parameters are included as fields
% mu: numerical vector that contains the prior mean vector
% sigma: numerical matrix that contains the prior covariance matrix
% i: numerical scalar, index of the arm whose EVI will be calculated
%
% OUTPUTS: 
% optbeta: optimal fixed lookahead
% kgi: exp(EVI) of arm i estimated using cKG1 approach, normalized for P
%   and I. Take the log and rescale to get the actual EVI.
%

%%
    %Convert the problem into linear version
    [a,b,d,Mprime] = TransformtoLinearVersion( mu, sigma, parameters, i );
    [~,g0] = max(a); %current best alternative
    efnsi = parameters.lambdav(i)/sigma(i,i); %effective number of samples

    LOWVAL = 0;     % require at least 2^0 = 1 step look ahead
    HIVAL = 7;      % check lookahead up to 2^HIVAL steps aheads
    NUMCHECKS = 15; % check 15 values of increment
    betavec = 2.^(LOWVAL:((HIVAL-LOWVAL)/NUMCHECKS):HIVAL);

    %initilize
    temp = zeros(1,Mprime-1);
    %start with beta=1
    optbeta=1;
    betavar=1;
    for l = 1 : (Mprime-1)
        var = varfixedbeta(betavar, parameters.lambdav(i), efnsi );
        temp(l)=(b(l+1)-b(l)) * sqrt(var) * Psifunc(abs(d(l+1))/sqrt(var));
    end
    %discounted sampling cost
    cost = parameters.c(i)/parameters.P; 
    kgi = exp(parameters.delta*sum(temp))/(exp(cost)*exp((1-parameters.delta)*a(g0)));
    %search over betas
    for iter = 2:length(betavec)
       for l = 1 : (Mprime-1)
            var = varfixedbeta(betavec(iter), parameters.lambdav(i), efnsi );
            temp(l)=(b(l+1)-b(l)) * sqrt(var) * Psifunc(abs(d(l+1))/sqrt(var));
       end
       %sum cost over 0 to betavar(iter)
       cost = -(parameters.c(i)/parameters.P)*(1-parameters.delta^betavec(iter))/(1-parameters.delta);
       kgitemp = exp(parameters.delta^betavec(iter)*sum(temp))/(exp(cost)*exp((1-parameters.delta^betavec(iter))*a(g0)));
       if kgitemp > kgi
           kgi = kgitemp;
           optbeta = betavec(iter);
       end
    end

end

