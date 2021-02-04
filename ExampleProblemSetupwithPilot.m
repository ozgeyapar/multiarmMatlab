% ExampleProblemSetupwithPilot.m:
% PURPOSE: A macro to show how to setup the 'parameters' and 
% 'samplingparameters' inputs to simulate a problem that uses a given thetav
% and simulates a pilot data to estimate a prior distribution.
%
% WORKFLOW: Call SetRandomVars.m before to pregenerate the standard normal
% random variables that will be used in the pilot
%
%% 
%% SET PATHS
SetPaths
%%% Problem parameters
doses = 0:0.5:8; %dose values of each arm
M = size(doses,2); %number of arms
thetav = 2000*((1.65/3)*doses - (1.65/36)*doses.^2); %ground truth to be used
naturelambda = 4.5*(2000^2); %true sampling variance
naturelambdav = naturelambda*ones(1,M); %true sampling variance vector
P = 2000000*0.1; %population size
I = zeros(M,1);  %fixed implementation cost
c = 8500*ones(1,M); %variable cost of sampling
delta=1; % undiscounted

Tfixed = 1000; % Fixed sample size that will be used by the fixed stopping time

lambdatemp = ones(1,M); %will be replaced with the value estimated from the pilot
sigma0temp = eye(M); %will be replaced with the value estimated from the pilot
mu0temp = zeros(M,1); %will be replaced with the value estimated from the pilot

list = {'thetav',thetav,'naturelambdav',naturelambdav,'M',M,'lambdav',lambdatemp,'mu0',mu0temp,'sigma0',sigma0temp,'efns',lambdatemp./diag(sigma0temp)','P',P,'I',I,'c',c, 'delta', delta, 'pdetieoption', 'kgstar', 'Tfixed', Tfixed, 'sampleeach',1};
[ parameters, ~ ] = SetParametersFunc( list );

%%% Pilot data generation and prior estimation
samplingparameters.doses = doses;
samplingparameters.indicestosample = [1,5,9,13,17]; %which arms to sample in the pilot
samplingparameters.N = 10; %how many samples to take from each arm
samplingparameters.priortype = 'gpr'; %'gpr', 'robust' or 'tilted'
samplingparameters.priorind = 0; %if 1, returns the independent version of the prior
samplingparameters.graphforprior = 1; %if 1, plots gpr, robust and tilted priors
samplingparameters.zalpha = 1/2; %z value used for the tilted and robust priors
j = 1; %which row of doserespv will be used
% This function might throw errors if 
% NBASE != 10 and number of doses != 5.
[ parameters.mu0, parameters.sigma0, parameters.lambdav, parameters.efns, parameters.pilotdetails ] = SimPilotandDetPriorSec64( parameters, samplingparameters, j);
