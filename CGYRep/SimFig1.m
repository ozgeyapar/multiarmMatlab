function [ results ] = SimFig1( cgSoln, cfSoln, NUMOFREPS, policies, priorind, rand, alphaval, pval, Tfixed, foldertosave )
%SimFig1 Runs the simulation replications and saves the SC, OC and TC 
% values to a struct for Figure 1 in the paper.
    %% Generate the problem
    M = 80;
    P = 10^pval;
    I = zeros(M,1); %zero fixed cost
    c = 1*ones(1,M);
    delta=1; % undiscounted
    lambdav = (0.01^2)*ones(1,M);
 
    %Define the modeler's prior on thetas
    mu0=zeros(M,1);
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
    
    %% Directory to save
    CheckandCreateDir( foldertosave )
    
    %% Policies to be tested
    %Defines rules
    DefineRules;

    % Policy, turn string to function
    C = strsplit(policies,':');
    policyfuncs = cell(size(C,2));
    for i=1:size(C,2)
        policyfuncs{i,1} = eval(C{i});
    end 
    NUMOFPOL = length(policyfuncs(:,1)); %Number of policies to compute
    
    %% Run simulations for each allocation policy
    for j = 1:NUMOFPOL %For each allocation policy
            results.policy(j).allrule = AssignPolicyNames(func2str(policyfuncs{j}),1,rand(j),Tfixed); %Allocation rule
        for n = 1:NUMOFREPS
            [results.policy(j).detailed(n)] = FuncOCSim( cfSoln, cgSoln, n, policyfuncs{j},  priorind(j), Tfixed, parameters, rand(j));
        end
    end

    results.nofreps = NUMOFREPS;
    results.nofpols = NUMOFPOL;
end

