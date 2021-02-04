function [ results] = SimOneRepAllocHelper( undissoln, dissoln, parameters, allocationrule, thetav, observ, Tfixed, p)
%SimOneRepAllocHelper
% PURPOSE: Runs one simulation replication for a given allocation policy 
% with a given fixed sample size for given problem parameters.
%
% INPUTS: 
% undissol: variable which contains the standardized solution
%   for undiscounted problem. 
% dissoln: variable which contains the standardized solution
%   for discounted problem. 
% parameters: struct, problem parameters are included as fields
% allocationrule: function handle of the allocation policy
% thetavalue: numeric vector, ground truth vector
% observ: numeric vector, observation vector to be used
% Tfixed: number, fixed sample size
% p: number <= 1, randomization probability if the allocation
%   policy is randomized, negative if non-randomized.
%
% OUTPUTS: 
% results: struct that includes the following  
%     results.thetav ground truth mean
%     results.SCeach  sampling cost at each period
%     results.OCeach opportunity cost at each period
%     results.TCeach total cost at each period
%     results.comptime computation time passed
%
% SUGGESTED WORKFLOW: Used in Func80altOC.m, FuncSec64OC.m
%
%%
    %% Initalize
    if size(thetav, 2) ~= 1 %make sure that theta is a column array
        thetav = thetav';
    end
    
    %simulation variables
    mucur=parameters.mu0;
    sigmacur=parameters.sigma0;
    t = 0;
    alt(t+1)=(0);
    time(t+1) = t;
    muvec{t+1} = mucur;
    sigmavec{t+1} = sigmacur;
    yvec(t+1)=(0);
    cost = 0;
    SC(t+1) = 0;
    OC(t+1) = 0;
    TC(t+1) = 0;

    tic
    while (t<Tfixed)               
         if parameters.randomps == 1
             if rem(sqrt(t+1),1)==0 %randomly sample once in every perfect square
                i = randi(parameters.M,1,1);
             else
                i = allocationrule(undissoln, dissoln, parameters, mucur, sigmacur ,t, p); %alternative we will sample from
             end
         else
              i = allocationrule(undissoln, dissoln, parameters, mucur, sigmacur ,t, p); %alternative we will sample from
         end
         
         count = sum(alt(:)==i)+1; %how many times we have called alternetive i so far
         
         if (parameters.crn == 0) %random observations, no crn
            y = normrnd(thetav(i),sqrt(parameters.naturelambdav(i))); 
         elseif size(parameters.observ,2)>count %use pregenerated values
            y = observ(i,count)*sqrt(parameters.naturelambdav(i))+ thetav(i); %sample from alternative i
         else %we are outside the range of observation matrix
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
         
         %update simulation parameters
         t = t+1;
         alt(t+1)=i;
         time(t+1) = t;
         muvec{t+1} = mucur;
         sigmavec{t+1} = sigmacur;
         yvec(t+1)=y;
            
         %calcualte sampling, opportunity and total cost
         [~,sel] = max(parameters.P*mucur - parameters.I);
         selected = thetav(sel);
         SC(t+1) = cost;
         [~,best] = max(parameters.P*thetav - parameters.I);
         bestvalue = thetav(best);
         OC(t+1) = parameters.P*(bestvalue - selected) - parameters.I(best) + parameters.I(sel);
         TC(t+1) = SC(t+1) + OC(t+1);
    end
    elapsedtime = toc;

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

    %results.samcost = cost; %total sampling cost

    results.comptime = elapsedtime;
end

