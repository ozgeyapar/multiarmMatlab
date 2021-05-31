% ReplicateCGY.m:
% PURPOSE: A macro with the code required to generate the figures and tables
% for correlated multiarm paper (Chick, Gans, Yapar (2020)).
%%
%%%% Explanations for the options for the simulation rules and policies %%%%
%%% %%%  Policies to test: a sequence of allocation rule/stopping rule
    %%%  combinations - in the following - there are 4 policies, each with
    %%%  fixed sample size stopping rule
    % e.g. policies = 'aEqual:sfixed:aCKG:sfixed:aPDELower:sfixed:aPDELower:sfixed';
    %%% Here is the list of allocation and stopping policies that can be tested
    %%% with the names to call them
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
    
    %%%  Randomization probabilities for each policy: a numerical array,
    %%%  each value corresponds to the randomization probability of the
    %%%  corresponding allocation policy (according to the order given in 
    %%%  'policies' above). Use -1 for an allocation policy to be
    %%%  deterministic, otherwise select a number between 0 and 1.
    % e.g., rprob = [-1, -1, 0.2, -1];
    
    %%%  Randomization types for each policy: a numerical array,
    %%%  each value corresponds to the randomization method used (according
    %%%  to the order given in 'policies' above). 0 for nonrandomized, 1 
    %%%  for uniform, 2 for TTVS
    % e.g., rtype = [0, 0, 1, 0]; 
    
    %%%  Fixed stopping time: a numerical array, each value corresponds to
    %%%  the period to stop for fixed stopping policy (according
    %%%  to the order given in 'policies' above). 0 can be used if 
    %%%  a different stopping time is used
    % e.g., Tfixed = [20,20,20,20];
    
    %%%  Type of the prior to be used (if pilot study data is used to fit a 
    %%%  prior): CGY (2020) introduced two modifications to
    %%%  to the prior distribution obtained by using the Gaussian process 
    %%%  regression (GPR) called Robust and Tilted. Option called priortype 
    %%% controls whether the prior from the GPR or one of the two 
    %%% modifications are used. Use 'gpr' to use the GPR prior as it is, use
    %%% 'robust' for Robust prior and or use 'tilted' for Tilted prior.
    % e.g., priortype = 'gpr'; 
    %%% Option graphforprior controls whether a figure that shows the prior 
    %%% for each pilot study is generated or not.
    % e.g., graphforprior = 1; %if 1, generates , 0 for no figure.
    %%% Option zalpha is the fudge factor for uncertainty that is used
    %%%  to control how tilted and robust priors modify the prior mean.
    % e.g., zalpha = 1/2;


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
DOPAPER = false; % Set to TRUE to get figures/graphs for paper, FALSE to get sample runs with simpler graphs
DOHIREPS = false; % Set to TRUE to get lots of replications, FALSE to get small number of reps for testing
    CGYHIREPS = 16; % was 1000 for final paper. can set lower for testing.
    CGYLOWREPS = 2; % small number of replications so runs don't take too long - for debug or checking install
