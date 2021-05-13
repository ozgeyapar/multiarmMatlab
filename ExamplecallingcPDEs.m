% ExamplecallingcPDEs.m:
% PURPOSE: A macro to show how to get EVI values estimated with cPDE, 
% cPDELower and cPDEUpper for an example problem. 

%% INITIALIZATION
%%% Set directories
SetPaths

%%% Load Standard Solutions
PDELocalInit;
[cgSoln, cfSoln, ~, ~] = PDELoadSolnFiles(PDEmatfilebase, false); %load solution files
%% DEFINE THE EXAMPLE PROBLEM
M = 20; %number of alternatives
I = zeros(M,1); %fixed implementation cost
P = 10^4; %number of patients in the population
lambdav = (0.1^2)*ones(M,1); %sampling variance
c = 1*ones(M,1); %cost per sample
delta = 1; %undiscounted

%to generate a prior distribution
mu0 = zeros(M,1);
alphaval = 100;
beta0 = 1/2;
[sigma0,~] = PowExpCov(beta0,(M-1)/sqrt(alphaval),2,M,1); %I use PowExpCov 
% from matlabKG folder which is equivalent to the below for-loop technically,
% but PowExpCov is more accurate as M gets larger.
% % alpha0 = alphaval/(M-1)^2;
% % for i=1:M
% %    for j=1:M
% %        sigma0(i,j) = beta0*exp(-alpha0*(i-j)^2);
% %    end
% % end

%%% Call SetParametersFunc to setup the struct and check inputs
list = {'M',M,'lambdav',lambdav,'mu0',mu0,'sigma0',sigma0,'efns',lambdav./diag(sigma0)','P',P,'I',I,'c',c, 'delta', delta};
[ parameters, ~ ] = SetParametersFunc( list );

%%% Sample a couple of times to get an example prior distribution
rng default
thetav = mvnrnd(mu0,sigma0);
mucur = mu0;
sigmacur = sigma0;
for j = 1:3
    i = randi([1 M]);
    y = normrnd(thetav(i),sqrt(parameters.lambdav(i))); 
    [mucur,sigmacur] = BayesianUpdate(mucur,sigmacur,i, y, parameters.lambdav(i));
end

%% Getting EVI value of arm i using cPDELower, cPDEUpper and cPDE
i = 5; %get evi of arm i

% To get the evi from cPDELower and cPDEUpper for an undiscounted problem
evilower = cPDELowerUndis( cfSoln, parameters, mucur, sigmacur, i ) % returns 132.2694
eviupper = cPDEUpperUndisNoOpt( cfSoln, parameters, mucur, sigmacur, i ) % returns 132.5960

%  To get the evi from cPDE for an undiscounted problem
evi = cPDEUndis( parameters, mucur, sigmacur, i ) % returns 132.4101

