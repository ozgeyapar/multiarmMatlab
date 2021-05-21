% ReplicateCGY.m:
% PURPOSE: A macro with the code required to generate the figures and tables
% for correlated multiarm paper (Chick, Gans, Yapar (2020)).
%
% Here is the list of allocation and stopping policies that can be tested
% with the names to call them
% aPDEUpper: cPDEUpper allocation policy with optimized alphas
% aPDEUpperNO: cPDEUpper allocation policy with equal alphas
% aPDELower: cPDELower allocation policy
% aVar: Allocation policy based on variance of each arm
% aCKGstar: cKGstar allocation policy
% aCKG: cKG1 allocation policy
% aESPb: ESPb allocation policy
% aESPB: ESPB allocation policy
% aEqual: Equal (round-robin) allocation policy
% aPDE: cPDE allocation policy
% aRandom: Random allocation policy
% 
% sPDEUpper: cPDEUpper stopping policy with optimized alphas
% sPDEUpperNO: cPDEUpper stopping policy with equal alphas
% sPDELower: cPDELower stopping policy
% sfixed: Fixed stopping policy
% sCKGstar: cKGstar stopping policy
% sCKG: cKG1 stopping policy
% sESPb: ESPb stopping policy
% sPDE: cPDE stopping policy
% sPDEHeu: cPDE heuristic stopping policy, uses cPDELower and cPDEUpper for faster computation

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% INITIALIZATION
%%% Set directories
SetPaths

%%% Load Standard Solutions
PDELocalInit;
[cgSoln, cfSoln, ~, ~] = PDELoadSolnFiles(PDEmatfilebase, false); %load solution files

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GLOBAL PARAMETERS %%%

% Simulation details: Settings that can be edited by end-user. 
DOPAPER = true; % Set to TRUE to get figures/graphs for paper, FALSE to get sample runs with simpler graphs
DOHIREPS = false; % Set to TRUE to get lots of replications, FALSE to get small number of reps for testing
    CGYHIREPS = 10; % was 1000 for final paper. can set lower for testing.
    CGYLOWREPS = 5; % small number of replications so runs don't take too long - for debug or checking install
