function [ parameters ] = ProblemSetupDoseCaseStudy(priortype, zalpha)
%ProblemSetupDoseCaseStudy 
% PURPOSE: Generates the parameters struct that contains the
% parameters for the dose finding case study problem in Chick, Gans, Yapar (2020)
%
% INPUTS: 
% priortype: 'gpr', 'robust' or 'tilted'
% zalpha: used in robust and tilted priors

% OUTPUTS: 
% parameters: struct, holds the problem parameters

    %% Generate the problem
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
    naturelambdav = naturelambda*ones(M,1);
    
    P = 2000000*0.1; 
    I = zeros(M,1); % zero fixed cost
    c = 8500*ones(M,1);
    delta=1; % undiscounted
    
    %Pilot study details
    runpilot = 1;   
    if runpilot == 1
        lambda = 1; %will be calculated from the pilot
        sigma0 = eye(M); %will be calculated from the pilot
        mu0 = zeros(M,1); %will be calculated from the pilot
        lambdav = lambda*ones(M,1);
        efns = lambdav./diag(sigma0)';
    end
    indicestosample = [1,5,9,13,17];
    N = 10;
    
    %Generate the problem parameters
    list = {'M',M,'efns',efns, 'lambdav',lambdav,'mu0',mu0,'P',P,'I',I,'c',c,'delta',delta,'sigma0',sigma0,'thetav',thetav, ...
        'naturelambdav',naturelambdav, 'runpilot', runpilot, 'doses', doses, 'indicestosample', indicestosample, 'N', N, 'priortype',priortype,...
        'zalpha', zalpha}; 
    [ parameters, ~ ] = SetParametersFunc( list );
end

