function [ results ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings)
%SimSetupandRunFunc 
% PURPOSE: Runs the simulation replications for a given problem
%
% INPUTS: 
% cfSoln: variable which contains the standardized solution
%   for undiscounted problem.
% cgSoln: variable which contains the standardized solution
%   for discounted problem. 
% parameters: struct, holds the problem parameters
% policies: a string that holds policy pairs to be tested, seperated by :
% rtype: randomization type for each allocation policy
% rprob: randomization probability for each allocation policy
% Tfixed: fixed stopping time for each stopping policy (used if stopping 
%   policy is fixed).
% settings: struct of simulation settings such as bound, crn etc.
%
% OUTPUTS: 
% result: struct that includes simulation results

    %% Initilization
    NUMOFREPS = settings.NUMOFREPS;
    filename = settings.filename; 
    foldertosave = settings.foldertosave;
   
    %% Policies to be tested
    %Defines rules
    DefineRules;

    % Policy, turn string to function
    C = strsplit(policies,':');
    policyfuncs = cell(size(C,2)/2,2);
    for i=1:size(C,2)/2
        policyfuncs{i,1} = eval(C{2*i-1});
        policyfuncs{i,2} = eval(C{2*i});
    end 
    NUMOFPOL = length(policyfuncs(:,1)); %Number of policies to compute
    
    %% Run simulations for each policy
    for j = 1:NUMOFPOL 
        results.policy(j).allrule = AssignPolicyNames(func2str(policyfuncs{j,1}), 1, rtype(j), rprob(j), Tfixed(j)); %Allocation rule
        results.policy(j).stoprule = AssignPolicyNames(func2str(policyfuncs{j,2}), 2, rtype(j), rprob(j), Tfixed(j)); %Stopping rule
    end
    [thetastream,noisestream,pilotstream,randstream, tiestream] = RandStream.create('mrg32k3a','NumStreams',5,'Seed', settings.seed);
    for n = 1:NUMOFREPS
        % Generate random variables to be used in simulation run for CRN
        % CRN or not for observation noise
        if settings.crn == 1 
            stdnoise = randn(noisestream,parameters.M,settings.BOUND);
        else
            stdnoise = [];
        end

        % CRN or not for true means (thetas)
        if settings.crn == 1 && (isscalar(parameters.thetav) && parameters.thetav == -1)
            stdtheta = randn(thetastream,parameters.M,1); 
        else
            stdtheta = [];
        end

        % CRN or not for pilot study observations
        if settings.crn == 1 && parameters.runpilot == 1
            stdpilot = randn(pilotstream,2*parameters.N, size(parameters.indicestosample,2)); 
        else
            stdpilot = [];
        end
        
        % CRN or not for randomized allocation rules
        if settings.crn == 1 && any(rprob > 0) && any(rprob < 1)
            stdrand = rand(randstream,settings.BOUND,1); 
        else
            stdrand = [];
        end
        
        % Generate the actual means
        thetav = TrueThetaCreator( parameters, stdtheta, settings.crn); %actual thetas
        
        %Run pilot to get the prior and sampling variance
        if parameters.runpilot == 1
            [ parameters.mu0, parameters.sigma0, parameters.lambdav, parameters.efns, parameters.pilotdetails ] = SimPilotandDetPrior( parameters, stdpilot, thetav);
        end
        RandStream.setGlobalStream(tiestream)
        
        for  j = 1:NUMOFPOL
            [results.policy(j).detailed(n)] = SimulationFunc( cfSoln, cgSoln, policyfuncs{j,1}, policyfuncs{j,2}, rtype(j), rprob(j), Tfixed(j), parameters, thetav, stdnoise, stdrand, settings);
        end
    end
    results.nofreps = NUMOFREPS;
    results.nofpols = NUMOFPOL;
    results.parameters = parameters;
    
    %% Directory to save
    if foldertosave ~= -1
        CheckandCreateDir( foldertosave )
        save(strcat(foldertosave, filename), 'results')
    end
end

