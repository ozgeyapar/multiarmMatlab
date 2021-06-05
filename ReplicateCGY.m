%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ReplicateCGY.m:
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PURPOSE: A macro with the code required to generate the figures and tables
%% for the paper 'Bayesian Sequential Leanring for Clinical Trials of Multiple Correlated Medical Interventions',
%% by Stephen E Chick, Noah Gans, Ozge Yapar, manuscript accepted to appear in Management Science in 2021.
% The original version of the paper appeared at SSRN in 2018 and was submitted to Management Science at the time.
%% Stored at github.com:ozgeyapar/multiarmMatlab.git 
% Latest version: 2021 06 04: 
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SUMMARY OF THIS FILE
% This code provided as demonstrations of calling conventions for producing 
% all graphs and tables in the accepted manuscript. Please note that the
% code does NOT reproduce all graphs identically. There are a couple of
% reasons for this:
%   1. There is statistical noise due to simulation estimation
%   2. Some of the experiments require orders of magnitude longer run times
%   than others - and it is not always advantageous to use the allocation
%   policies or stopping times that have long run times. The paper gives
%   results for all algorithms with good statistical esitmation, however
%   those results required LONG times in a very distributed environment to
%   be able to complte the graphs and tables. Because we do not wish to
%   presume that all potential users of this code would have the same
%   distributed environment, we have adapted the code to be able to run on 
%   a single machine.
%   3. The code implements all of the arm allocation policies and stopping
%   times of the paper, to show how they can be used. It then allows for
%   generation of all graphs and tables from the paper, while controlling
%   the number of replications used for estimates (using GGYHIREPS,
%   CGYLOWREPS, DOHIREPS as macros to control the number of replications
%   and whether full sets of results are to be produce - with DOHIREPS true
%   or false - true to generate tables from paper, false to demonstrate 
%   calling conventions for quick to run tables), DOSAVEFILES (to save 
%   graphics to EPS, tables to XLS, data to MAT files).
% 
%% TEST ENVIRONMENT
% This set of macros have been tested in Matlab 2021a.
% Please consult the README.md at the github repo for information about
% installing additional repos that are required for the code in this file
% to run properly.
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GENERAL INFORMATION ABOUT SPECIFYING AN ARM ALLOCATION POLICY AND A STOPPING TIME TO TEST FROM THE PAPER.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% There are many allocation policies tested as well as many stopping rules.
% this code assumes that an overall policy, composed of an allocation rul
% and stopping time, is specified by a given string: for example, an equal
% allocation is specified by 'aEqual' and a fixed duration stopping time is
% specified by 'sfixed'. 
%% For a list of all supported allocaiton rules and stopping times, see 'sim/DefineRules.m'
% The concept is to have the string reference a function handle which is
% passed to the sampling algorithm to allocate arms and to decide when to
% stop sampling.
%
%% Here is the list of allocation and stopping policies that can be tested with the names to call them
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
% sPDE: cPDE stopping policy, uses cPDELower and cPDEUpper for faster computation
%
%% To specify a single policy or multiple policies (to test multiple policies for a graph
% Here are some example individual policies:
% 	policies = 'aCKG:sfixed';
% 	policies = 'aPDELower:sfixed';
%
% Here is an example of a list of 4 policies, with different allocation
% rules and each with the fixed duration stopping time.
% 	policies = 'aEqual:sfixed:aCKG:sfixed:aPDELower:sfixed:aPDELower:sfixed';
%
%% To specify a randomized version of a policy, when applicable
%  Randomization probabilities for each policy: a numerical array,
%  each value corresponds to the randomization probability of the
%  corresponding allocation policy (according to the order given in 
%  'policies' above). Use -1 for an allocation policy to be
%  deterministic, otherwise select a number between 0 and 1.
% e.g., rprob = [-1, -1, 0.2, -1];
%
%  Randomization types for each policy: a numerical array,
%  each value corresponds to the randomization method used (according
%  to the order given in 'policies' above). 0 for nonrandomized, 1 
%  for uniform, 2 for TTVS
% e.g., rtype = [0, 0, 1, 0]; 
%
%  Fixed stopping time: a numerical array, each value corresponds to
%  the period to stop for fixed stopping policy (according
%  to the order given in 'policies' above). 0 can be used if 
%  a different stopping time is used
% e.g., Tfixed = [20,20,20,20];
%
%% Specification of a prior distribution to be used
%%%  Type of the prior to be used (if pilot study data is used to fit a 
%%%  prior): CGY (2020) introduced two modifications to
%%%  to the prior distribution obtained by using the Gaussian process 
%%%  regression (GPR) called Robust and Tilted. Option called priortype 
%%% controls whether the prior from the GPR or one of the two 
%%% modifications are used. Use 'gpr' to use the GPR prior as it is, use
%%% 'robust' for Robust prior and or use 'tilted' for Tilted prior.
% e.g., priortype = 'gpr'; 
%%% Option zalpha is the fudge factor for uncertainty that is used
%%%  to control how tilted and robust priors modify the prior mean.
% e.g., zalpha = 1/2;
%%% Option settings.graphforprior controls whether a figure that shows 
%%% the prior for each pilot study is generated or not, generated only
%%% for the first 5 simulation replications
% e.g., settings.graphforprior = 1; %if 1, generates , 0 for no figure.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% INITIALIZATION TO SET PATHS AND LOAD IN PRECOMPUTED PDE ALLOCATION FILES
%% Consult README.md to install the necessary code clusters (including the cKG 
%% package of Peter Frazier, and the pdestop package from Steve Chick
%% Also: create a SetPaths file to localize the code and initialize paths for your local installation.

DOMSGS = true;  % GLOBAL: Set to 'true' to get status messages for code execution, false otherwise.

mymsg='setting paths, loading precomputed PDE solution (see readme.md for explanation)';
if DOMSGS disp(mymsg); end;
%%% Set directories
SetPaths

%%% Load Standard Solutions for the PDE code. You must have created them
%%% once on your machine as described in README.md
PDELocalInit;
[cgSoln, cfSoln, ~, ~] = PDELoadSolnFiles(PDEmatfilebase, false); %load solution files

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GLOBAL PARAMETERS %%%

% Simulation details: Settings that can be edited by end-user. 
DOPAPER = true; % GLOBAL: Set to TRUE to get figures/graphs for paper, FALSE to get sample runs with simpler graphs
DOHIREPS = true; % GLOBAL: Set to TRUE to get lots of replications, FALSE to get small number of reps for testing
    CGYHIREPS = 40; % GLOBAL: was 1000 for final paper. can set lower for testing.
    CGYLOWREPS = 4; % GLOBAL: small number of replications so runs don't take too long - for debug or checking install
DOSAVEFILES = true; % GLOBAL: set to true to save results and figures to file, FALSE if files are not to be saved. 
    %if saved, need to set foldertosave and filename fields of the settings
    %field as denoted below, e.g. settings.foldertosave = strcat(pdecorr,
    %'Outputs\') settings.filename = 'myfigs'.
    % If foldertosave field is -1, no result will be saved regardless of the 
    % value of filename field.
DOSLOWPAIRS = false; % GLOBAL: Set to TRUE to get graphs with cPDE and other slow policies (be prepared for VERY long run times), set to false (recommended) to omit cPDE from analysis

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
settings.seed = 487429276; % seed to be used for random number generation - value used in paper.
%settings.seed = 48742927; % seed to be used for random number generation
settings.BOUND = 7500; % FOr paper, was set to 10000 - Maximum number of observations per arm per sample path.
%% Note that the settings parameters can be adjusted below for a given experiment to suit the needs of that experiment, e.g. to have files saved to a different directory if you prefer

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHUNK: Policies to test. 
%% Copy and paste chunk by chunk the code.
% this chunk illustrates examples of creating a list of policies to test,
% and running a simulation experiment, including output of graphs
if ~DOPAPER
    %% Compare several allocation policies on an 80 arm problem
    %Problem parameters  
    M = 80; % number of arms in the problem
    alphaval = 100; %for alpha = alphaval/(M-1)^2
    pval = 6; %for P = 10^pval

    mymsg = 'running simple low-resolution test sample';
    if DOMSGS disp(mymsg); end;

    % Policies to include - these are delimited by ':', and are to have an
    % allocation rule followed by a stopping rule. 
    policies = 'aEqual:sfixed:aCKG:sfixed:aPDELower:sfixed:aPDELower:sfixed'; 
    % the number of rule pairs (allocation/stopping) is therefore:
    numrulepairs = (1+count(policies,':'))/2;
    % for each rule pair, speciify if the allocation rule is to include
    % randomization or not. If the value is negative, the allocation is
    % applied in a deterministic way. if the value is in [0,1), then this
    % reflects a randomization probability, to be intepreted according to
    % the definition of the relevant allocation rule.
    rprob = -1 * ones(numrulepairs,1);  % this sets all rule pairs to be run in determinstic way
    rprob(3) = 0.2; % this sets the third rule pair to use the given randomization probability
    %    rprob = [-1, -1, 0.2, -1]; % randomization probability, negative if deterministic
    % rtype = is set for randomization for a given rule pair. 0 for nonrandomized, 1 for uniform selection if randomize, 2 for TTVS - top two value sampling variation
    rtype = 0 * ones(numrulepairs,1); % this sets all rule pairs to be nonrandomized.
    rtype(3) = 1; % here, the third rule pair is randomized for uniform selection
    %rtype = [0, 0, 1, 0]'; %0 for nonrandomized, 1 for uniform selection if randomize, 2 for TTVS - top two value sampling variation
    % NOTE: rprob and rtype consistency: For randomization to happen, both have to imply randomization. 
    % THAT IS: if rprob(1) = .2 and rtype(1) = 0, deterministic. If rprob(1) = -1 and rtype(1) = 2, deterministic. 

    Tfixed = 15*ones(numrulepairs,1);%[2,2,2,2]; %period to stop for fixed stopping policy, 0 if another stopping policy is used
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
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHUNK: FIGURE 1 of SECTION 6.2 and FIGURE 4 of SECTION 7.2
% These figures give the EOC for each of several allocation rules as a function of a (fixed) sample size
% Figure 1 in section 6.2 does this for deterministic allocations
% Figure 4 of section 7.2 does this to compare deterministic and randomized allocations

%Problem parameters  
M = 80;
alphaval = 100; %for alpha = alphaval/(M-1)^2
pval = 6; %for P = 10^pval

% For Figure 1 in Section 6.2 
mymsg = sprintf('analysis for Sec 6.2 fig 1: Nreps = %d, doslowpairs = %d.',settings.NUMOFREPS,DOSLOWPAIRS);
if DOMSGS disp(mymsg); end;
if DOSLOWPAIRS % if you want to do with cPDE use the next line - be prepared for VERY long run times...
    policies = 'aEqual:sfixed:aESPB:sfixed:aRandom:sfixed:aVar:sfixed:aCKG:sfixed:aCKGstar:sfixed:aPDEUpperNO:sfixed:aPDE:sfixed:aPDELower:sfixed'; % policies to include
    %rprob = [-1,-1,-1, -1, -1, -1, -1, -1, -1]; % randomization probability, negative if deterministic
    numrulepairs = (1+count(policies,':'))/2;
    rprob = -1*ones(numrulepairs,1);% run as deterministic allocations
    rtype = zeros(size(rprob));  %0 for no randomization, 1 for uniform, 2 for TTVS
else % otherwise use the follwoing line, which does all the graphs except cPDE allocation rule
    policies = 'aEqual:sfixed:aESPB:sfixed:aRandom:sfixed:aVar:sfixed:aCKG:sfixed:aCKGstar:sfixed:aPDEUpperNO:sfixed:aPDELower:sfixed'; % policies to include
    numrulepairs = (1+count(policies,':'))/2;
    rprob = -1*ones(numrulepairs,1);% run as deterministic allocations
%       rprob = [-1,-1,-1, -1, -1, -1, -1, -1]; % randomization probability, negative if deterministic
    rtype = zeros(size(rprob));  %0 for no randomization, 1 for uniform, 2 for TTVS
end
%
Tfixed = 100*ones(numrulepairs,1);%100*ones(9,1); %period to stop for fixed stopping policy, 0 if another stopping policy is used
if DOSAVEFILES
    settings.foldertosave = strcat(pdecorr, 'Outputs\');
    settings.filename = strcat('sec62Fig1-P',num2str(pval),'-alpha',num2str(alphaval)); %name of the figure file if it will be saved
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

% For Figure 4 in Section 7.2
mymsg = sprintf('analysis for Sec 7.2 fig 4: Nreps = %d, doslowpairs = %d.',settings.NUMOFREPS,DOSLOWPAIRS);
if DOMSGS disp(mymsg); end;
policies = 'aEqual:sfixed:aRandom:sfixed:aVar:sfixed:aPDELower:sfixed:aPDELower:sfixed:aPDELower:sfixed:aPDELower:sfixed:aPDELower:sfixed'; % policies to include
numrulepairs = (1+count(policies,':'))/2;
rprob = [-1,-1,-1,0.4,0.2,0.4,0.2,-1]; % randomization probability, negative if deterministic
rtype = [0,0,0, 1, 1, 2, 2, 0]; %1 for uniform, 2 for TTVS

Tfixed = 100*ones(numrulepairs,1);%100*ones(8,1); %period to stop for fixed stopping policy, 0 if another stopping policy is used
if DOSAVEFILES
    settings.foldertosave = strcat(pdecorr, 'Outputs\');
    settings.filename = strcat('sec72Fig4-P',num2str(pval),'-alpha',num2str(alphaval)); %name of the figure file if it will be saved
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHUNK: Finding the best fixed stopping time using simulation for dose-finding case study
%% In main paper,in Figure 3 we explore the concept of the 'best' fixed duration for a policy, and the EOC, E[T], etotal cost
%% for some different ways of automatically setting the prior. See Sec 6.4, Figure 3.
% Left panel of Sec 6.4 Fig 3 is with GPR, right panel is with 'tilted' prior. figure for robust policy not in paper.
% This code plots the various costs so the sample size with minimum expected total cost can be found.
% The optimal values can also be used to inform the fixed duration stopping times that are used in Table 2.

mymsg = sprintf('analysis for Sec 6.4 fig 3: Nreps = %d, doslowpairs = %d.',settings.NUMOFREPS,DOSLOWPAIRS);
if DOMSGS disp(mymsg); end;

priortypestodo = {'gpr', 'robust', 'tilted'};
settings.graphforprior = 0; %if 1, generates a figure that shows the prior for each pilot study
zalpha = 1/2; % used in robust and tilted priors

%%% Simulation details
% Consider setting a different seed, so that best fixed stopping time is
% coming from a different set of observations
settings.seed = 6541235; % seed to be used for random number generation

policies = 'aCKG:sfixed';
rprob = [-1]; % randomization probability, negative if deterministic
rtype = [0]; %1 for uniform, 2 for TTVS
Tfixed = 3000; %period to stop for fixed stopping policy, 0 if another stopping policy is used

tic
for i=1:length(priortypestodo)
    priortype = string(priortypestodo(i));
    if DOSAVEFILES
        settings.foldertosave = strcat(pdecorr, 'Outputs\');
        settings.filename = strcat('sec64fig3-',priortype); %name of the figure file if it will be saved
    else
        settings.foldertosave = -1; % folder path to save results and figures, -1 to not save, example to save: strcat(pdecorr, 'Outputs\')
        settings.filename = ''; %name of the figure file if it will be saved
    end

    %%% Run simulation
    [ parameters ] = ProblemSetupDoseCaseStudy(priortype, zalpha);
    [ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
    %%% Generating a figure
    GenerateOCTCSCFig(simresults, settings.foldertosave, settings.filename);
end
toc

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHUNK: Table 1 of SECTION 6.3, Table EC.2 in Appendix C.1

% Comparing allocation and stopping policy pairs with 80 arm problem
%Problem parameters  
M = 80;
alphaval = 100; %for alpha = alphaval/(M-1)^2
pval = 6; %for P = 10^pval

%%%%%%%%%%%%%%%%%%%%
%%%Policies to test
if ~DOPAPER
    mymsg = 'demo analysis analogous to sec 6.3 table 1';
    if DOMSGS disp(mymsg); end;
    policies = 'aEqual:sfixed:aCKG:sfixed:aPDELower:sfixed:aPDELower:sfixed'; % Policies to include
    %numrulepairs = (1+count(policies,':'))/2;
    rprob = [-1, -1, 0.2, -1]; % randomization probability, negative if deterministic
    rtype = [0, 0, 1, 0]; %1 for uniform, 2 for TTVS
    Tfixed = 10*ones(4,1); %period to stop for fixed stopping policy, 0 if another stopping policy is used
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
    [ testTable ] = GenerateTCTable( simresults, settings.foldertosave, settings.filename );
    %%% toCopy is a Matlab variable that contains the summary statistics 
    %%% for the simulation in the following order: 
    %%%     'Allocation','Stopping','E[T]', 'S.E', 'E[SC]','S.E','E[OC]','S.E','E[TC]'
    %%%     ,'S.E','P(CS)','CPU'}.
    %%% Can be opened with openvar('testTable') command to be viwed as a table.
    toc(startt)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For Table 1 in Section 6.3
if DOPAPER
    mymsg = sprintf('analysis for sec 6.3 table 1: Nreps = %d, doslowpairs = %d.',settings.NUMOFREPS,DOSLOWPAIRS);
    if DOMSGS disp(mymsg); end;
    if ~DOSLOWPAIRS
        policies = 'aCKG:sfixed:aCKG:sfixed:aCKG:sPDEUpperNO:aCKG:sPDE:aCKG:sfixed:aCKG:sPDELower:aCKG:sCKGstar:aPDELower:sPDEUpperNO:aPDELower:sPDE:aPDELower:sfixed:aPDELower:sPDELower:aPDELower:sfixed:aPDELower:sCKGstar:aVar:sfixed:aVar:sfixed'; % policies to include
        Tfixed = [493,200,0,0,130,0,0,0,0,200,0,150,0,200,150]'; %period to stop for fixed stopping policy, 0 if another stopping policy is used
    else
        policies = 'aCKG:sfixed:aCKG:sfixed:aCKG:sPDEUpperNO:aCKG:sfixed:aCKG:sPDELower:aCKG:sCKGstar:aPDELower:sPDE:aPDELower:sPDELower:aPDELower:sCKGstar:aVar:sfixed:aVar:sfixed'; % policies to include
        Tfixed = [493,200,0,130,0,0,0,0,0,200,150]'; %period to stop for fixed stopping policy, 0 if another stopping policy is used
    end
    numrulepairs = (1+count(policies,':'))/2;
    rprob = -1*ones(numrulepairs,1); % randomization probability, negative if deterministic
    rtype = 0*ones(numrulepairs,1); %1 for uniform, 2 for TTVS
    if DOSAVEFILES
        settings.foldertosave = strcat(pdecorr, 'Outputs\');
        settings.filename = strcat('sec63tab1-P',num2str(pval),'-alpha',num2str(alphaval)); %name of the figure file if it will be saved
    else
        settings.foldertosave = -1; % folder path to save results and figures, -1 to not save, example to save: strcat(pdecorr, 'Outputs\')
        settings.filename = ''; %name of the figure file if it will be saved
    end
    %%% Run simulation
    startt = tic;
    [ parameters ] = ProblemSetupSynthetic( M, alphaval, pval);
    [ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
    %%% Generating a table to compare policies
    [ table1sec63 ] = GenerateTCTable( simresults, settings.foldertosave, settings.filename );
    %%% Can be viewed with openvar('table1sec63')
    toc(startt)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For Table EC2 in Appendix C.1
if DOPAPER
    mymsg = sprintf('analysis for app C.1 table EC.2: Nreps = %d, doslowpairs = %d.',settings.NUMOFREPS,DOSLOWPAIRS);
    if DOMSGS disp(mymsg); end;
    pval = 4; %for P = 10^4
    if DOSLOWPAIRS % if all pairs desired... be prepared for LONG run unless analysis is parallelized
        policies = 'aPDEUpper:sCKGstar:aPDEUpperNO:sCKGstar:aPDEUpper:sPDELower:aPDEUpperNO:sPDELower'; % policies to include
    else % remove the super slow aPDEUpper computation
        policies = 'aPDEUpperNO:sCKGstar:aPDEUpperNO:sPDELower'; % policies to include
        policies = 'aPDEUpper:sCKGstar:aPDEUpperNO:sCKGstar:aPDEUpper:sPDELower:aPDEUpperNO:sPDELower'; % policies to include %SEC TEST
    end
    numrulepairs = (1+count(policies,':'))/2;
    rprob = -1*ones(numrulepairs,1); % randomization probability, negative if deterministic
    rtype = 0*ones(numrulepairs,1); %1 for uniform, 2 for TTVS
    Tfixed = 0*ones(numrulepairs,1); %[0,0,0,0]'; %period to stop for fixed stopping policy, 0 if another stopping policy is used
    if DOSAVEFILES
        settings.foldertosave = strcat(pdecorr, 'Outputs\');
        settings.filename = strcat('appC1tabEC2'); %name of the figure file if it will be saved
    else
        settings.foldertosave = -1; % folder path to save results and figures, -1 to not save, example to save: strcat(pdecorr, 'Outputs\')
        settings.filename = ''; %name of the figure file if it will be saved
    end
    %%% Run simulation
    [ parameters ] = ProblemSetupSynthetic( M, alphaval, pval);
    [ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
    %%% Generating a table to compare policies
    [ tableEC2 ] = GenerateTCTable( simresults, settings.foldertosave, settings.filename );  
    %%% Can be viewed with openvar('tableEC2')
    toc(startt)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHUNK: Testing of GPR prior, etc.

%% Comparing allocation and stopping policy pairs with dose-finding case study
%Problem parameters   
priortype = 'gpr'; %'gpr', 'robust' or 'tilted'
zalpha = 1/2; % used in robust and tilted priors
settings.graphforprior = 1; %if 1, generates a figure that shows the prior 
        % for pilot data for first 5 replications, 0 means no figure is
        % generated.
if ~DOPAPER
    mymsg = sprintf('test for prior distribution fitting');
    if DOMSGS disp(mymsg); end;
    %%%  Policies to test
    policies = 'aEqual:sfixed:aCKG:sfixed:aPDELower:sfixed:aPDELower:sfixed'; % Policies to include
    rprob = [-1, -1, 0.2, -1]; % randomization probability, negative if deterministic
    rtype = [0, 0, 1, 0]; %1 for uniform, 2 for TTVS
    Tfixed = 20*ones(size(rtype)); %period to stop for fixed stopping policy, 0 if another stopping policy is used
    if DOSAVEFILES
        settings.foldertosave = strcat(pdecorr, 'Outputs\');
        settings.filename = strcat('sec64fig2'); %name of the figure file if it will be saved
    else
        settings.foldertosave = -1; % folder path to save results and figures, -1 to not save, example to save: strcat(pdecorr, 'Outputs\')
        settings.filename = ''; %name of the figure file if it will be saved
    end
    %%% Run simulation
    startt = tic;
    [ parameters ] = ProblemSetupDoseCaseStudy(priortype, zalpha);
    [ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
    %%% Generating a table to compare policies
    [ testTab2 ] = GenerateTCTable( simresults, settings.foldertosave, settings.filename );  
    %%% Can be viewed with openvar('testTab2')
    toc(startt)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For Table 2 in Section 6.4
%Problem parameters  
priortypestodo = {'gpr', 'robust', 'tilted'};
zalpha = 1/2; % used in robust and tilted priors
settings.graphforprior = 1; %if 1, generates a figure that shows the prior 
        % for pilot data for first 5 replications, 0 means no figure is
        % generated.
        
%%%  Policies to test
if DOPAPER
    if DOSLOWPAIRS
        policies = 'aCKG:sfixed:aPDELower:sfixed:aVar:sfixed:aCKG:sPDE:aCKG:sPDEUpperNO:aPDELower:sPDEUpperNO:aPDELower:sPDE'; % policies to include
    else
        policies = 'aCKG:sfixed:aPDELower:sfixed:aVar:sfixed:aCKG:sPDEUpperNO:aPDELower:sPDEUpperNO'; % policies to include
        policies = 'aCKG:sfixed:aPDELower:sfixed:aVar:sfixed:aCKG:sPDE:aCKG:sPDEUpperNO:aPDELower:sPDEUpperNO:aPDELower:sPDE'; % policies to include %SEC test
    end
    numrulepairs = (1+count(policies,':'))/2;
    rprob = -1*ones(numrulepairs,1); % randomization probability, negative if deterministic
    rtype = 0*ones(numrulepairs,1); %1 for uniform, 2 for TTVS

    %%% Run simulations
    mymsg = sprintf('analysis for Sec 6.4 table 2: Nreps = %d, doslowpairs = %d.',settings.NUMOFREPS,DOSLOWPAIRS);
    if DOMSGS disp(mymsg); end;
    startt = tic;
    for i=1:length(priortypestodo)
        priortype = string(priortypestodo(i));
        Tfixed=0*ones(numrulepairs,1);
        if strcmp(priortype, 'gpr')
           Tfixed(1:3) = 1060*ones(3,1);
        elseif strcmp(priortype, 'robust')
           Tfixed(1:3) = 565*ones(3,1);
        elseif strcmp(priortype, 'tilted')
           Tfixed(1:3) = 595*ones(3,1);
        end
        if ~DOHIREPS
            Tfixed = ceil(Tfixed/50);
        end
        if DOSAVEFILES
            settings.foldertosave = strcat(pdecorr, 'Outputs\');
            settings.filename = strcat('sec64tab2', priortype); %name of the figure file if it will be saved
        else
            settings.foldertosave = -1; % folder path to save results and figures, -1 to not save, example to save: strcat(pdecorr, 'Outputs\')
            settings.filename = ''; %name of the figure file if it will be saved
        end
        [ parameters ] = ProblemSetupDoseCaseStudy(priortype, zalpha);
        simresults=eye(5+i);
        [ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
        %%% Generating a table to compare policies
        [ table2sec64 ] = GenerateTCTable( simresults, settings.foldertosave, settings.filename );  
        %%% Can be viewed with openvar('table2sec64')
    end
    toc(startt)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHUNK: Plotting EVI approximations against different prior means
%% For EC Appendix C.2, Figure EC.1
% This section generates a graph that plots EVIs approximated by cPDELower, 
% cPDEUpper, cPDE, cKG1 and cKG* methods for a range of mu_0^i values of arm i
% in a three-arm problem.
% The user can control the value of i (1,2 or 3) and the range of mu_0^i's
% to be plotted.

%%% Generate the problem with 3 arms
mymsg = sprintf('analysis for App C.2 fig EC.1: Nreps = %d, doslowpairs = %d.',settings.NUMOFREPS,DOSLOWPAIRS);
if DOMSGS disp(mymsg); end;
[ parameters ] = ProblemSetup3Arms();
%%% Figure parameters
i = 1; % calculate the EVI of arm i
if ~DOHIREPS
    mu0istotest = (-3:1:3)*sqrt(parameters.sigma0(i,i)); %prior mean values to calculate the EVI at
else
    % i = 1;
    mu0istotest = (-3:0.1:3)*sqrt(parameters.sigma0(i,i));
end
if DOSAVEFILES
    settings.foldertosave = strcat(pdecorr, 'Outputs\');
    settings.filename = 'AppC2FigEC1'; %name of the figure file if it will be saved
else
    settings.foldertosave = -1; % folder path to save results and figures, -1 to not save, example to save: strcat(pdecorr, 'Outputs\')
    settings.filename = ''; %name of the figure file if it will be saved
end
%%% Perform computations for figure and the plot the figure (saving if needed)
tic
GenerateEVIvsmu0Fig(mu0istotest, i, cfSoln, parameters, settings.foldertosave, settings.filename)
toc

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHUNK: Plotting EVI approximations across all arms in a problem
%% For EC Appendix C.2, Figure EC.2
% This section generates a graph that plots EVIs approximated by cPDELower, 
% cPDEUpper, cPDE, cKG1 and cKG* methods across a range of arms in the 
% syntetic problem.
% The user can control the problem parameters and which arms to include
% in the plot.

%%% Generate a problem
mymsg = sprintf('analysis for App C.2 fig EC.2: Nreps = %d, doslowpairs = %d.',settings.NUMOFREPS,DOSLOWPAIRS);
if DOMSGS disp(mymsg); end;
M = 80;
alphaval = 16; %for alpha = alphaval/(M-1)^2
pval = 4; %for P = 10^pval
[ parameters ] = ProblemSetupSynthetic( M, alphaval, pval);
if DOSAVEFILES
    settings.foldertosave = strcat(pdecorr, 'Outputs\');
    settings.filename = 'AppC2FigEC2'; %name of the figure file if it will be saved
else
    settings.foldertosave = -1; % folder path to save results and figures, -1 to not save, example to save: strcat(pdecorr, 'Outputs\')
    settings.filename = ''; %name of the figure file if it will be saved
end

% setup prior and observe 10 patients worth of data
rng default
thetav = mvnrnd(parameters.rpimu0,parameters.rpisigma0);
mucur = parameters.mu0;
sigmacur = parameters.sigma0;
for j = 1:10 % observe data from 10 patients to get some 'information' beyond prior
    i = randi([1 parameters.M]);
    y = normrnd(thetav(i),sqrt(parameters.lambdav(i))); 
    [mucur,sigmacur] = BayesianUpdate(mucur,sigmacur,i, y, parameters.lambdav(i));
end
parameters.mu0 = mucur;
parameters.sigma0 = sigmacur;

% check for some of the arms the value of information for each of those
% arms. generate the figure
armstotest = 1:5:parameters.M;
tic
warning('if a few warnings pop up for this current graph, it is not a bit deal - see comments in code for info');
GenerateEVIvsArmsFig(armstotest, cfSoln, parameters, settings.foldertosave, settings.filename)
toc
% NOTE: There might be a few 'warning: might try bigger initial number of
% grid...' - if graph looks fine, then no worries. if seems odd, try to
% increase the time horizon and the density of the grid in
% GeneratEVIvsArmsFig when calling cPDEUndis (longer number of steps
% lookahead, greater number of checks per standard dev will increase run
% time though - wihtout likely improving quality of allocation choice.
% points for w direction - however

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHUNK: Plotting EVI approximations and CPU times across multiple problems as function of number of arms, at time step 5
% Plot for Figures EC.3 and EC.4 in Appendix C.2
%
% This section generates two graphs. One depicts the EVI for a given arm i 
% using cPDELower, cPDEUpper, cPDE, cKG1 and cKG* methods. The other one
% plots the computation times of these EVI calculations.
% The values are plotted across different numbers of arms in the syntetic 
% problem. To obtain a prior with different priors for different arms, a 
% couple of arms are sampled and the prior is updated before the graph is 
% generated.
% The user can control the problem parameters, the number of arms to include
% in the plot, which arm to calculate EVI for, and how many samples are 
% taken (to update the prior) before calculating the EVI.

% For Figures EC3 and EC4 
mymsg = sprintf('analysis for App C.2 fig EC.3 and fig EC.4: Nreps = %d, doslowpairs = %d.',settings.NUMOFREPS,DOSLOWPAIRS);
if DOMSGS disp(mymsg); end;
%%% Problem parameters
Mvec = 5:5:100; % Number of arms in the problem to test over
alphaval = 100; %for alpha = alphaval/(M-1)^2
pval = 4; %for P = 10^pval
alttograph = 5; %which alterantive's EVI to calculate
periodtograph = 5; %calculate EVI after how many periods
if DOSAVEFILES
    settings.foldertosave = strcat(pdecorr, 'Outputs\');
    settings.filename = 'AppC2FigEC34'; %name of the figure file if it will be saved
else
    settings.foldertosave = -1; % folder path to save results and figures, -1 to not save, example to save: strcat(pdecorr, 'Outputs\')
    settings.filename = ''; %name of the figure file if it will be saved
end

%%% Generating the figures and saving files (if desired)
tic
GenerateEVIandCPUvsNumofArmsFig(Mvec, cfSoln, alttograph, periodtograph, alphaval, pval, settings.foldertosave, settings.filename)
toc

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHUNK: Plotting the power curve for a problem
%% FOr Online Companion Appendix D.1, Figure EC.5
% This section generates a graph that plots the probability of correct 
% selection of different policies against the difference between the
% mean of best arm and the second best arm (called delta) in a triangular 
% synthetic problem.
% The user can control the problem parameters, the range of deltas and the
% policies to be tested.

%%% Problem parameters
M = 21; % Number of arms in the problem to test over
deltastotest = 0.3:0.2:1.5; % controls the shape of the triangular curve
if DOHIREPS
    settings.NUMOFREPS = CGYHIREPS; % high number of replications for more accurate graphs - 1000 was used for paper
else
    settings.NUMOFREPS = 2*CGYLOWREPS; % low number of replications, for testing purposes.
end
if DOSAVEFILES
    settings.foldertosave = strcat(pdecorr, 'Outputs\');
    settings.filename = 'AppD1FigEC5'; %name of the figure file if it will be saved
else
    settings.foldertosave = -1; % folder path to save results and figures, -1 to not save, example to save: strcat(pdecorr, 'Outputs\')
    settings.filename = ''; %name of the figure file if it will be saved
end
mymsg = sprintf('analysis for App C.2 fig EC.5: Nreps = %d, doslowpairs = %d.',settings.NUMOFREPS,DOSLOWPAIRS);
if DOMSGS disp(mymsg); end;

%%% Policies to test
if ~DOHIREPS %%something resembling fig 5 with subset of procedures, shorter run times
    policies = 'aPDEUpperNO:sfixed:aCKGstar:sfixed:aPDELower:sfixed';
    rprob = -1*ones(3,1); % randomization probability, negative if deterministic
    rtype = 0*ones(3,1); %1 for uniform, 2 for TTVS
    Tfixed = [150,150,150]; %period to stop for fixed stopping policy, 0 if another stopping policy is used
else  % For Figure EC5
    policies = 'aPDEUpperNO:sfixed:aCKGstar:sfixed:aPDELower:sfixed:aPDEUpperNO:sPDEUpperNO:aCKGstar:sCKGstar:aPDELower:sPDELower';
    rprob = -1*ones(6,1); % randomization probability, negative if deterministic
    rtype = 0*ones(6,1); %1 for uniform, 2 for TTVS
    Tfixed = [150,150,150,0,0,0]; %period to stop for fixed stopping policy, 0 if another stopping policy is used
end

%%% Run simulation for all deltas and policies, then plot the figure.
all = struct();
tic
for i = 1:size(deltastotest,2)
    stepsize = deltastotest(i);
    [ parameters ] = ProblemSetupTriangular( M, stepsize);
    [ result ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
    all(i).simresults = result;
    all(i).deltaval = stepsize;
end
%%% Generating a figure
GeneratePowerCurve(all, settings.foldertosave, settings.filename);
toc

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHUNK: helping to figure out optimal fixed stopping time
%% In main paper,in table 2 we explore the concept of the 'best' fixed duration for a policy.
%% This section plots curves that helps one find, for a given setup, the optimal fixed duration stopping time.
% stopping time. the following code can be used to find the 'best' fixed
% duration stopping time for a given prior/ problem. 
%% Finding the best fixed stopping time using simulation for 80 arm problem


%Problem parameters  
M = 80;
alphaval = 100; %for alpha = alphaval/(M-1)^2
pval = 6; %for P = 10^pval
if DOSAVEFILES
    settings.foldertosave = strcat(pdecorr, 'Outputs\');
    settings.filename = 'helpSec64tab2'; %name of the figure file if it will be saved
else
    settings.foldertosave = -1; % folder path to save results and figures, -1 to not save, example to save: strcat(pdecorr, 'Outputs\')
    settings.filename = ''; %name of the figure file if it will be saved
end
tmpsettings = settings;
settings.NUMOFREPS = 50; % can set as wish

%%% Simulation details
% Consider setting a different seed, so that best fixed stopping time is
% coming from a different set of observations
% settings.seed = 6541235; % seed to be used for random number generation

% HERE we give optoin to do a test call of code which runs reasonably fast,
% then given another option for the example taht was used in section 6.2
% for the cKG allocation...
if ~DOHIREPS %%%  Policies to test - this is for a 'test run'
    policies = 'aCKG:sfixed'; % Policies to include - here test is for cKG allocation, wihtout randomization
    rprob = [-1]; % randomization probability, negative if deterministic
    rtype = [0]; %1 for uniform, 2 for TTVS
    Tfixed = [600]; %period to stop for fixed stopping policy, 0 if another stopping policy is used
else % For Section 6.2 - this is for what was done in section 6.2
    policies = 'aCKG:sfixed';
    rprob = [-1]; % randomization probability, negative if deterministic
    rtype = [0]; %1 for uniform, 2 for TTVS
    Tfixed = 3000; %10000; %period to stop for fixed stopping policy, 0 if another stopping policy is used
end

%%% Run simulation
mymsg = sprintf('miscellany code to plot E[OC], E[TC], E[SC]: Nreps = %d, doslowpairs = %d.',settings.NUMOFREPS,DOSLOWPAIRS);
if DOMSGS disp(mymsg); end;
tic
[ parameters ] = ProblemSetupSynthetic( M, alphaval, pval);
[ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
%%% Generating a figure
GenerateOCTCSCFig(simresults, settings.foldertosave, settings.filename);
toc
settings = tmpsettings;

