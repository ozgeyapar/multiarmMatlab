function [ kgi] = cKG1DisRatio(parameters,  mu, sigma, i )
%cKG1DisRatio
% PURPOSE: Calculates the cKG1 index as benefit to cost ratio, as defined
% in Chick, Gans, Yapar (2020). FPD(2009) defined cKG1 for the case of zero 
% sampling cost. This function implements it for positive sampling cost and 
% positive discounting.
% 
% INPUTS: 
% parameters: struct, problem parameters are included as fields 
% mu: numerical vector that contains the prior mean vector
% sigma: numerical matrix that contains the prior covariance matrix
% i: numerical scalar, index of the arm whose cKG1 index will be calculated
%
% OUTPUTS: 
% kgi: log of cKG1 index for arm i, normalized for P and I
%

%%
    %Convert the problem into linear version
    [a,b,d,Mprime] = TransformtoLinearVersion( mu, sigma, parameters, i );
    [~,g0] = max(a); %current best alternative
    efnsi = parameters.lambdav(i)/sigma(i,i); %effective number of samples

    if Mprime == 1 %there is no value in sampling, by definition kg takes one sample
       kgi = -(log(parameters.delta)+log(parameters.c(i))-log(parameters.P))-(log((1-parameters.delta))+log(a(g0)));
    else
        %initilize
        temp = zeros(1,Mprime-1);
        betavar = 1; %one-step lookahead
        for l = 1:Mprime-1
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
    end
end