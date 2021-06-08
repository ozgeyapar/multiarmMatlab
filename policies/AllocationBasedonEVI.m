function [ i ] = AllocationBasedonEVI( evicalc, ispdeused, parameters, muin, sigmain, randtype, randprob)
%AllocationBasedonEVI
% PURPOSE: Takes the EVI approximations as an input and returns an arm
% to be sampled from.
%
% INPUTS: 
% evicalc: approximated EVi values for each arm
% ispdeused: if EVI calculation uses a pde-based approximation, a different
%   tiebreaking is used when all EVIs are non-positive
% parameters: struct, problem parameters are included as fields
% muin: numerical vector that contains the prior mean vector
% sigmain: numerical matrix that contains the prior covariance matrix
% randtype: randomization type, 1 for uniform, 2 for TTVS
% randprob: randomization probability
%
% OUTPUTS: 
% i: index of the arm to be sampled
%

%%
    % When the policy is called within a simulation, these values are passed
    % This is to make sure that the allocation policies work when they are
    % called standalone
    if (~isfield(parameters, 'randomizeornot'))
        value = rand;
    else
        value = parameters.randomizeornot;
    end
    if (~isfield(parameters, 'randomizedarm'))
        armtosample = randi(parameters.M);
    else
        armtosample = parameters.randomizedarm;
    end
    % if the uniform distribution generates something below randprob, randomize
    if value <= randprob && randtype == 1 %%Uniform
        [ i ] = armtosample;
    elseif value <= randprob && randtype == 2 % TTVS
        if all(evicalc<=0) && ispdeused == 1 %if stopping version of pde-based policy wants to stop
            i = AllocationTieBreaker( parameters, 1:parameters.M,  muin, sigmain, parameters.pdetieoption);
        else
            [~,indmax] = max(evicalc);
            evicalc(indmax) = -Inf;
            [evimax2, i] = max(evicalc);
            idx = find(evicalc == evimax2);   
            if size(idx,2) > 1 %tied for a positive number, use regular tiebreaking
                i = AllocationTieBreaker( parameters, idx,  muin, sigmain, parameters.tieoption);
            end
        end
    else
        if all(evicalc<=0) && ispdeused == 1  %if stopping version of pde-based policy wants to stop
            i = AllocationTieBreaker( parameters, 1:parameters.M,  muin, sigmain, parameters.pdetieoption);
        else
            [evimax,i] = max(evicalc);
            idx = find(evicalc == evimax);   
            if size(idx,2) > 1 %tied for a positive number, use regular tiebreaking
                i = AllocationTieBreaker( parameters, idx,  muin, sigmain, parameters.tieoption);
            end
        end
    end

end
