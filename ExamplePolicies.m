%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ExamplePolicies.m:
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PURPOSE: A macro to show how to call 
%% allocation policies and stopping times for an example problem instance.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SUMMARY OF THIS FILE
% This code provided as demonstrations of calling conventions for
% allocation policies and stopping times for a given problem instance. 
% The purpose is to show how to obtain
% 1) which arm an allocation policy suggests for sampling for a given
% problem instance, and 
% 2) whether a stopping time suggests stopping or continuing for a given
% problem instance.
% Allocation policies and stopping times are defined in the paper 
% 'Bayesian Sequential Learning for Clinical Trials of Multiple Correlated
% Medical Interventions' by Stephen E Chick, Noah Gans, Ozge Yapar, 
% manuscript accepted to appear in Management Science in 2021.
% The original version of the paper appeared at SSRN in 2018 and was 
% submitted to Management Science at the time. 

%% WORKFLOW
% This set of macros have been tested in Matlab 2021a.
% Please consult the README.md at the github repo for information about
% installing additional repos that are required for the code in this file
% to run properly.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GENERAL INFORMATION ABOUT CALLING AN ARM ALLOCATION POLICY AND A STOPPING TIME.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code provides an example calling convention for each supported 
% allocaiton rule and stopping time. 
% Each allocaiton rule and stopping time has an associated Matlab function,
% which can be found under the folder 'policies'.
%
%% Inputs for allocation policy functions: 
%% NOTE: Each function uses a subset of these inputs, see the example calling
%% conventions below for more details.
% undissol: variable which contains the standardized solution
%   for undiscounted problem.
% dissoln: variable which contains the standardized solution
%   for discounted problem.
% parameters: struct, problem parameters are included as fields
% muin: numerical vector that contains the current prior mean vector
% sigmain: numerical matrix that contains the current prior covariance matrix
% t: numerical scalar, current period, to keep track of the round robin
%   order of 'Equal' allocation rule.
% randprob: a numerical, value corresponds to the randomization probability of the
%  corresponding allocation policy. Use -1 for an allocation policy to be
%  deterministic, otherwise select a number between 0 and 1.
%   e.g., randprob = -1;
%   e.g., randprob = 0.2;
% randtype: a numerical, value corresponds to the randomization method: 
%  0 for nonrandomized, 1 for uniform, 2 for TTVS
%   e.g., randtype = 0; 
%   e.g., randtype = 2; 
% NOTE: For randomization to occur, both randtype and randprob need to
% indicate that randomization should be done. otherwise, a nonrandomized
% version of the allocation policy will be done.
%
%% Inputs for stopping time functions: 
%% NOTE: Each function uses a subset of these inputs, see the example calling
%% conventions below for more details. 
% undissol: variable which contains the standardized solution
%   for undiscounted problem.
% dissoln: variable which contains the standardized solution
%   for discounted problem.
% parameters: struct, problem parameters are included as fields 
% muin: numerical vector that contains the prior mean vector
% sigmain: numerical matrix that contains the prior covariance matrix
% Tfixed: the period at which the fixed stopping rule stops
% t: numerical scalar, current period
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INITIALIZATION TO SET PATHS AND LOAD IN PRECOMPUTED PDE FILES
%% Consult README.md to install the necessary code clusters (including the cKG 
%% package of Peter Frazier, and the pdestop package from Steve Chick
%% Also: create a SetPaths file to localize the code and initialize paths for your local installation.
%%% Status messages for code execution
DOMSGS = true;  % GLOBAL: Set to 'true' to get status messages for code execution, false otherwise.
mymsg='setting paths, loading precomputed PDE solution (see readme.md for explanation)';
if DOMSGS disp(mymsg); end;

%%% Set directories
SetPaths

%%% Load Standard Solutions
PDELocalInit;
[cgSoln, cfSoln, ~, ~] = PDELoadSolnFiles(PDEmatfilebase, false); %load solution files

%%% GLOBAL: Set to TRUE to get results with cPDE and other slow policies (be 
% prepared for long run times), set to false (recommended) to omit cPDE and 
% optimized cPDEUpper
DOSLOWPAIRS = true; 

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHUNK: SET THE EXAMPLE PROBLEM
mymsg = 'generating a problem instance';
if DOMSGS disp(mymsg); end;
%%% Problem parameters
M = 20; %number of arms
lambdav = 10^6*ones(M,1); %sampling variance
mu0=zeros(M,1); %vector of prior means
[sigma0,~] = PowExpCov(1/2,(M-1)/sqrt(16),2,M,1); %matrix of prior coviarance
P = 10^6; %population size
I = zeros(M,1); % fixed implementation cost
c = ones(M,1); %variable cost of sampling
delta = 1; %discount rate
rng default
thetav = mvnrnd(mu0,sigma0); % sample a ground truth from the prior distribution

%%% Call SetParametersFunc to setup a parameter structure and to check inputs
list = {'M',M,'lambdav',lambdav,'mu0',mu0,'sigma0',sigma0,'efns',lambdav./diag(sigma0)','P',P,'I',I,'c',c, 'delta', delta, 'thetav', thetav};
[ parameters, ~ ] = SetParametersFunc( list );

%%% Sample a couple of times from random arms and update the prior distribution based on those observations
mucur = parameters.mu0;
sigmacur = parameters.sigma0;
for j = 1:2
    i = randi([1 parameters.M]);
    y = normrnd(thetav(i),sqrt(parameters.lambdav(i))); 
    [mucur,sigmacur] = BayesianUpdate(mucur,sigmacur,i, y, parameters.lambdav(i));
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHUNK: CALLING ALLOCATION POLICIES
%% Deterministic Versions of Policies
mymsg = 'calculating the allocation decisions from different deterministic policies';
if DOMSGS disp(mymsg); end;
randtype = 0; % for these examples, do deterministic allocations. so randtype is set to 0, randprob set to -1 (below 0).
randprob = -1;
[ i ] = AllocationcPDEUpperNoOpt( cfSoln, cgSoln, parameters, mucur, sigmacur, randtype, randprob )
[ i ] = AllocationcPDELower( cfSoln, cgSoln, parameters, mucur, sigmacur, randtype, randprob )
[ i ] = AllocationVariance( parameters, mucur, sigmacur )
[ i ] = AllocationcKGstar( parameters, mucur, sigmacur, randtype, randprob )
[ i ] = AllocationcKGstarRatio( parameters, mucur, sigmacur, randtype, randprob )
[ i ] = AllocationcKG1(parameters, mucur, sigmacur, randtype, randprob )
[ i ] = AllocationcKG1Ratio(parameters, mucur, sigmacur, randtype, randprob )
[ i ] = AllocationIndESPb(parameters, mucur, sigmacur, randtype, randprob )
[ i ] = AllocationIndESPcapB(cfSoln, parameters, mucur, sigmacur, randtype, randprob )

t = 2; %current period, to keep track of the round robin order of 'Equal' allocation rule.
[ i ] = AllocationEqual(parameters, t )

if DOSLOWPAIRS % if you want cPDE and optimized cPDEUpper use the next line - be prepared for long run times...
    % Arms returned by below allocation policies are: 17, 14
    [ i ] = AllocationcPDE( parameters, mucur, sigmacur, randtype, randprob )
    [ i ] = AllocationcPDEUpperOpt( cfSoln, cgSoln, parameters, mucur, sigmacur, randtype, randprob )
end

%% Randomized Examples
mymsg = 'calculating the allocation decisions from a sample randomized policies';
if DOMSGS disp(mymsg); end;
rng default
randtype = 1; % uniform randomization with prob 0.2
randprob = 0.2;
[ i] = AllocationcPDELower( cfSoln, cgSoln, parameters, mucur, sigmacur, randtype, randprob  )
randtype = 2; % TTVS randomization with prob 0.2
randprob = 0.2;
[ i] = AllocationcPDELower( cfSoln, cgSoln, parameters, mucur, sigmacur, randtype, randprob  )
[ i ] = AllocationRandom(parameters )

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHUNK: CALLING STOPPING TIMES
mymsg = 'calculating the stopping decision from different dtopping times';
if DOMSGS disp(mymsg); end;

[ stop ] = StoppingcPDEUpperNoOpt( cfSoln, cgSoln, parameters,  mucur, sigmacur )
[ stop ] = StoppingcPDELower( cfSoln, cgSoln, parameters,  mucur, sigmacur )
[ stop ] = StoppingcKGstar( parameters, mucur, sigmacur )
[ stop ] = StoppingcKGstarRatio( parameters, mucur, sigmacur )
[ stop ] = StoppingcKG1( parameters, mucur, sigmacur )
[ stop ] = StoppingcKG1Ratio( parameters, mucur, sigmacur )
[ stop ] = StoppingIndESPb( parameters, mucur, sigmacur )
[ stop ] = StoppingcPDE(cfSoln, cgSoln, parameters, mucur, sigmacur)
[ stop ] = StoppingcPDEUpperOpt( cfSoln, cgSoln, parameters,  mucur, sigmacur )

Tfixed = 100; %the period at which the fixed stopping rule stops
t = 2; %current period
[ stop ] = StoppingFixed( Tfixed, t )
