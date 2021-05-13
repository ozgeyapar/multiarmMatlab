function [results] = SimulationFunc( cfSoln, cgSoln, allpolicy, stoppolicy, rtype, rprob, Tfixed, parameters, thetav, stdnoise, stdrand, settings)
%SimulationFunc
% PURPOSE: Runs one simulation replication for a given policy.
%
% INPUTS: 
% cfSoln: variable which contains the standardized solution
%   for undiscounted problem.
% cgSoln: variable which contains the standardized solution
%   for discounted problem. 
% allpolicy: allocation policy 
% stoppolicy: stopping policy 
% rtype: randomization type for each allocation policy
% rprob: randomization probability for each allocation policy
% Tfixed: fixed stopping time for each stopping policy (used if stopping 
%   policy is fixed).
% parameters: struct, holds the problem parameters
% thetav: vector of actual means
% stdnoise: a matrix of standardized normals, used for observation noise if crn is asked
% stdrand: a matrix of uniform between 1 and 0, used for randomization if crn is asked
% settings: struct of simulation settings such as bound, crn etc.

% OUTPUTS: 
% result: struct that includes simulation results

%%  
    %% Run the simulation for one replication
    %Initilize
    mucur=parameters.mu0;
    sigmacur=parameters.sigma0;
    t = 0;
    alt(t+1)=(0);
    %time(t+1) = t;
    %muvec{t+1} = mucur;
    %sigmavec{t+1} = sigmacur;
    %yvec(t+1)=(0);
    cost = 0;
    SC(t+1) = 0;
    OC(t+1) = 0;
    TC(t+1) = 0;
    stoppedatbound = 0;
    stoppedimm = 0;

    repstart = tic;
    while (~stoppolicy(cfSoln, cgSoln, parameters, mucur, sigmacur, Tfixed, t) && t<settings.BOUND)
         if t == Tfixed - 1 %record if stops because we are at the boundary
            stoppedatbound = 1;
         end
         if (settings.crn == 1)
            parameters.randomizeornot = stdrand(t+1);
            i = allpolicy(cfSoln, cgSoln, parameters, mucur, sigmacur, t, rtype, rprob); %alternative we will sample from
         else
            parameters.randomizeornot = rand;
            i = allpolicy(cfSoln, cgSoln, parameters, mucur, sigmacur, t, rtype, rprob); %alternative we will sample from 
         end
         count = sum(alt(:)==i)+1; %how many times we have called alternetive i so far
         
         if (settings.crn == 0) %random observations, no crn
            y = normrnd(thetav(i),sqrt(parameters.naturelambdav(i))); 
         elseif size(stdnoise,2)>count %use pregenerated values
            y = stdnoise(i,count)*sqrt(parameters.naturelambdav(i))+ thetav(i); %sample from alternative i
         else %we are outside the range of observation matrix
            formatSpec = '%dth arm was sampled %d times, outside of the crn noise matrix range, will continue with random sample';
            warning(formatSpec,i,count)
            y = normrnd(thetav(i),sqrt(parameters.naturelambdav(i))); 
         end
         
         % Bayesian update based on the observation
         [mucur,sigmacur] = BayesianUpdate(mucur,sigmacur,i, y, parameters.lambdav(i));
         
         % Calculate sampling cost
         if (t==0)
            cost = parameters.c(i);
         else
            cost = cost + parameters.delta*parameters.c(i);
         end
         
         %update and save simulation parameters
         t = t+1;
         alt(t+1)=i;
         %time(t+1) = t;
         %muvec{t+1} = mucur;
         %sigmavec{t+1} = sigmacur;
         %yvec(t+1)=y;
            
         %calcualte sampling, opportunity and total cost
         [~,sel] = max(parameters.P*mucur - parameters.I);
         selected = thetav(sel);
         SC(t+1) = cost;
         [~,best] = max(parameters.P*thetav - parameters.I);
         bestvalue = thetav(best);
         OC(t+1) = parameters.P*(bestvalue - selected) - parameters.I(best) + parameters.I(sel);
         TC(t+1) = SC(t+1) + OC(t+1);
    end
    elapsedtime = toc(repstart);
    
    if t == 0 %we stopped immediately
        stoppedimm = 1;
    end
    
    results.thetav = thetav;
    %results.t = time;
    %results.lastt = t; %period in which the algorithm stopped
    %results.alt = alt;
    %results.mu = muvec;
    %results.sigma = sigmavec;
    %results.y = yvec;
    results.SCeach = SC;
    results.OCeach = OC;
    results.TCeach = TC;
    results.CS = (sel == best);
    results.SClast = SC(t+1);
    results.OClast = OC(t+1);
    results.TClast = TC(t+1);
    results.stoppedatbound = stoppedatbound;
    results.stoppedimm = stoppedimm;
    results.lastt = t; %period in which the algorithm stopped
    results.alt = alt; % To compute the ratio of lower vs higher doses

    results.comptime = elapsedtime;
end