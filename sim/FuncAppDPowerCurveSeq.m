function [result,parameters] = FuncAppDPowerCurveSeq( myJobNum, n, r, priorind, expname, nodetails, delta, numofalt, foldername)
%FuncAppDPowerCurveSeq
% PURPOSE: Runs n simulation replications for a given allocation policy and
% stopping time for a problem with a triangular grount truth as in Section D of
% Chick, Gans, Yapar (2020), if fixed stopping time is given, sample size
% is 150
%
% INPUTS: 
% myJobNum: sometimes used for submitting to a server, otherwise any number
%   works
% n: numerical scalar, replication number, effects which pregenerated random
%   number if used
% r: string, name of the allocation policy and stopping time is seperated 
%   by :, ex. 'aCKG:sPDELower', name of policies are defined in
%   DefineRules.m
% priorind: if 1, policy uses independent coviarance matrix
% expname: string, experiment name, used while saving results as .mat files
% nodetails: if 1, does not save the details like prior at every period,
%   only saves what is needed to calculate opportunity and sampling costs
% delta: number, difference between the best and second best arms
% numofalt: odd number, number of alternatives in the problem
% priortype: 'gpr', 'robust' or 'tilted'
% foldername: string, directory for .mat file to be saved
%
% OUTPUTS: Saves a .mat file to the specified directory and generates
% following two variables
% result: struct that includes simulation results and summary statistics (see
%   SimOneRepFullPolicyHelper.m for simulation result details and 
%   SimulationSummary.m for summary statistics)
% parameters: struct that includes the problem parameters
%
% WORKFLOW: Called in SimforAppD1.m

%%
    %% Initilization work
    % needed for the server
    addpath(genpath(kgcbfolder),genpath(pdecodefolder),genpath(pdecorrfolder));
    
    % load standardized solution files
    PDELocalInit;
    [cgSoln, cfSoln, ~, ~] = PDELoadSolnFiles(strcat(pdecode, 'Matfiles/'), false); %needed everytime - load solution files
    
    %Defines rules
    DefineRules;

    %Policy, turn strings to functions
    C = strsplit(r,':');
    rules{1} = eval(C{1});
    rules{2} = eval(C{2});
    
    %% Problem parameters
    %triangular truth curve, assumes number of alternatives is odd
    M = numofalt;
    thetav = zeros(1,M);
    for i = 1:(M-1)/2
        thetav((M+1)/2+i) = thetav((M+1)/2)-i*delta;
        thetav((M+1)/2-i) = thetav((M+1)/2)-i*delta;
    end
    thetav = thetav'*2000;
    naturelambda = 4.5*(2000^2);
    naturelambdav = naturelambda*ones(1,M);
    lambda = 4.5*(2000^2);
    lambdav = lambda*ones(1,M);
    P = 2000000*0.1; 
    I = zeros(M,1); % zero fixed cost
    c = 8500*ones(1,M);
    delta=1; % undiscounted
    Tfixed = 150;

    %Define the modeler's prior on thetas
    alphaval = 16;
    efns = 0.1;
    beta0 = lambda/efns;
    %This method creates a non-positive semidefinite matrix for M.
    %Therefore, I use PowExpCov from matlabKG code. Both method give the same
    %results for M=20, but PowExpCov is more accurate as M gets larger.
%     alpha0 = alphaval/(M-1)^2;
%     for i=1:M
%         for j=1:M
%             sigma0(i,j) = beta0*exp(-alpha0*(i-j)^2);
%         end
%     end
    [sigma0,~] = PowExpCov(beta0,(M-1)/sqrt(alphaval),2,M,1);
    mu0 = zeros(M,1) + sqrt(sigma0((M+1)/2,(M+1)/2));

    if priorind ==1
        sigma0 = diag(diag(sigma0));
    end

    %Simulation details and generate the problem parameters
    pdetieoption = 'kgstar';
    list = {'M',M,'efns',lambdav./diag(sigma0)', 'lambdav',lambdav,'mu0',mu0,'P',P,'I',I,'c',c,'delta',delta,'sigma0',sigma0,'thetav',thetav, 'naturelambdav',naturelambdav,'Tfixed',Tfixed,'pdetieoption',pdetieoption, 'randomps', 0};
    [ parameters, rval ] = SetParametersFunc( list );
    
    %% Run n simulation for one replication
    NUMOFREPS = n; %Number of replications per rule
    for i=1:NUMOFREPS %For number of replications, run simulation
        rng(parameters.seed(i),'twister');
        thetavalue = TrueMeanCreator( parameters, i); %actual mean value
        if(parameters.crn==1)
            observ = parameters.observ(:,:,i); %observation for ith replication
        else
            observ = [];
        end
        [ result.rule(1).detailed(i)] = SimOneRepFullPolicyHelper( cfSoln, cgSoln, parameters, rules{1}, rules{2}, thetavalue, observ, i, nodetails, 3000, 0);
    end
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
    result.nofreps = NUMOFREPS;
    result.nofrules = 1;
    
    %%%%%%%%% Summary variables %%%%%%%%
    result = SimulationSummary(result);
    result = rmfield(result.rule,'detailed');
    
    %%%%%%%%% Save simulation details to a file %%%%%%%%
    if  ~strcmpi(expname,'deneme') 
        mymat = strcat(foldername,expname,'.mat'); %file name includes analysis date and time and number of replications and experiment name given
        save(mymat,'result');
    end
end