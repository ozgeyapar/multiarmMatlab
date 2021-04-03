function [result,parameters] = FuncSec64TC( myJobNum, n, r, priorind, expname, nodetails, priortype, matlocfile, initialrepnum, foldername, Tfixed, zalpha, graphforprior)
%FuncSec64TC
% PURPOSE: Runs one simulation replication for a given allocation policy 
% and a given stopping time for the problem in Section 6.4 of 
% Chick, Gans, Yapar (2020) and saves the results to a .mat file.
% 
% INPUTS: 
% myJobNum: used for submitting to the server, any number works
% n: numerical scalar, replication number, effects which pregenerated random
%   number if used
% r: string, name of the allocation policy and stopping time is seperated 
%   by :, ex. 'aCKG:sPDELower', name of policies are defined in
%   DefineRules.m
% priorind: if 1, policy uses independent coviarance matrix
% expname: string, experiment name, used while saving results as .mat files
% nodetails: if 1, does not save the details like prior at every period,
%   only saves what is needed to calculate opportunity and sampling costs
% priortype: 'gpr', 'robust' or 'tilted'
% matlocfile: string, the folder in which pregenerated random variables 
%   are saved, ex. 'variables' 
% initialrepnum: number, runs replcations initialrepnum to initialrepnum+1000
% foldername: string, directory for .mat file to be saved
% Tfixed: number, fixed sample size for fixed stopping time
% zalpha: number, z used in robust and tilted priors, 1/2 by default
% graphforprior: if graphforprior is 1, a figure for the
%   prior for this sample path is generated, 0 by default
%
% OUTPUTS: Saves a .mat file to the specified directory and generates
% following two variables
% result: struct that includes simulation results (see
%   SimOneRepFullPolicyHelper.m for its details)
% parameters: struct that includes the problem parameters
%
% SUGGESTED WORKFLOW: See GenerateFig2.m for 
% examples.
%
%%
    %% Initilization work
    % If some arguments are not given
    if nargin <= 10
        if strcmp(priortype, 'gpr')
            Tfixed = 750;
        elseif strcmp(priortype, 'robust')
            Tfixed = 1100;
        elseif strcmp(priortype, 'tilted')
            Tfixed = 1100;
        end
        graphforprior = 0;
        zalpha = 1/2;
    elseif nargin <= 11
        graphforprior = 0;
        zalpha = 1/2;
    end

    SetPaths
    addpath(genpath(kgcbfolder),genpath(pdecodefolder),genpath(pdecorrfolder));
    
    % load standardized solution files
    PDELocalInit;
    [cgSoln, cfSoln, ~, ~] = PDELoadSolnFiles(PDEmatfilebase, false); %load solution files
    
    %Defines rules
    DefineRules;

    %Policy, turn strings to functions
    C = strsplit(r,':');
    rules{1} = eval(C{1});
    rules{2} = eval(C{2});

    %% Problem parameters
    % True theta is efficacy minus toxicity
    M = 17;
    doses = 0:0.5:8; %control
    EasympL = 4500;
    ED50 = 4;
    Esteepk = 2;	
    %Esubtract = 2.68;

    TasympL = -7000;
    TD50 = 8;
    Tsteepk = 1.5;
    %Tsubtract = -2.68;
    %lintrend = 30;

    Evalue = EasympL./(1+exp(-Esteepk*(doses-ED50)));
    Tvalue = TasympL./(1+exp(-Tsteepk*(doses-TD50)));
    thetav = Evalue + Tvalue;
    
    naturelambda = 4.5*(2000^2);
    naturelambdav = naturelambda*ones(1,M);
    
    P = 2000000*0.1; 
    I = zeros(M,1); % zero fixed cost
    c = 8500*ones(1,M);
    delta=1; % undiscounted

    %% Parameters for pilot
    indicestosample = [1,5,9,13,17];
    N = 10;
    
    samplingparameters.doses = doses;
    samplingparameters.indicestosample = indicestosample;
    samplingparameters.N = N;
    samplingparameters.priortype = priortype;
    samplingparameters.priorind = priorind;
    samplingparameters.graphforprior = graphforprior;
    samplingparameters.zalpha = zalpha;
    lambda = 1; %will be calculated from the pilot
    sigma0 = eye(M); %will be calculated from the pilot
    mu0 = zeros(M,1); %will be calculated from the pilot
    lambdav = lambda*ones(1,M);
    efns = lambdav./diag(sigma0)';
    
    %Simulation details and generate the problem parameters
    pdetieoption = 'kgstar';
    list = {'M',M,'efns',efns, 'lambdav',lambdav,'mu0',mu0,'P',P,'I',I,'c',c,'delta',delta,'sigma0',sigma0,'thetav',thetav, 'naturelambdav',naturelambdav,'Tfixed',Tfixed,'sampleeach',1,'pdetieoption',pdetieoption, 'matlocfile', matlocfile, 'randomps', 0};
    [ parameters, ~ ] = SetParametersFunc( list );
    
    %% Run the simulation for one replication
    parameters.initialrepnum = initialrepnum; %if want to run more than 1000 replications with crn
    parameters.repnum = n;
    parameters.expname = expname;
    REPNUM = parameters.initialrepnum + n;

    i = n;
    rng(parameters.seed(i),'twister');
    [ parameters.mu0, parameters.sigma0, parameters.lambdav, parameters.efns, parameters.pilotdetails ] = SimPilotandDetPriorSec64( parameters, samplingparameters, i);
    thetavalue = TrueMeanCreator( parameters, i); %actual mean value
    if(parameters.crn==1)
        observ = parameters.observ(:,:,i); %observation for ith replication
    else
        observ = [];
    end
    [ result.rule(1).detailed] = SimOneRepFullPolicyHelper( cfSoln, cgSoln, parameters, rules{1}, rules{2}, thetavalue, observ, i, nodetails, 10000, 0);
    result.rule(1).allrule = AssignRuleNames(func2str(rules{1}),1,parameters); %Allocation rule
    result.rule(1).stoprule = AssignRuleNames(func2str(rules{2}),2,parameters); %Stopping rule

    if isfield(parameters, 'seed')
        parameters = rmfield(parameters,'seed');
    end
    if isfield(parameters, 'observ')
        parameters = rmfield(parameters,'observ');
    end
    if isfield(parameters, 'thetamat')
        parameters = rmfield(parameters,'thetamat');
    end
    if isfield(parameters, 'doserespv')
        parameters = rmfield(parameters,'doserespv');
    end
    result.parameters = parameters;
    result.nofreps = REPNUM;
    result.nofrules = 1;
    
    %%Save simulation details to a file
    if  ~strcmpi(expname,'deneme') 
        mymat = strcat(foldername,expname,'-repnum-',num2str(REPNUM),'.mat'); 
        save(mymat,'result');
    end

end