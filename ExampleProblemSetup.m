% ExampleProblemSetup.m:
% PURPOSE: A macro to show how to setup the 'parameters' input for 
% functions in the policies folder, for a problem with a given prior 
% distribution and that generates the thetas randomly from a given prior
%% 
%% SET PATHS
SetPaths
%%
%%% Problem parameters
M = 20; %number of arms
lambdav = 10^6*ones(1,M); %sampling variance
mu0=zeros(M,1); %vector of prior means
[sigma0,~] = PowExpCov(1/2,(M-1)/sqrt(16),2,M,1); %matrix of prior coviarance
P = 10^6; %population size
I = zeros(M,1); % fixed implementation cost
c = ones(1,M); %variable cost of sampling
Tfixed = 200; % Fixed sample size that will be used by the fixed stopping time
delta = 1; %discount rate

%%% Some simulation details that can be changed are summarized below. 
%%% If you change any of these below values, remember to add them to the 
%%% variable called list below.

%randomps = 0; %Random sample at every perfect square used if 1, default is 0
%crn = 1; %common random numbers is implemented if 1, default is 1

% Ground truth used in the simulation is generated from prior 
% N(rpimu0, rpisigma0) if thetav is not specified. rpimu0 = mu0 and 
% rpisigma0 = sigma0 by default but can be changed.
%rpimu0 = mu0;
%rpisigma0 = sigma0;

% If you want to have the same ground truth across 
% simulationreplications, define thetav intead of rpimu0 and rpisigma0
%thetav = 2000*((1.65/3)*(0:0.4:8) - (1.65/36)*(0:0.4:8).^2);

% Sampling variance used by the policies and actual sampling variance used
% to simulate samples can be different, they are same by default, use 
% naturelambdav if you want it to be different.
%naturelambdav = 4.5*(2000^2); 

% If you want to use a differnet set of random variables to run the 
% simulation, give the directory of new random variables to 
% matlocfile variable, directory has to be a subdirectory of multiarmMatlab

%%% Call SetParametersFunc to setup the struct and check inputs
list = {'M',M,'lambdav',lambdav,'mu0',mu0,'sigma0',sigma0,'efns',lambdav./diag(sigma0)','P',P,'I',I,'c',c, 'delta', delta, 'pdetieoption', 'kgstar', 'Tfixed', Tfixed};
[ parameters, ~ ] = SetParametersFunc( list );