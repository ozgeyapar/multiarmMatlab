function [ result ] = SimulationSummary( result )
%SimulationSummary
% PURPOSE: Calculates the summary statistics across multiple simulation
%  replications
%
% INPUTS: 
% result: a stuct that contains the simulation replication results
%
% OUTPUTS: 
% result: a stuct that contains the simulation replication results and
% following summary statistics 
%     result.rule(j).expsamcost expected sampling cost
%     result.rule(j).seSC standard error of expected sampling cost
%     result.rule(j).expOC expected opportunity cost
%     result.rule(j).seOC standard error of expected opportunity cost
%     result.rule(j).exptotalcost expected total cost
%     result.rule(j).vartotalcost standard error of expected total cost
%     result.rule(j).PCS probability of correct selection 
%     result.rule(j).totalcomptime total time used for computation
%     result.rule(j).lastt average sample size
%     result.rule(j).expreward expected reward
%     result.rule(j).seR standard error of expected reward
%     result.rule(j).EVPI expected calue of perfect information
%
% SUGGESTED WORKFLOW: Used MergeReplicationsEC2.m, 
%   MergeReplicationsforTab1.m, MergeReplicationsforTab2.m, 
%   FuncAppDPowerCurveSeq.m
%
%%
for j = 1:result.nofrules %For each rule pair
    for i=1:result.nofreps %For number of replications
        %select the alternative with the maximum mean
        if size(result.rule(j).detailed(i).thetav, 2) ~= 1 %make sure that theta is a column array
            result.rule(j).detailed(i).thetav = result.rule(j).detailed(i).thetav';
        end
        [~,result.rule(j).detailed(i).sel] = max(result.parameters.P*result.rule(j).detailed(i).mu{result.rule(j).detailed(i).lastt+1}-result.parameters.I);
        selected = result.rule(j).detailed(i).thetav(result.rule(j).detailed(i).sel);
        %actual best theta
        [~,best] = max(result.parameters.P*result.rule(j).detailed(i).thetav-result.parameters.I);
        bestvalue = result.rule(j).detailed(i).thetav(best);
        %opportunity cost
        result.rule(j).detailed(i).OC = result.parameters.P*(bestvalue - selected) -result.parameters.I(best) + result.parameters.I(result.rule(j).detailed(i).sel);
        %total cost
        result.rule(j).detailed(i).TC = result.rule(j).detailed(i).samcost + result.rule(j).detailed(i).OC;
        %reward
        result.rule(j).detailed(i).reward = -result.rule(j).detailed(i).samcost + result.parameters.P*selected-result.parameters.I(result.rule(j).detailed(i).sel);
        %correct selection
        result.rule(j).detailed(i).CS = (result.rule(j).detailed(i).sel == best); 
        %perfect info
        result.rule(j).detailed(i).PI = result.parameters.P*bestvalue-result.parameters.I(best);
    end
    % Expectation and standard error of the mean
    result.rule(j).expsamcost = mean([result.rule(j).detailed.samcost]); %Sampling cost
    result.rule(j).seSC = std([result.rule(j).detailed.samcost])/sqrt(result.nofreps);
    result.rule(j).expOC = mean([result.rule(j).detailed.OC]); %Opportunity cost
    result.rule(j).seOC = std([result.rule(j).detailed.OC])/sqrt(result.nofreps);
    result.rule(j).exptotalcost = mean([result.rule(j).detailed.TC]); %Sum of sampling and opportunity cost
    result.rule(j).vartotalcost = std([result.rule(j).detailed.TC])/sqrt(result.nofreps);
    result.rule(j).PCS = sum([result.rule(j).detailed.CS])/result.nofreps; %probability of correct selection 
    result.rule(j).totalcomptime = sum([result.rule(j).detailed.comptime]); %total time required for computation
    result.rule(j).lastt = mean([result.rule(j).detailed.lastt]); %average length before stopping
    result.rule(j).expreward = mean([result.rule(j).detailed.reward]); %Reward
    result.rule(j).seR = std([result.rule(j).detailed.reward])/sqrt(result.nofreps);
    result.rule(j).EVPI = mean([result.rule(j).detailed.PI]); %Expected Value of Perfect Information
end

end