DOSAVEFILES = true; % set to true to save results and figures to file, FALSE if files are not to be saved. 
    %if saved, need to set foldertosave and filename fields of the settings
    %field as denoted below, e.g. settings.foldertosave = strcat(pdecorr,
    %'Outputs\') settings.filename = 'myfigs'.
DOSLOWPAIRS = false; % Set to TRUE to get graphs with cPDE and other slow policies (be prepared for VERY long run times), set to false (recommended) to omit cPDE from analysis

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
M = 80; % number of arms in the problem
alphaval = 100; %for alpha = alphaval/(M-1)^2
pval = 6; %for P = 10^pval

if ~DOPAPER
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
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CHUNK 2: FIGURE 1 of SECTION 6.2 and FIGURE 2 of SECTION 6.4

%Problem parameters  
M = 80;
alphaval = 100; %for alpha = alphaval/(M-1)^2
pval = 6; %for P = 10^pval

if DOPAPER
    % For Figure 1 in Section 6.2 
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
    Tfixed = 20*ones(numrulepairs,1);%100*ones(9,1); %period to stop for fixed stopping policy, 0 if another stopping policy is used
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
    numrulepairs = (1+count(policies,':'))/2;
    rprob = [-1,-1,-1,0.4,0.2,0.4,0.2,-1]; % randomization probability, negative if deterministic
    rtype = [0,0,0, 1, 1, 2, 2, 0]; %1 for uniform, 2 for TTVS
        
    Tfixed = 10*ones(numrulepairs,1);%100*ones(8,1); %period to stop for fixed stopping policy, 0 if another stopping policy is used
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
    %%% Can be opened with openvar('toCopy') command to be viwed as a table.
    if DOSAVEFILES
%        foldertosave = strcat(pdecorr, 'Outputs\');
        CheckandCreateDir( settings.foldertosave )
        filename = 'testTable'; %name of the excel file if it will be saved
        writecell(testTable,strcat(settings.foldertosave, filename, '.xls'))
    else
        openvar('testTable')
    end
    toc(startt)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For Table 1 in Section 6.3
if DOPAPER
    policies = 'aCKG:sfixed:aCKG:sfixed:aCKG:sPDEUpperNO:aCKG:sPDEHeu:aCKG:sfixed:aCKG:sPDELower:aCKG:sCKGstar:aPDELower:sPDEUpperNO:aPDELower:sPDEHeu:aPDELower:sfixed:aPDELower:sPDELower:aPDELower:sfixed:aPDELower:sCKGstar:aVar:sfixed:aVar:sfixed'; % policies to include
    %numrulepairs = (1+count(policies,':'))/2;
    rprob = -1*ones(15,1); % randomization probability, negative if deterministic
    rtype = 0*ones(15,1); %1 for uniform, 2 for TTVS
    Tfixed = [493,200,0,0,130,0,0,0,0,200,0,150,0,200,150]'; %period to stop for fixed stopping policy, 0 if another stopping policy is used
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
    [ table1sec63 ] = GenerateTCTable( simresults, settings.foldertosave, settings.filename );
    %openvar('table1sec63')
    if DOSAVEFILES
        CheckandCreateDir( settings.foldertosave )
        filename = 'table1sec63'; %name of the excel file if it will be saved
        writecell(table1sec63, strcat(settings.foldertosave, filename, '.xls'))
    else
        openvar('table1sec63')
    end
    toc(startt)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For Table EC2 in Appendix C.1

%SEC: THIS BLOCK IS STILL IN TESTING
if DOPAPER
    pval = 4; %for P = 10^4
    if DOSLOWPAIRS % if all pairs desired... be prepared for LONG run unless analysis is parallelized
        policies = 'aPDEUpper:sCKGstar:aPDEUpperNO:sCKGstar:aPDEUpper:sPDELower:aPDEUpperNO:sPDELower'; % policies to include
    else % remove the super slow aPDEUpper computation
        policies = 'aPDEUpperNO:sCKGstar:aPDEUpperNO:sPDELower'; % policies to include
    end
    numrulepairs = (1+count(policies,':'))/2;
    rprob = -1*ones(numrulepairs,1); % randomization probability, negative if deterministic
    rtype = 0*ones(numrulepairs,1); %1 for uniform, 2 for TTVS
    Tfixed = 0*ones(numrulepairs,1); %[0,0,0,0]'; %period to stop for fixed stopping policy, 0 if another stopping policy is used

    %%% Run simulation
    [ parameters ] = ProblemSetupSynthetic( M, alphaval, pval);
    [ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
    %%% Generating a table to compare policies
    [ tableEC2 ] = GenerateTCTable( simresults, settings.foldertosave, settings.filename );
    if DOSAVEFILES
        CheckandCreateDir( settings.foldertosave )
        filename = 'tableEC2'; %name of the excel file if it will be saved
        writecell(tableEC2, strcat(settings.foldertosave, filename, '.xls'))
    else
        openvar('tableEC2')
    end    
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
    Tfixed = 20*ones(size(rtype)); %period to stop for fixed stopping policy, 0 if another stopping policy is used
    %%% Run simulation
    startt = tic;
    [ parameters ] = ProblemSetupDoseCaseStudy(priortype, graphforprior, zalpha);
    [ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
    %%% Generating a table to compare policies
    [ testTab2 ] = GenerateTCTable( simresults, settings.foldertosave, settings.filename );
    if DOSAVEFILES
        CheckandCreateDir( settings.foldertosave )
        filename = 'testTab2'; %name of the excel file if it will be saved
        writecell(testTab2, strcat(settings.foldertosave, filename, '.xls'))
    else
        openvar('testTab2')
    end      
    toc(startt)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TO HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% For Table 2 in Section 6.4
%Problem parameters  
priortypestodo = {'gpr', 'robust', 'tilted'};
priortype = 'gpr'; %'gpr', 'robust' or 'tilted'
graphforprior = 1; %if 1, generates a figure that shows the prior for each pilot study, 0 for no figure.
zalpha = 1/2; % used in robust and tilted priors

%%%  Policies to test
if DOPAPER
    if DOSLOWPAIRS
        policies = 'aCKG:sfixed:aPDELower:sfixed:aVar:sfixed:aCKG:sPDEHeu:aCKG:sPDEUpperNO:aPDELower:sPDEUpperNO:aPDELower:sPDEHeu'; % policies to include
    else
        policies = 'aCKG:sfixed:aPDELower:sfixed:aVar:sfixed:aCKG:sPDEUpperNO:aPDELower:sPDEUpperNO'; % policies to include
    end
    numrulepairs = (1+count(policies,':'))/2;
    rprob = -1*ones(numrulepairs,1); % randomization probability, negative if deterministic
    rtype = 0*ones(numrulepairs,1); %1 for uniform, 2 for TTVS
    CheckandCreateDir( settings.foldertosave );
    
    %%% Run simulations
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
        [ parameters ] = ProblemSetupDoseCaseStudy(priortype, graphforprior, zalpha);
        simresults=eye(5+i);
        [ simresults ] = SimSetupandRunFunc( cgSoln, cfSoln, parameters, policies, rtype, rprob, Tfixed, settings);
        %%% Generating a table to compare policies
        [ testTab2 ] = GenerateTCTable( simresults, settings.foldertosave, settings.filename );
        if DOSAVEFILES
            CheckandCreateDir( settings.foldertosave )
            filename = 'Table2Sec64-'; %name of the excel file if it will be saved
            writecell(testTab2, strcat(settings.foldertosave, filename, priortype, '.xls'))
        else
            openvar('testTab2')
        end      
    end
    toc(startt)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Plotting EVI approximations against different prior means
% This section generates a graph that plots EVIs approximated by cPDELower, 
% cPDEUpper, cPDE, cKG1 and cKG* methods for a range of mu_0^i values of arm i
% in a three-arm problem.
% The user can control the value of i (1,2 or 3) and the range of mu_0^i's
% to be plotted.

%%% Generate a problem with 3 arms
[ parameters ] = ProblemSetup3Arms();

%%% Figure parameters
i = 1; % calculate the EVI of arm i
mu0istotest = (-3:1:3)*sqrt(parameters.sigma0(i,i)); %prior mean values to calculate the EVI at

% For Figure EC1
% i = 1;
% mu0istotest = (-3:0.1:3)*sqrt(parameters.sigma0(i,i));

%%% Generating the figure
GenerateEVIvsmu0Fig(mu0istotest, i, cfSoln, parameters, settings.foldertosave, settings.filename)

%% Plotting EVI approximations across all arms in a problem
% This section generates a graph that plots EVIs approximated by cPDELower, 
% cPDEUpper, cPDE, cKG1 and cKG* methods across a range of arms in the 
% syntetic problem.
% The user can control the problem parameters and which arms to include
% in the plot.

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
% This section generates a graph that plots the probability of correct 
% selection of different policies against the difference between the
% mean of best arm and the second best arm (called delta) in a triangular 
% synthetic problem.
% The user can control the problem parameters, the range of deltas and the
% policies to be tested.

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