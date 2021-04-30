% ExamplePolicies.m:
% PURPOSE: A macro to show how to call some allocation polciies and 
% stopping times for an example problem.
%
% WORKFLOW: SetSolFiles.m should be run once per machine beforehand to 
% generate the standardized PDE solution.
%
%% INITIALIZATION
%%% Set directories
SetPaths

%%% Load Standard Solutions
PDELocalInit;
[cgSoln, cfSoln, ~, ~] = PDELoadSolnFiles(PDEmatfilebase, false); %load solution files

%% SET THE EXAMPLE PROBLEM
%%% Problem parameters
M = 20; %number of arms
lambdav = 10^6*ones(1,M); %sampling variance
mu0=zeros(M,1); %vector of prior means
[sigma0,~] = PowExpCov(1/2,(M-1)/sqrt(16),2,M,1); %matrix of prior coviarance
P = 10^6; %population size
I = zeros(M,1); % fixed implementation cost
c = ones(1,M); %variable cost of sampling
delta = 1; %discount rate

%%% Call SetParametersFunc to setup the struct and check inputs
list = {'M',M,'lambdav',lambdav,'mu0',mu0,'sigma0',sigma0,'efns',lambdav./diag(sigma0)','P',P,'I',I,'c',c, 'delta', delta};
[ parameters, ~ ] = SetParametersFunc( list );

%%% Sample a couple of times to get an example prior distribution
rng default
thetav = mvnrnd(parameters.mu0,parameters.sigma0);
mucur = parameters.mu0;
sigmacur = parameters.sigma0;
for j = 1:2
    i = randi([1 M]);
    y = normrnd(thetav(i),sqrt(parameters.lambdav(i))); 
    [mucur,sigmacur] = BayesianUpdate(mucur,sigmacur,i, y, parameters.lambdav(i));
end

%% Allocation policies that use standardized solution
% arms returned by below allocation policies are: 19, 1, 19, 1, 7, 6
rng default
[ i] = AllocationIndESPcapB( cfSoln, parameters, mucur, sigmacur, 0, -1 ) % deterministic
[ i] = AllocationcPDELower( cfSoln, cgSoln, parameters, mucur, sigmacur, 0, -1) % deterministic
[ i] = AllocationcPDELower( cfSoln, cgSoln, parameters, mucur, sigmacur, 1, 0.2 )% uniform randomization with prob 0.2
[ i] = AllocationcPDELower( cfSoln, cgSoln, parameters, mucur, sigmacur, 1, 0.4 )% TTVS randomization with prob 0.2
[ i ] = AllocationcPDEUpperNoOpt( cfSoln, cgSoln, parameters, mucur, sigmacur, 0, -1 ) % deterministic
[ i ] = AllocationcPDEUpperOpt( cfSoln, cgSoln, parameters, mucur, sigmacur, 0, -1) % deterministic

%% Stopping times that use standardized solution
% all stopping policies should return 0 (do not stop)
[ stop ] = StoppingcPDEHeu( cfSoln, cgSoln, parameters, mucur, sigmacur)
[ stop ] = StoppingcPDELower( cfSoln, cgSoln, parameters, mucur, sigmacur )
[ stop ] = StoppingcPDEUpperNoOpt( cfSoln, cgSoln, parameters, mucur, sigmacur )
[ stop ] = StoppingcPDEUpperOpt( cfSoln, cgSoln, parameters, mucur, sigmacur)
