% ReplicateCGY.m:
% PURPOSE: A macro with the code required to generate the figures and tables
% for correlated multiarm paper (Chick, Gans, Yapar (2020)).

%% INITIALIZATION
%%% Set directories
SetPaths

%%% Load Standard Solutions
PDELocalInit;
[cgSoln, cfSoln, ~, ~] = PDELoadSolnFiles(PDEmatfilebase, false); %load solution files

%% Comparing allocation policies with 80 arm problem
startt = tic;
%Problem parameters  
alphaval = 100; %for alpha = 100/(M-1)^2
pval = 6; %for P = 10^6

%%% Simulation details
settings.NUMOFREPS = 1; %number of replications for the simulation, 1000 in the paper
settings.filename = ''; %name of the figure file if it will be saved
settings.crn = 1; %1 if crn is implemented, 0 otherwise
settings.seed = 487429276; % seed to be used for random number generation
settings.foldertosave = -1; % folder path to save results and figures, -1 to not save
%settings.filename = strcat('sec62-P',num2str(pval),'-alpha',num2str(alphaval));
%settings.foldertosave = strcat(pdecorr, 'Outputs'); 
settings.BOUND = 10000; %Maximum number of periods the simulation goes

%%%  Policies to test
policies = 'aEqual:sfixed:aCKG:sfixed:aPDELower:sfixed:aPDELower:sfixed'; % Policies to include
rprob = [-1, -1, 0.2, -1]; % randomization probability, negative if deterministic
rtype = [0, 0, 1, 0]; %1 for uniform, 2 for TTVS
Tfixed = [50,50,50,50]; %period to stop for fixed stopping policy, 0 if another stopping policy is used

% For Figure 1 in Section 6.2 
% policies = 'aEqual:sfixed:aESPB:sfixed:aRandom:sfixed:aVar:sfixed:aCKG:sfixed:aKGStarLower:sfixed:aPDEUpperNO:sfixed:aPDE:sfixed:aPDELower:sfixed'; % policies to include
% rprob = [-1,-1,-1, -1, -1, -1, -1, -1, -1]; % randomization probability, negative if deterministic
% rtype = [0,0,0,0,0,0,0,0,0]; %1 for uniform, 2 for TTVS
% Tfixed = 100*ones(9,1); %period to stop for fixed stopping policy, 0 if another stopping policy is used

% For Figure 2 in Section 6.4
% policies = 'aEqual:sfixed:aRandom:sfixed:aVar:sfixed:aPDELower:sfixed:aPDELower:sfixed:aPDELower:sfixed:aPDELower:sfixed:aPDELower:sfixed'; % policies to include
% rprob = [-1,-1,-1,0.4,0.2,0.4,0.2,-1]; % randomization probability, negative if deterministic
% rtype = [0,0,0, 1, 1, 2, 2, 0]; %1 for uniform, 2 for TTVS
% Tfixed = 100*ones(8,1); %period to stop for fixed stopping policy, 0 if another stopping policy is used

%%% Run simulation
[ parameters ] = ProblemSetup80Arms( alphaval, pval);
[ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);

%%% Generating a figure to compare allocation policies
GenerateOCFig(simresults, settings.foldertosave, settings.filename, 0);
toc(startt)

%%% Calculate CI at a given t
givent = 50;
[meandOC, sedOCa] = CalculateCIofOC( simresults, givent );

%% Comparing allocation and stopping policy pairs with 80 arm problem
startt = tic;
%Problem parameters  
alphaval = 100; %for alpha = 100/(M-1)^2
pval = 6; %for P = 10^6

%%% Simulation details
settings.NUMOFREPS = 5; %number of replications for the simulation, 1000 in the paper
settings.filename = ''; %name of the figure file if it will be saved
settings.crn = 1; %1 if crn is implemented, 0 otherwise
settings.seed = 487429276; % seed to be used for random number generation
settings.foldertosave = -1; % folder path to save results and figures, -1 to not save
%settings.filename = strcat('sec62-P',num2str(pval),'-alpha',num2str(alphaval));
%settings.foldertosave = strcat(pdecorr, 'Outputs'); 
settings.BOUND = 10000; %Maximum number of periods the simulation goes

