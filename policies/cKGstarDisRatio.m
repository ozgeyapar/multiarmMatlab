function [ optbeta, kgi] = cKGstarDisRatio( parameters, mu, sigma, i )
%cKGstarDisRatio
% PURPOSE: Calculates the cKG* index as benefit to cost ratio, as defined
% in Chick, Gans, Yapar (2020). Allows positive sampling cost and 
% positive discounting.
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
    [a,b,d,Mprime] = TransformtoLinearVersion( mu, sigma, parameters, i );
    [~,g0] = max(a); %current best alternative
    efnsi = parameters.lambdav(i)/sigma(i,i); %effective number of samples

    LOWVAL = 0;     % require at least 2^0 = 1 step look ahead
    HIVAL = 7;      % check lookahead up to 2^HIVAL steps aheads
    NUMCHECKS = 15; % check 15 values of increment
    betavec = 2.^(LOWVAL:((HIVAL-LOWVAL)/NUMCHECKS):HIVAL);

    if Mprime == 1 %there is no value in sampling, by definition kg takes one sample
       kgi = -(log(parameters.delta)+log(parameters.c(i))-log(parameters.P))-(log((1-parameters.delta))+log(a(g0)));
       optbeta=1;
    else
        %initilize
        temp = zeros(1,Mprime-1);
        %start with beta=1
        optbeta=1;
        betavar=1;
        for l = 1 : (Mprime-1)
            var = varfixedbeta(betavar, parameters.lambdav(i), efnsi );
            logstd = (1/2)*logvarfixedbeta( betavar, parameters.lambdav(i), efnsi );
            logbdiff = log((b(l+1)-b(l)));
            logloss = logPsifunc(abs(d(l+1))/sqrt(var));
            logdisc = log(parameters.delta);
            temp(l) = logdisc + logstd + logbdiff + logloss;
        end
        %log of value of stopping now
        stopnow = log((1-parameters.delta))+log(a(g0));
        %Numerically stable way to evaluate log(benefit) = log(sum(exp(temp)))
        maxvalue = max(temp,stopnow);
        logbenefit = tempmax + log(sum(exp(temp-maxvalue))-exp(stopnow-maxvalue));
        %Difference between log(benefit)-log(cost), which is equal to log(benefit/cost)
        kgi = logbenefit-(log(parameters.c(i))-log(parameters.P));
        %search over betas
        for iter = 2:length(betavec)
           for l = 1 : (Mprime-1)
                var = varfixedbeta(betavec(iter), parameters.lambdav(i), efnsi );
                logstd = (1/2)*logvarfixedbeta( betavec(iter), parameters.lambdav(i), efnsi );
                logbdiff = log((b(l+1)-b(l)));
                logloss = logPsifunc(abs(d(l+1))/sqrt(var));
                logdisc = betavec(iter)*log(parameters.delta);
                temp(l) = logdisc + logstd + logbdiff + logloss;
           end
            %log of value of stopping now
            stopnow = log((1-parameters.delta^betavec(iter)))+log(a(g0));
            %Numerically stable way to evaluate log(benefit) = log(sum(exp(temp)))
            maxvalue = max(temp,stopnow);
            logbenefit = tempmax + log(sum(exp(temp-maxvalue))-exp(stopnow-maxvalue));
            %sum cost over 0 to betavar(iter)
            cost = -(parameters.c(i)/parameters.P)*(1-parameters.delta^betavec(iter))/(1-parameters.delta);
            %Difference between log(benefit)-log(cost), which is equal to log(benefit/cost)
            kgitemp = logbenefit-log(cost);

            if kgitemp > kgi
               kgi = kgitemp;
               optbeta = betavec(iter);
           end
        end
    end
end