DOSAVEFILES = true; % set to true to save results and figures to file, FALSE if files are not to be saved. 
    %if saved, need to set foldertosave and filename fields of the settings
    %field as denoted below, e.g. settings.foldertosave = strcat(pdecorr,
    %'Outputs\') settings.filename = 'myfigs'.

if DOHIREPS
    settings.NUMOFREPS = CGYHIREPS; % high number of replications for more accurate graphs - 1000 was used for paper
else
    settings.NUMOFREPS = CGYLOWREPS; % low number of replications, for testing purposes.
end
if DOSAVEFILES
    settings.foldertosave = strcat(pdecorr, 'Outputs\');
    settings.filename = 'demo'; %name of the figure file if it will be saved
else
    settings.foldertosave = -1; % folder path to save results and figures, -1 to not save, example to save: strcat(pdecorr, 'Outputs\')
    settings.filename = ''; %name of the figure file if it will be saved
end
settings.crn = 1; %1 if crn is implemented, 0 otherwise
settings.seed = 487429276; % seed to be used for random number generation
settings.BOUND = 10000; %Maximum number of periods the simulation goes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CHUNK 1: Policies to test

%% Comparing allocation policies with 80 arm problem
%Problem parameters  
M = 80;
alphaval = 100; %for alpha = alphaval/(M-1)^2
pval = 6; %for P = 10^pval

if ~DOPAPER
    %%%  Policies to test: a sequence of allocation rule/stopping rule
    %%%  combinations - in the following - there are 4 policies, each with
    %%%  fixed sample size stopping rule
    policies = 'aEqual:sfixed:aCKG:sfixed:aPDELower:sfixed:aPDELower:sfixed'; % Policies to include
    rprob = [-1, -1, 0.2, -1]; % randomization probability, negative if deterministic
    rtype = [0, 0, 1, 0]; %0 for nonrandomized, 1 for uniform, 2 for TTVS
    Tfixed = 20*ones(1,4);%[2,2,2,2]; %period to stop for fixed stopping policy, 0 if another stopping policy is used
    if DOSAVEFILES
        settings.foldertosave = strcat(pdecorr, 'Outputs\');
        settings.filename = strcat('test-P',num2str(pval),'-alpha',num2str(alphaval)); %name of the figure file if it will be saved
    else
        settings.foldertosave = -1; % folder path to save results and figures, -1 to not save, example to save: strcat(pdecorr, 'Outputs\')
        settings.filename = ''; %name of the figure file if it will be saved
    end

    %%% Run simulation analysis
    startt = tic;
    [ parameters ] = ProblemSetupSynthetic( M, alphaval, pval);
    [ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
    %%% Generating a figure to compare allocation policies
    GenerateOCFig(simresults, settings.foldertosave, settings.filename, 0);
    %%% Calculate CI at a given t
    givent = 2;
    [meandOC, sedOCa] = CalculateCIofOC( simresults, givent );
    toc(startt)
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CHUNK 2: FIGURE 1 of SECTION 6.2 and FIGURE 2 of SECTION 6.4

%Problem parameters  
M = 80;
alphaval = 100; %for alpha = alphaval/(M-1)^2
pval = 6; %for P = 10^pval

if DOPAPER
    % For Figure 1 in Section 6.2 
    policies = 'aEqual:sfixed:aESPB:sfixed:aRandom:sfixed:aVar:sfixed:aCKG:sfixed:aCKGstar:sfixed:aPDEUpperNO:sfixed:aPDE:sfixed:aPDELower:sfixed'; % policies to include
    rprob = [-1,-1,-1, -1, -1, -1, -1, -1, -1]; % randomization probability, negative if deterministic
    rtype = [0,0,0,0,0,0,0,0,0]; %1 for uniform, 2 for TTVS
    Tfixed = 100*ones(9,1); %period to stop for fixed stopping policy, 0 if another stopping policy is used
    if DOSAVEFILES
        settings.foldertosave = strcat(pdecorr, 'Outputs\');
        settings.filename = strcat('sec62-P',num2str(pval),'-alpha',num2str(alphaval)); %name of the figure file if it will be saved
    else
        settings.foldertosave = -1; % folder path to save results and figures, -1 to not save, example to save: strcat(pdecorr, 'Outputs\')
        settings.filename = ''; %name of the figure file if it will be saved
    end
    %%% Run simulation analysis
    startt = tic;
    [ parameters ] = ProblemSetupSynthetic( M, alphaval, pval);
    [ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
    %%% Generating a figure to compare allocation policies
    GenerateOCFig(simresults, settings.foldertosave, settings.filename, 0);
    %%% Calculate CI at a given t
    givent = 2;
    [meandOC, sedOCa] = CalculateCIofOC( simresults, givent );
    toc(startt)

    % For Figure 2 in Section 6.4
    policies = 'aEqual:sfixed:aRandom:sfixed:aVar:sfixed:aPDELower:sfixed:aPDELower:sfixed:aPDELower:sfixed:aPDELower:sfixed:aPDELower:sfixed'; % policies to include
    rprob = [-1,-1,-1,0.4,0.2,0.4,0.2,-1]; % randomization probability, negative if deterministic
    rtype = [0,0,0, 1, 1, 2, 2, 0]; %1 for uniform, 2 for TTVS
    Tfixed = 100*ones(8,1); %period to stop for fixed stopping policy, 0 if another stopping policy is used
    if DOSAVEFILES
        settings.foldertosave = strcat(pdecorr, 'Outputs\');
        settings.filename = strcat('sec64-P',num2str(pval),'-alpha',num2str(alphaval)); %name of the figure file if it will be saved
    else
        settings.foldertosave = -1; % folder path to save results and figures, -1 to not save, example to save: strcat(pdecorr, 'Outputs\')
        settings.filename = ''; %name of the figure file if it will be saved
    end
    %%% Run simulation analysis
    startt = tic;
    [ parameters ] = ProblemSetupSynthetic( M, alphaval, pval);
    [ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
    %%% Generating a figure to compare allocation policies
    GenerateOCFig(simresults, settings.foldertosave, settings.filename, 0);
    %%% Calculate CI at a given t
    givent = 2;
    [meandOC, sedOCa] = CalculateCIofOC( simresults, givent );
    toc(startt)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CHUNK 3: Table 1 of SECTION 6.3, Table EC.2 in Appendix C.1

%% Comparing allocation and stopping policy pairs with 80 arm problem
%Problem parameters  
M = 80;
alphaval = 100; %for alpha = alphaval/(M-1)^2
pval = 6; %for P = 10^pval

%%%%%%%%%%%%%%%%%%%%
%%%Policies to test
if ~DOPAPER
    policies = 'aEqual:sfixed:aCKG:sfixed:aPDELower:sfixed:aPDELower:sfixed'; % Policies to include
    rprob = [-1, -1, 0.2, -1]; % randomization probability, negative if deterministic
    rtype = [0, 0, 1, 0]; %1 for uniform, 2 for TTVS
    Tfixed = 10*ones(1,4); %period to stop for fixed stopping policy, 0 if another stopping policy is used
    if DOSAVEFILES
        settings.foldertosave = strcat(pdecorr, 'Outputs\');
        settings.filename = strcat('chunk3test-P',num2str(pval),'-alpha',num2str(alphaval)); %name of the figure file if it will be saved
    else
        settings.foldertosave = -1; % folder path to save results and figures, -1 to not save, example to save: strcat(pdecorr, 'Outputs\')
        settings.filename = ''; %name of the figure file if it will be saved
    end
    %%% Run simulation
    startt = tic;
    [ parameters ] = ProblemSetupSynthetic( M, alphaval, pval);
    [ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
    %%% Generating a table to compare policies
    [ toCopy ] = GenerateTCTable( simresults, settings.foldertosave, settings.filename );
    toc(startt)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For Table 1 in Section 6.3
if DOPAPER
    policies = 'aCKG:sfixed:aCKG:sfixed:aCKG:sPDEUpperNO:aCKG:sPDEHeu:aCKG:sfixed:aCKG:sPDELower:aCKG:sCKGstar:aPDELower:sPDEUpperNO:aPDELower:sPDEHeu:aPDELower:sfixed:aPDELower:sPDELower:aPDELower:sfixed:aPDELower:sCKGstar:aVar:sfixed:aVar:sfixed'; % policies to include
    rprob = -1*ones(15,1); % randomization probability, negative if deterministic
    rtype = 0*ones(15,1); %1 for uniform, 2 for TTVS
    Tfixed = [493,200,0,0,130,0,0,0,0,200,0,150,0,200,150]; %period to stop for fixed stopping policy, 0 if another stopping policy is used
    if DOSAVEFILES
        settings.foldertosave = strcat(pdecorr, 'Outputs\');
        settings.filename = strcat('sec63table1-P',num2str(pval),'-alpha',num2str(alphaval)); %name of the figure file if it will be saved
    else
        settings.foldertosave = -1; % folder path to save results and figures, -1 to not save, example to save: strcat(pdecorr, 'Outputs\')
        settings.filename = ''; %name of the figure file if it will be saved
    end
    %%% Run simulation
    startt = tic;
    [ parameters ] = ProblemSetupSynthetic( M, alphaval, pval);
    [ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
    %%% Generating a table to compare policies
    [ toCopy ] = GenerateTCTable( simresults, settings.foldertosave, settings.filename );
    toc(startt)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For Table EC2 in Appendix C.1

if DOPAPER
    pval = 4; %for P = 10^4
    policies = 'aPDEUpper:sCKGstar:aPDEUpperNO:sCKGstar:aPDEUpper:sPDELower:aPDEUpperNO:sPDELower'; % policies to include
    rprob = -1*ones(4,1); % randomization probability, negative if deterministic
    rtype = 0*ones(4,1); %1 for uniform, 2 for TTVS
    Tfixed = [0,0,0,0]; %period to stop for fixed stopping policy, 0 if another stopping policy is used

    %%% Run simulation
    [ parameters ] = ProblemSetupSynthetic( M, alphaval, pval);
    [ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
    %%% Generating a table to compare policies
    [ toCopy ] = GenerateTCTable( simresults, settings.foldertosave, settings.filename );
    toc(startt)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CHUNK 4: Testing of GPR prior, etc.

%% Comparing allocation and stopping policy pairs with dose-finding case study
%Problem parameters  
priortype = 'gpr'; %'gpr', 'robust' or 'tilted'
graphforprior = 1; %if 1, generates a figure that shows the prior for each pilot study, 0 for no figure.
zalpha = 1/2; % used in robust and tilted priors

if ~DOPAPER
    %%%  Policies to test
    policies = 'aEqual:sfixed:aCKG:sfixed:aPDELower:sfixed:aPDELower:sfixed'; % Policies to include
    rprob = [-1, -1, 0.2, -1]; % randomization probability, negative if deterministic
    rtype = [0, 0, 1, 0]; %1 for uniform, 2 for TTVS
    Tfixed = [20,20,20,20]; %period to stop for fixed stopping policy, 0 if another stopping policy is used
    %%% Run simulation
    startt = tic;
    [ parameters ] = ProblemSetupDoseCaseStudy(priortype, graphforprior, zalpha);
    [ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
    %%% Generating a table to compare policies
    [ toCopy ] = GenerateTCTable( simresults, settings.foldertosave, settings.filename );
    toc(startt)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TO HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% For Table 1 in Section 6.3 
%SEC FIX: IS THIS TABLE 1 IN 6.3? OR OTHER? Table 1 of 6.3 was listed above?
%Problem parameters  
priortype = 'gpr'; %'gpr', 'robust' or 'tilted'
graphforprior = 1; %if 1, generates a figure that shows the prior for each pilot study, 0 for no figure.
zalpha = 1/2; % used in robust and tilted priors

%%%  Policies to test
if DOPAPER
    policies = 'aCKG:sfixed:aCKG:sfixed:aCKG:sPDEUpperNO:aCKG:sPDEHeu:aCKG:sfixed:aCKG:sPDELower:aCKG:sCKGstar:aPDELower:sPDEUpperNO:aPDELower:sPDEHeu:aPDELower:sfixed:aPDELower:sPDELower:aPDELower:sfixed:aPDELower:sCKGstar:aVar:sfixed:aVar:sfixed'; % policies to include
    rprob = -1*ones(15,1); % randomization probability, negative if deterministic
    rtype = 0*ones(15,1); %1 for uniform, 2 for TTVS
    Tfixed = [493,200,0,0,130,0,0,0,0,200,0,150,0,200,150]; %period to stop for fixed stopping policy, 0 if another stopping policy is used
    %%% Run simulation
    startt = tic;
    [ parameters ] = ProblemSetupDoseCaseStudy(priortype, graphforprior, zalpha);
    [ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
    %%% Generating a table to compare policies
    [ toCopy ] = GenerateTCTable( simresults, settings.foldertosave, settings.filename );
    toc(startt)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Plotting EVI approximations against different prior means
%%% Generate a problem with 3 arms
[ parameters ] = ProblemSetup3Arms();

%%% Figure parameters
i = 1; % calculate the EVI of arm i
mu0istotest = (-3:1:3)*sqrt(parameters.sigma0(i,i)); %prior mean values to calcualte the EVI at

% For Figure EC1
% i = 1;
% mu0istotest = (-3:0.1:3)*sqrt(parameters.sigma0(i,i));

%%% Generating the figure
GenerateEVIvsmu0Fig(mu0istotest, i, cfSoln, parameters, settings.foldertosave, settings.filename)

%% Plotting EVI approximations across all arms in a problem
%%% Generate a problem
M = 80;
alphaval = 16; %for alpha = alphaval/(M-1)^2
pval = 4; %for P = 10^pval
[ parameters ] = ProblemSetupSynthetic( M, alphaval, pval);
rng default
thetav = mvnrnd(parameters.rpimu0,parameters.rpisigma0);
mucur = parameters.mu0;
sigmacur = parameters.sigma0;
for j = 1:10
    i = randi([1 parameters.M]);
    y = normrnd(thetav(i),sqrt(parameters.lambdav(i))); 
    [mucur,sigmacur] = BayesianUpdate(mucur,sigmacur,i, y, parameters.lambdav(i));
end
parameters.mu0 = mucur;
parameters.sigma0 = sigmacur;

%%% Figure parameters
armstotest = 1:5:parameters.M;

% For Figure EC2
% M = 80;
% alphaval = 16; %for alpha = alphaval/(M-1)^2
% pval = 4; %for P = 10^pval
% [ parameters ] = ProblemSetupSynthetic( M, alphaval, pval);
% % Take 10 random allocations
% rng default
% thetav = mvnrnd(parameters.rpimu0,parameters.rpisigma0);
% mucur = parameters.mu0;
% sigmacur = parameters.sigma0;
% for j = 1:10
%     i = randi([1 parameters.M]);
%     y = normrnd(thetav(i),sqrt(parameters.lambdav(i))); 
%     [mucur,sigmacur] = BayesianUpdate(mucur,sigmacur,i, y, parameters.lambdav(i));
% end
% armstotest = 1:5:parameters.M;

%%% Generating the figure
GenerateEVIvsArmsFig(armstotest, cfSoln, parameters, settings.foldertosave, settings.filename)

%% Plotting EVI approximations and CPU times across multiple problems
%%% Problem parameters
Mvec = 5:5:100; % Number of arms in the problem to test over
alphaval = 100; %for alpha = alphaval/(M-1)^2
pval = 4; %for P = 10^pval
alttograph = 5; %which alterantive's EVI to calculate
periodtograph = 5; %calculate EVI after how many periods

% For Figures EC3 and EC4 
% Mvec = 5:5:100; % Number of arms in the problem to test over
% alphaval = 100; %for alpha = alphaval/(M-1)^2
% pval = 4; %for P = 10^4
% alttograph = 5; %which alterantive's EVI to calculate
% periodtograph = 5; %calcualte EVI after how many periods

%%% Generating the figures
GenerateEVIandCPUvsNumofArmsFig(Mvec, cfSoln, alttograph, periodtograph, alphaval, pval, settings.foldertosave, settings.filename)

%% Plotting the power curve for a problem
%%% Problem parameters
M = 21; % Number of arms in the problem to test over
deltastotest = 0.3:0.2:1.5; % controls the shape of the triangular curve

%%% Policies to test
policies = 'aPDEUpperNO:sfixed:aCKGstar:sfixed:aPDELower:sfixed';
rprob = -1*ones(3,1); % randomization probability, negative if deterministic
rtype = 0*ones(3,1); %1 for uniform, 2 for TTVS
Tfixed = [20,20,20]; %period to stop for fixed stopping policy, 0 if another stopping policy is used

% For Figure EC5
% policies = 'aPDEUpperNO:sfixed:aCKGstar:sfixed:aPDELower:sfixed:aPDEUpperNO:sPDEUpperNO:aCKGstar:sCKGstar:aPDELower:sPDELower';
% rprob = -1*ones(6,1); % randomization probability, negative if deterministic
% rtype = 0*ones(6,1); %1 for uniform, 2 for TTVS
% Tfixed = [150,150,150,0,0,0]; %period to stop for fixed stopping policy, 0 if another stopping policy is used

%%% Run simulation for all deltas and policies
all = struct();
for i = 1:size(deltastotest,2)
    stepsize = deltastotest(i);
    [ parameters ] = ProblemSetupTriangular( M, stepsize);
    [ result ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
    all(i).simresults = result;
    all(i).deltaval = stepsize;
end

%%% Generating a figure
GeneratePowerCurve(all, settings.foldertosave, settings.filename);

%% Finding the best fixed stopping time using simulation for 80 arm problem
%Problem parameters  
M = 80;
alphaval = 100; %for alpha = alphaval/(M-1)^2
pval = 6; %for P = 10^pval

%%% Simulation details
% Consider setting a different seed, so that best fixed stopping time is
% coming from a different set of observations
% settings.seed = 6541235; % seed to be used for random number generation

%%%  Policies to test
policies = 'aCKG:sfixed'; % Policies to include
rprob = [-1]; % randomization probability, negative if deterministic
rtype = [0]; %1 for uniform, 2 for TTVS
Tfixed = [100]; %period to stop for fixed stopping policy, 0 if another stopping policy is used

% For Section 6.2 
% policies = 'aCKG:sfixed'
% rprob = [-1]; % randomization probability, negative if deterministic
% rtype = [0]; %1 for uniform, 2 for TTVS
% Tfixed = 10000; %period to stop for fixed stopping policy, 0 if another stopping policy is used

%%% Run simulation
[ parameters ] = ProblemSetupSynthetic( M, alphaval, pval);
[ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);

%%% Generating a figure
GenerateOCTCSCFig(simresults, settings.foldertosave, settings.filename);
toc(startt)

%% Finding the best fixed stopping time using simulation for dose-finding case study
%Problem parameters  
priortype = 'gpr'; %'gpr', 'robust' or 'tilted'
graphforprior = 0; %if 1, generates a figure that shows the prior for each pilot study
zalpha = 1/2; % used in robust and tilted priors

%%% Simulation details
% Consider setting a different seed, so that best fixed stopping time is
% coming from a different set of observations
% settings.seed = 6541235; % seed to be used for random number generation

%%%  Policies to test
policies = 'aCKG:sfixed'; % Policies to include
rprob = [-1]; % randomization probability, negative if deterministic
rtype = [0]; %1 for uniform, 2 for TTVS
Tfixed = [100]; %period to stop for fixed stopping policy, 0 if another stopping policy is used

% For Section 6.2 
% policies = 'aCKG:sfixed'
% rprob = [-1]; % randomization probability, negative if deterministic
% rtype = [0]; %1 for uniform, 2 for TTVS
% Tfixed = 3000; %period to stop for fixed stopping policy, 0 if another stopping policy is used

%%% Run simulation
[ parameters ] = ProblemSetupDoseCaseStudy(priortype, graphforprior, zalpha);
[ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);

%%% Generating a figure
GenerateOCTCSCFig(simresults, settings.foldertosave, settings.filename);