% ReplicateFiguresRev1.m:
% PURPOSE: A macro with the code required to:
%   1. Set up the path structure in matlab and generate a folder to save 
%   the simulation results and figures.
%   2. Generate the figures and tables for correlated multiarm paper.
%
% OUTPUTS: For each section of the paper Chich, Gans, Yapar (2020), 
% simulation results (.mat) and figures (.fig and .eps) will be saved in 
% folder Outputs\Sectionname where Sectionname is the
% approprite section number for that figure or table.
%
% WORKFLOW: SetSolFiles.m and SetRandomVars.m should be run once per 
% machine beforehand to generate the standardized PDE solution to be used
% for cPDELower and cPDEUpper and to generate the random variables to be
% used in the simulation replications.

%% SET PATHS
SetPaths

%% Figure 1 in Section 6.2
% Folder to save results
sec62folder = strcat(pdecorr, 'Outputs\Sec62\'); 
mkdir(sec62folder);

% Generate Figure 1
SimforFig1
PlotFig1

%% Table 1 in Section 6.3
% Folder to save results
sec63folder = strcat(pdecorr, 'Outputs\Sec63\'); 
mkdir(sec63folder);

% Generate Table 1
SimforTab1
MergeandGenerateTable1

% To generate the graphs that support the 'best' fixed T in Table 1
FindingtheFixedTforTable1

%% Section 6.4
% Folder to save results
sec64folder = strcat(pdecorr, 'Outputs\Sec64\');
mkdir(sec64folder);

% Generate Table 2
SimforTab2
MergeandGenerateTable2

% Generate Figure 2
GenerateFig2

% To generate Figure 3 (the graphs that support the 'best' fixed T in Table 2)
FindingtheFixedTforTable2

%% Figure 4 in Section 7.2
% Equal, Random, Variance and cPDELower data is the same as the data from
% Figure 1, so I am not repeating the code here. Run this after running the
% Figure 1 portion above.

% Folder to save results
sec72folder = strcat(pdecorr, 'Outputs\Sec72\'); 
mkdir(sec72folder);

% Generate Figure 1
SimforFig4
PlotFig4

%% Appendix C.1
% Folder to save results
appc1folder = strcat(pdecorr, 'Outputs\AppC1\'); 
mkdir(appc1folder);

% Generate Table EC2 in App C1
SimforTabEC2
MergeandGenerateTableEC2

%% Appendix C.2 and C.3
% Folder to save results
appc23folder = strcat(pdecorr, 'Outputs\AppC2andC3\'); 
mkdir(appc23folder);

% Generate Figure EC1-EC4
PlotsAppC

%% Appendix D
% Folder to save results
appdfolder = strcat(pdecorr, 'Outputs\AppD1\');
mkdir(appdfolder);

% Generate Figure EC5
SimforAppD1
PlotFigEC5
