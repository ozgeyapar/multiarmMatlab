function [result] = FuncOCSim( cfSoln, cgSoln, n, allpolicy, priorind, Tfixed, parameters, p)
%FuncOCSim
% PURPOSE: Runs one simulation replication for a given allocation policy 
% with a given fixed sample size and saves the results to a .mat file.
%
% INPUTS: 
% n: numerical scalar, replication number, effects which pregenerated random
%   number if used
% r: string, name of the allocation policy to be run, as defined in 
%   DefineRules.m, ex. 'aPDELower', 'Equal'
% names: string cell array, name of the policy, ex. {'cPDELower', 'Equal'}
% priorind: if 1, policy uses independent coviarance matrix
% Tfixed: number, fixed sample size
% expname: string, experiment name, used while saving results as .mat files
% parameters: struct, holds the problem parameters
% p: number <= 1, randomization probability if the allocation
%   policy is randomized, negative if non-randomized.
% foldername: string, directory for .mat file to be saved
%
% OUTPUTS: Saves a .mat file to the specified directory and generates
% following two variables
% result: struct that includes simulation results (see
%   SimOneRepAllocHelper.m for its details)
% parameters: struct that includes the problem parameters
%
% SUGGESTED WORKFLOW: See SimforFig1.m and SimforFig4.m for
% examples.
%
%%
    %% Run the simulation for one replication
    i = n; %Which replication to run
    rng(parameters.seed(i),'twister');
    thetavalue = TrueMeanCreator( parameters, i); %actual mean value
    if(parameters.crn==1)
        observ = parameters.observ(:,:,i); %observation for ith replication
    else
        observ = [];
    end
    if priorind == 1
        % Use independent prior 
        parameters.sigma0 = diag(diag(parameters.sigma0));
    end
    [ result ] = SimOneRepAllocHelper( cfSoln, cgSoln, parameters, allpolicy, thetavalue, observ, Tfixed, p);

end