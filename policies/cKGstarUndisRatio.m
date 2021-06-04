function [ optbeta, kgi] = cKGstarUndisRatio( parameters, mu, sigma, i )
%cKGstarUndisRatio
% PURPOSE: Calculates the cKG* index as benefit to cost ratio, as defined
% in Chick, Gans, Yapar (2020). Allows positive sampling cost and 
% no discounting.
% 
% INPUTS: 
% parameters: struct, problem parameters are included as fields
% mu: numerical vector that contains the prior mean vector
% sigma: numerical matrix that contains the prior covariance matrix
% i: numerical scalar, index of the arm whose EVI will be calculated
%
% OUTPUTS: 
% optbeta: optimal fixed lookahead
% kgi: log of cKG* index for arm i, normalized for P and I
%

%%
    %Convert the problem into linear version
    [~,b,d,Mprime] = TransformtoLinearVersion( mu, sigma, parameters, i );
    %[~,g0] = max(a); %current best alternative
    efnsi = parameters.lambdav(i)/sigma(i,i); %effective number of samples

    LOWVAL = 0;     % require at least 2^0 = 1 step look ahead
    HIVAL = 7;      % check lookahead up to 2^HIVAL steps aheads
    NUMCHECKS = 20; % check 20 values of increment
    betavec = 2.^(LOWVAL:((HIVAL-LOWVAL)/NUMCHECKS):HIVAL);
    %betavec = (2.^LOWVAL:1:2.^HIVAL); %used to check every possible discrete value

    if Mprime == 1 %there is no value in sampling, by definition kg takes one sample
       kgi = -log(parameters.c(i))-log(parameters.P);
       optbeta=1;
    else
        %initilize
        temp = zeros(1,Mprime-1);
        %sampling once to start
        optbeta=1;
        betavar=1;
        %kg value for a single observation
        for l = 1:Mprime-1
            var = varfixedbeta(betavar, parameters.lambdav(i), efnsi );
            logstd = (1/2)*logvarfixedbeta( betavar, parameters.lambdav(i), efnsi );
            logbdiff = log((b(l+1)-b(l)));
            logloss = logPsifunc(abs(d(l+1))/sqrt(var));
            temp(l) = logstd + logbdiff + logloss;
        end
        %Numerically stable way to evaluate log(benefit) = log(sum(exp(temp)))
        tempmax = max(temp);
        logbenefit = tempmax + log(sum(exp(temp-tempmax)));
        %Difference between log(benefit)-log(cost), which is equal to log(benefit/cost)
        kgi = logbenefit-(log(parameters.c(i))-log(parameters.P)); 
        %iterate through other values
        for iter = 2:length(betavec)
           for l = 1:Mprime-1
                var = varfixedbeta(betavec(iter), parameters.lambdav(i), efnsi );
                logstd = (1/2)*logvarfixedbeta(betavec(iter), parameters.lambdav(i), efnsi );
                logbdiff = log((b(l+1)-b(l)));
                logloss = logPsifunc(abs(d(l+1))/sqrt(var));
                temp(l) = logstd + logbdiff + logloss;
           end
           tempmax = max(temp);
           logbenefit = tempmax + log(sum(exp(temp-tempmax)));
           %Difference between log(benefit)-log(cost), which is equal to log(benefit/cost)
           curr = logbenefit-(log(parameters.c(i))+log(betavec(iter))-log(parameters.P)); 
           if curr > kgi 
               optbeta = betavec(iter);
               kgi = curr;
           end
        end
    end
end
