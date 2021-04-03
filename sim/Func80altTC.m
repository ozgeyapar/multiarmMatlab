function [result,parameters] = Func80altTC( myJobNum, n, r, alphaval, stdev, priorind, expname, nodetails, costv, pv, matlocfile, initialrepnum, foldername, Tfixed)
%Func80altTC
% PURPOSE: Runs one simulation replication for a given allocation policy 
% with given stopping time for the problem in Section 6.3 of 
% Chick, Gans, Yapar (2020) and saves the results to a .mat file.
%
% INPUTS: 
% myJobNum: used for submitting to the server, any number works
% n: numerical scalar, replication number, effects which pregenerated random
%   number if used
% r: string, name of the allocation policy and stopping time is seperated 
%   by :, ex. 'aCKG:sPDELower', name of policies are defined in
%   DefineRules.m
% alphaval: number, determines zeta = alphaval/(M-1)^2
% stdev: number, sampling standard deviation sqrt(lambda)
% priorind: if 1, policy uses independent coviarance matrix
% expname: string, experiment name, used while saving results as .mat files
% nodetails: if 1, does not save the details like prior at every period,
%   only saves what is needed to calculate opportunity and sampling costs
% costv: sampling cost is 10^(costv)
% pv: number, determines population size, P = 10^pv
% matlocfile: string, the folder in which pregenerated random variables 
%   are saved, ex. 'variables' 
% initialrepnum: number, runs replcations initialrepnum to initialrepnum+1000
% foldername: string, directory for .mat file to be saved
% Tfixed: number, fixed sample size for fixed stopping time
%
% OUTPUTS: Saves a .mat file to the specified directory and generates
% following two variables
% result: struct that includes simulation results (see
%   SimOneRepFullPolicyHelper.m for its details)
% parameters: struct that includes the problem parameters
%
% SUGGESTED WORKFLOW: See SimforTab1.m and SimforTabEC2.m for
% examples.
%
%%
    %% Initilization work
    % if input for Tfixed is not given
    if nargin <= 13
        Tfixed = 100;
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
    M = 80;
    P = 10^pv;
    I = zeros(M,1); % zero fixed cost
    c = (10^costv)*ones(1,M);
    delta=1; % undiscounted
    lambdav = (stdev^2)*ones(1,M);
    
    %Define the modeler's prior on thetas
    mu0=zeros(M,1);
    alphaval = alphaval;
    %alpha0 = alphaval/(M-1)^2;
    beta0 = 1/2;
    %This method creates a non-positive semidefinite matrix for M=80.
    %Therefore, I use PowExpCov from matlabKG code. Both method give the same
    %results for M=20, but PowExpCov is more accurate as M gets larger.
    % for i=1:M
    %     for j=1:M
    %         sigma0(i,j) = beta0*exp(-alpha0*(i-j)^2);
    %     end
    % end
    [sigma0,~] = PowExpCov(beta0,(M-1)/sqrt(alphaval),2,M,1);

    %Define the nature's prior on
    rpimu0=mu0;
    rpisigma0 = sigma0;

    if priorind ==1
        sigma0 = diag(diag(sigma0));
    end
    
    %Simulation details and generate the problem parameters
    pdetieoption = 'kgstar';
    list = {'Tfixed',Tfixed','M',M,'efns',lambdav./diag(sigma0)', 'lambdav',lambdav,'mu0',mu0,'P',P,'I',I,'c',c,'delta',delta,'sigma0',sigma0,'rpisigma0',rpisigma0,'rpimu0',rpimu0,'pdetieoption',pdetieoption, 'matlocfile', matlocfile, 'randomps', 0};
    %list = {'M',M,'rho',rho,'efns',efns, 'lambdav',lambdav,'mu0',mu0,'P',P,'I',I,'c',c,'delta',delta,'Tfixed',Tfixed,'sigma0',sigma0,'thetav',thetav};
    [ parameters, ~ ] = SetParametersFunc( list );
    
    %% Run the simulation for one replication
    parameters.initialrepnum = initialrepnum;
    parameters.expname = expname;
    REPNUM = parameters.initialrepnum + n; %Number of replications per rule

    i = n;
    rng(parameters.seed(i),'twister');
    thetavalue = TrueMeanCreator( parameters, i); %actual mean value
    if(parameters.crn==1)
        observ = parameters.observ(:,:,i); %observation for ith replication
    else
        observ = [];
    end
    [ result.rule(1).detailed] = SimOneRepFullPolicyHelper( cfSoln, cgSoln, parameters, rules{1}, rules{2}, thetavalue, observ, i, nodetails, 3000, 0);
    result.rule(1).allrule = AssignRuleNames(func2str(rules{1}),1,parameters); %Allocation rule
    result.rule(1).stoprule = AssignRuleNames(func2str(rules{2}),2,parameters); %Stopping rule

    if(isfield(parameters, 'observ'))
        parameters = rmfield(parameters,'observ');
    end
    if(isfield(parameters, 'thetamat'))
        parameters = rmfield(parameters,'thetamat');
    end
    if(isfield(parameters, 'seed'))
        parameters = rmfield(parameters,'seed');
    end
    if isfield(parameters, 'doserespv')
        parameters = rmfield(parameters,'doserespv');
    end
    result.parameters = parameters;
    result.repnum = REPNUM;
    result.nofrules = 1;
    
    %%Save simulation details to a file
    if  ~strcmpi(expname,'deneme') 
        mymat = strcat(foldername,expname,'-','repnum-',num2str(REPNUM),'.mat');
        save(mymat,'result');
    end
end