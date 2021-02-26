function [result,parameters] = Func80altOC( myJobNum, n, r, names, priorind, Tfixed, expname, alphaval, stdev, patientsv, p, foldername)
%Func80altOC
% PURPOSE: Runs one simulation replication for a given allocation policy 
% with a given fixed sample size for the problem in Section 6.2 of 
% Chick, Gans, Yapar (2020) and saves the results to a .mat file.
%
% INPUTS: 
% myJobNum: used for submitting to the server, any number works
% n: numerical scalar, replication number, effects which pregenerated random
%   number if used
% r: string, name of the allocation policy to be run, as defined in 
%   DefineRules.m, ex. 'aPDELower', 'Equal'
% names: string cell array, name of the policy, ex. {'cPDELower', 'Equal'}
% priorind: if 1, policy uses independent coviarance matrix
% Tfixed: number, fixed sample size
% expname: string, experiment name, used while saving results as .mat files
% alphaval: number, determines zeta = alphaval/(M-1)^2
% stdev: number, sampling standard deviation sqrt(lambda)
% costv: sampling cost is 10^(costv)
% patientsv: number, determines population size, P = 10^patientsv
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
    %% Initilization work
    % needed for the server
    addpath(genpath(kgcbfolder),genpath(pdecodefolder),genpath(pdecorrfolder));
    
    % load standardized solution files
    PDELocalInit;
    [cgSoln, cfSoln, cgOn, cfOn] = PDELoadSolnFiles(strcat(pdecode, 'Matfiles/'), false); %needed everytime - load solution files
    
    %Defines rules
    DefineRules;

    % Policy, turn string to function
    rules = eval(r);

    %% Problem parameters
    M = 80;
    P = 10^patientsv;
    I = zeros(M,1); %zero fixed cost
    c = 1*ones(1,M);
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
    
    %Define the nature's prior on theta
    rpimu0=mu0;
    rpisigma0 = sigma0;
    
    %Simulation details and generate the problem parameters
    pdetieoption = 'kgstar';
    list = {'M',M,'efns',lambdav./diag(sigma0)', 'lambdav',lambdav,'mu0',mu0,'P',P,'I',I,'c',c,'delta',delta,'sigma0',sigma0,'rpisigma0',rpisigma0,'rpimu0',rpimu0,'pdetieoption',pdetieoption, 'randomps', 0};
    %list = {'M',M,'rho',rho,'efns',efns, 'lambdav',lambdav,'mu0',mu0,'P',P,'I',I,'c',c,'delta',delta,'Tfixed',Tfixed,'sigma0',sigma0,'thetav',thetav};
    [ parameters, ~ ] = SetParametersFunc( list );

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
        parameters.sigma0 = diag(diag(parameters.sigma0));
    else
        [parameters.sigma0,~] = PowExpCov(beta0,(M-1)/sqrt(alphaval),2,M,1);
    end
    [ result.rule(1).detailed(i) ] = SimOneRepAllocHelper( cfSoln, cgSoln, parameters, rules, thetavalue, observ, Tfixed, p);
    if p <= 0 %No randomization
        result.rule(1).allrule = strcat(AssignRuleNames(func2str(rules),1,parameters)); %Allocation rule
    else
        result.rule(1).allrule = strcat(AssignRuleNames(func2str(rules),1,parameters), '-p', num2str(p)); %Allocation rule
    end
    if isfield(parameters, 'seed')
        parameters = rmfield(parameters,'seed');
    end
    if isfield(parameters, 'observ')
        parameters = rmfield(parameters,'observ');
    end
    if isfield(parameters, 'thetamat')
        parameters = rmfield(parameters,'thetamat');
    end
    result.rule(1).parameters = parameters;

    result.repnum = i;
    result.nofrules = 1;

    %% Save simulation details to a file
    if  ~strcmpi(expname,'deneme') 
        mymat = strcat(foldername, expname,'-', names{1},'-repnum-',num2str(i),'.mat');
        X = result.rule(1);
        save(mymat,'X'); 
    end

end