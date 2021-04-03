% ExamplecallingcPDEs.m:
% PURPOSE: A macro to show how to get EVI values estimated with cPDE, 
% cPDELower and cPDEUpper, how to get the arm from cPDE, cPDELower and 
% cPDEUpper allocation policies, and how to get whether cPDE, cPDELower and 
% cPDEUpper stopping times stop or continue for an example problem. 
%
% WORKFLOW: SetSolFiles.m should be run once per machine beforehand to 
% generate the standardized PDE solution to be used for cPDELower and 
% cPDEUpper.

%% DEFINE THE EXAMPLE PROBLEM
M = 20; %number of alternatives
parameters.M = M;
parameters.I = zeros(M,1); %fixed implementation cost
parameters.P = 10^4; %number of patients in the population
parameters.lambdav = (0.1^2)*ones(1,M); %sampling variance
parameters.c = 1*ones(1,M); %cost per sample
parameters.delta = 1; %undiscounted

%to generate a prior distribution
mu0 = zeros(M,1);
rng default
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
thetav = mvnrnd(mu0,sigma0);
mucur = mu0;
sigmacur = sigma0;
for j = 1:3
    i = randi([1 M]);
    y = normrnd(thetav(i),sqrt(parameters.lambdav(i))); 
    [mucur,sigmacur] = BayesianUpdate(mucur,sigmacur,i, y, parameters.lambdav(i));
end

%% Getting EVI value of arm i using cPDELower and cPDEUpper
i = 5; %get evi of arm i
% Load general standardized PDE solution 
PDELocalInit;
[cgSoln, cfSoln, cgOn, cfOn] = PDELoadSolnFiles(PDEmatfilebase, false); %load solution files

% To get the evi from cPDELower and cPDEUpper for an undiscounted problem
evilower = cPDELowerUndis( cfSoln, parameters, mucur, sigmacur, i )
eviupper = cPDEUpperUndisNoOpt( cfSoln, parameters, mucur, sigmacur, i )

%% Getting EVI value of arm i using cPDE
evi = cPDEUndis( parameters, mucur, sigmacur, i )

%% Allocation policies (returns the index of the arm)
allpollower = AllocationcPDELower( cfSoln, cgSoln, parameters, mucur, sigmacur ) %cPDELower
allpolupper = AllocationcPDEUpperNoOpt( cfSoln, cgSoln, parameters, mucur, sigmacur ) %cPDEUpper without optimization
allpolcpde = AllocationcPDE( parameters, mucur, sigmacur ) %cPDE

%% Stopping times (1 for stop, 0 for continue)
stoppollower = StoppingcPDELower( cfSoln, cgSoln, parameters, mucur, sigmacur ) %cPDELower
stoppolupper = StoppingcPDEUpperNoOpt( cfSoln, cgSoln, parameters, mucur, sigmacur ) %cPDEUpper without optimization
stoppolcpdeheu = StoppingcPDEHeu( cfSoln, cgSoln, parameters, mucur, sigmacur, 1) %cPDE