%%%  Policies to test
policies = 'aEqual:sfixed:aCKG:sfixed:aPDELower:sfixed:aPDELower:sfixed'; % Policies to include
rprob = [-1, -1, 0.2, -1]; % randomization probability, negative if deterministic
rtype = [0, 0, 1, 0]; %1 for uniform, 2 for TTVS
Tfixed = [50,50,50,50]; %period to stop for fixed stopping policy, 0 if another stopping policy is used

% For Table 1 in Section 6.3
% policies = 'aCKG:sfixed:aCKG:sfixed:aCKG:sPDEUpperNO:aCKG:sPDEHeu:aCKG:sfixed:aCKG:sPDELower:aCKG:sKGStarLower:aPDELower:sPDEUpperNO:aPDELower:sPDEHeu:aPDELower:sfixed:aPDELower:sPDELower:aPDELower:sfixed:aPDELower:sKGStarLower:aVar:sfixed:aVar:sfixed'; % policies to include
% rprob = -1*ones(15,1); % randomization probability, negative if deterministic
% rtype = 0*ones(15,1); %1 for uniform, 2 for TTVS
% Tfixed = [493,200,0,0,130,0,0,0,0,200,0,150,0,200,150]; %period to stop for fixed stopping policy, 0 if another stopping policy is used

%%% Run simulation
[ parameters ] = ProblemSetup80Arms( alphaval, pval);
[ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
toc(startt)
%%% Generating a table to compare policies
[ toCopy ] = GenerateTCTable( simresults, settings.foldertosave, settings.filename );

%% Comparing allocation and stopping policy pairs with dose-finding case study
startt = tic;
%Problem parameters  
priortype = 'gpr'; %'gpr', 'robust' or 'tilted'
graphforprior = 0; %if 1, generates a figure that shows the prior for each pilot study
zalpha = 1/2; % used in robust and tilted priors

%%% Simulation details
settings.NUMOFREPS = 1000; %number of replications for the simulation, 1000 in the paper
settings.filename = ''; %name of the figure file if it will be saved
settings.crn = 1; %1 if crn is implemented, 0 otherwise
settings.seed = 487429276; % seed to be used for random number generation
settings.foldertosave = -1; % folder path to save results and figures, -1 to not save
%settings.filename = strcat('sec62-P',num2str(pval),'-alpha',num2str(alphaval));
%settings.foldertosave = strcat(pdecorr, 'Outputs'); 
settings.BOUND = 10000; %Maximum number of periods the simulation goes

%%%  Policies to test
policies = 'aEqual:sfixed:aCKG:sfixed:aPDELower:sfixed:aPDELower:sfixed'; % Policies to include
rprob = [-1, -1, 0.2, -1]; % randomization probability, negative if deterministic
rtype = [0, 0, 1, 0]; %1 for uniform, 2 for TTVS
Tfixed = [50,50,50,50]; %period to stop for fixed stopping policy, 0 if another stopping policy is used

% For Table 1 in Section 6.3
% policies = 'aCKG:sfixed:aCKG:sfixed:aCKG:sPDEUpperNO:aCKG:sPDEHeu:aCKG:sfixed:aCKG:sPDELower:aCKG:sKGStarLower:aPDELower:sPDEUpperNO:aPDELower:sPDEHeu:aPDELower:sfixed:aPDELower:sPDELower:aPDELower:sfixed:aPDELower:sKGStarLower:aVar:sfixed:aVar:sfixed'; % policies to include
% rprob = -1*ones(15,1); % randomization probability, negative if deterministic
% rtype = 0*ones(15,1); %1 for uniform, 2 for TTVS
% Tfixed = [493,200,0,0,130,0,0,0,0,200,0,150,0,200,150]; %period to stop for fixed stopping policy, 0 if another stopping policy is used

%%% Run simulation
[ parameters ] = ProblemSetupDoseCaseStudy(priortype, graphforprior, zalpha);
[ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
toc(startt)
%%% Generating a table to compare policies
[ toCopy ] = GenerateTCTable( simresults, settings.foldertosave, settings.filename );



