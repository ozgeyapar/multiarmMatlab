%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ExamplecallingcPDEs.m:
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PURPOSE: A macro to show how to obtain EVI values estimated with cPDE, 
%% cPDELower and cPDEUpper  for an arm in an example undiscounted problem instance.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SUMMARY OF THIS FILE
% This code provided as demonstrations of calling conventions for
% cPDE, cPDELower and cPDEUpper approximations defined in the paper 
% 'Bayesian Sequential Learning for Clinical Trials of Multiple Correlated
% Medical Interventions' by Stephen E Chick, Noah Gans, Ozge Yapar, 
% manuscript accepted to appear in Management Science in 2021.
% The original version of the paper appeared at SSRN in 2018 and was 
% submitted to Management Science at the time. 
%
%% WORKFLOW
% This set of macros have been tested in Matlab 2021a.
% Please consult the README.md at the github repo for information about
% installing additional repos that are required for the code in this file
% to run properly.
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INITIALIZATION TO SET PATHS AND LOAD IN PRECOMPUTED PDE FILES
%% Consult README.md to install the necessary code clusters (including the cKG 
%% package of Peter Frazier, and the pdestop package from Steve Chick
%% Also: create a SetPaths file to localize the code and initialize paths for your local installation.
%%% Status messages for code execution
DOMSGS = true;  % GLOBAL: Set to 'true' to get status messages for code execution, false otherwise.
mymsg = 'setting paths, loading precomputed PDE solution (see readme.md for explanation)';
if DOMSGS disp(mymsg); end;

%%% Set directories
SetPaths

%%% Load Standard Solutions
PDELocalInit;
[cgSoln, cfSoln, ~, ~] = PDELoadSolnFiles(PDEmatfilebase, false); %load solution files

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHUNK: SET THE EXAMPLE PROBLEM
mymsg = 'generating a problem instance';
if DOMSGS disp(mymsg); end;
%%% Problem parameters
M = 20; %number of alternatives
I = zeros(M,1); %fixed implementation cost
P = 10^4; %number of patients in the population
lambdav = (0.1^2)*ones(M,1); %sampling variance
c = 1*ones(M,1); %cost per sample
delta = 1; %undiscounted
mu0 = zeros(M,1);
alphaval = 100;
beta0 = 1/2;
[sigma0,~] = PowExpCov(beta0,(M-1)/sqrt(alphaval),2,M,1);
rng default
thetav = mvnrnd(mu0,sigma0); % sample a ground truth from the prior distribution

%%% Call SetParametersFunc to setup the struct and check inputs
list = {'M',M,'lambdav',lambdav,'mu0',mu0,'sigma0',sigma0,'efns',lambdav./diag(sigma0)','P',P,'I',I,'c',c, 'delta', delta, 'thetav', thetav};
[ parameters, ~ ] = SetParametersFunc( list );

%%% Sample a couple of times to get an example prior distribution
mucur = parameters.mu0;
sigmacur = parameters.sigma0;
for j = 1:3
    i = randi([1 parameters.M]);
    y = normrnd(thetav(i),sqrt(parameters.lambdav(i))); 
    [mucur,sigmacur] = BayesianUpdate(mucur,sigmacur,i, y, parameters.lambdav(i));
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHUNK: GETTING EVI APPROXIMATION FOR ARM i USING cPDELower, cPDEUpper and cPDE
i = 5; %get evi of arm i

% To get the evi from cPDELower and cPDEUpper for an undiscounted problem
mymsg = sprintf('calculating EVI using cPDELower approximation for arm %d',i);
if DOMSGS disp(mymsg); end;
evilower = cPDELowerUndis( cfSoln, parameters, mucur, sigmacur, i ) % returns 132.2694

mymsg = sprintf('calculating EVI using cPDEUpper (equal weights) approximation for arm %d',i);
if DOMSGS disp(mymsg); end;
eviupper = cPDEUpperUndisNoOpt( cfSoln, parameters, mucur, sigmacur, i ) % returns 132.5960

mymsg = sprintf('calculating EVI using cPDE approximation for arm %d',i);
if DOMSGS disp(mymsg); end;
%  To get the evi from cPDE for an undiscounted problem
evi = cPDEUndis( parameters, mucur, sigmacur, i ) % returns 132.4101

