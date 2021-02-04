function [ results] = SimOneRepFullPolicyHelper( undissoln, dissoln, parameters, allocationrule, stoppingrule, thetav, observ, reps, nodetails, horizon, p)
%SimOneRepFullPolicyHelper
% PURPOSE: Runs one simulation replication for a given allocation policy 
% and a given stopping time for given problem parameters.
%
% INPUTS: 
% undissol: variable which contains the standardized solution
%   for undiscounted problem. 
% dissoln: variable which contains the standardized solution
%   for discounted problem. 
% parameters: struct, problem parameters are included as fields
% allocationrule: function handle of the allocation policy
% stoppingrule: function handle of the stopping time
% thetav: numeric vector, ground truth vector
% observ: numeric vector, observation vector to be used
% reps: number, which replication we are in, can be used for identifying
%   problems if needed
% nodetails: if 1, does not save the details like prior at every period,
%   only saves what is needed to calculate opportunity and sampling costs
% horizon: number, a large number to stop simulation from running too long
% p: number <= 1, randomization probability if the allocation
%   policy is randomized, negative if non-randomized.
%
% OUTPUTS: 
% results: struct that includes the following
%     results.stoppedatbound if 1, simulation reached t=horizon
%     results.stoppedimm if 1, the simulation stopped at t=0
%     results.mu mean belief when the algorithm stopped
%     results.lastt period in which the algorithm stopped
%     results.thetav ground truth mean
%     results.samcost total sampling cost
%     results.alt alternatives sampled from at each period
%     results.comptime computation time passed
%     
%    if nodetails == 0
%         results.t period we stopped at
%         results.mu mean belief at each period
%         results.sigma covariance belief at each period
%         results.y observations obtained at each period
%
% SUGGESTED WORKFLOW: Used in Func80altTC.m, FuncSec64TC.m
%
%%
    %% Initalize
    % Undiscounted and one sampling cost is zero, avoid running till infinity
    if parameters.delta == 1 && any(parameters.c==0)
        BOUND = 10000;
    else
        BOUND = horizon;
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
    stoppedatbound = 0;
    stoppedimm = 0;

    tic
    while (~stoppingrule(undissoln, dissoln, parameters, mucur, sigmacur, t) && t<BOUND) %as long as stopping rule gives false
    %while (~stoppingrule(undissoln, dissoln, parameters, mucur, sigmacur, t))
         if t == BOUND - 1 %record if stops because we are at the boundary
            stoppedatbound = 1;
            results.alt = alt;
         end
         if parameters.randomps == 1
             if rem(sqrt(t+1),1)==0 %randomly sample once in every perfect square
                i = randi(parameters.M,1,1);
             else
                i = allocationrule(undissoln, dissoln, parameters, mucur, sigmacur ,t ,p); %alternative we will sample from
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
         
        %      if t>BOUND-10 %start to write out as we get close to the boundary
        %         temp = strrep(strsplit(func2str(stoppingrule),{'(',')'},'CollapseDelimiters',true),'Stopping','');
        %         temp = char(temp(3));
        %         sprintf('Stopping rule %s, in rep %d, period %d, sampled %d', temp, reps, t, i)
        %      end
        %      if t>BOUND-1 %record if stops because we are at the boundary
        %         stopped = [stopped, t];
        %      end
    end
    elapsedtime = toc;

    if t == 0 %we stopped immediately
        stoppedimm = 1;
    end

    if nodetails == 0 %if details are wanted, save them
        results.t = time;
        results.mu = muvec;
        results.sigma = sigmavec;
        results.y = yvec;
    end

    results.stoppedatbound = stoppedatbound;
    results.stoppedimm = stoppedimm;
    results.mu{t+1} = muvec{t+1};
    results.lastt = t; %period in which the algorithm stopped
    results.thetav = thetav;
    results.samcost = cost; %total sampling cost
    results.alt = alt; % To compute the ratio of lower vs higher doses

    results.comptime = elapsedtime;
end

