% ReplicateCGY.m:
% PURPOSE: A macro with the code required to:
%   1. Set up the path structure in matlab and generate a folder to save 
%   the simulation results and figures.
%   2. Generate the figures and tables for correlated multiarm paper.

%% Set Paths
SetPaths

%% Load Standard Solutions
PDELocalInit;
[cgSoln, cfSoln, ~, ~] = PDELoadSolnFiles(PDEmatfilebase, false); %load solution files

%% Figure 1 in Section 6.2
%Initilization
sec62folder = strcat(pdecorr, 'Outputs\Sec62\'); % Folder to save results
NUMOFREPS = 3; %number of replications for the simulation, 1000 in the paper
% policies = 'aEqual:aESPB:aKGStarLower:aVar:aCKG:aKGStarLower:aPDEUpperNO:aPDELower:aPDE'; %allocation policies to include
% priorind = [0,1,0,0,0,0,0,0,0,0]; %1 if the allocation policy uses independent prior
% rand = [-1,-1,-1, 1, -1, -1, -1, -1, -1]; % randomization probability, negative if deterministic
policies = 'aCKG:aKGStarLower:aPDELower'; %allocation policies to include
priorind = [0,0,0]; %1 if the allocation policy uses independent prior
rand = [-1,1,-1]; % randomization probability, negative if deterministic
Tfixed = 100; % number of periods 

%Problem parameters  
alphaval = 100; %for alpha = 100/(M-1)^2
pval = 6; %for P = 10^6
figurename = strcat('sec62-P',num2str(pval),'-alpha',num2str(alphaval));

%Run simulation
[ fig1results ] = SimFig1( cgSoln, cfSoln, NUMOFREPS, policies, priorind, rand, alphaval, pval, Tfixed, sec62folder );

% Generating and saving the figure
GenerateFig1(fig1results, strcat(sec62folder,figurename), 0);

% Calculate CI at a given t
givent = 100;
[meandOC, sedOCa] = CalculateCIofOC( fig1results, givent );