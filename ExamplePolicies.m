% ExamplePolicies.m:
% PURPOSE: A macro to show how to call some allocation polciies and 
% stopping times for the example problem from ExampleProblemSetup.m.
%
% WORKFLOW: SetSolFiles.m should be run once per machine beforehand to 
% generate the standardized PDE solution.
%
%% SET THE EXAMPLE PROBLEM
ExampleProblemSetup

%% Current prior distribution
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
% Load general standardized PDE solution 
PDELocalInit;
[cgSoln, cfSoln, cgOn, cfOn] = PDELoadSolnFiles('pdestop/Matfiles/', false); %load solution files

% Call the allocation policy, parameters variable is defined 
% in ExampleProblemSetup.m
[ i] = AllocationIndESPcapB( cfSoln, parameters, mucur, sigmacur )
[ i] = AllocationcPDELower( cfSoln, cgSoln, parameters, mucur, sigmacur )
[ i] = AllocationcPDELowerTTVS( cfSoln, cgSoln, parameters, mucur, sigmacur, 0.2 )
[ i] = AllocationcPDELowerUnif( cfSoln, cgSoln, parameters, mucur, sigmacur, 0.2 )
[ i ] = AllocationcPDEUpperNoOpt( cfSoln, cgSoln, parameters, mucur, sigmacur )
[ i ] = AllocationcPDEUpperOpt( cfSoln, cgSoln, parameters, mucur, sigmacur )

%% Stopping times that use standardized solution
% General standardized PDE solution is loaded above
[ stop ] = StoppingcPDEHeu( cfSoln, cgSoln, parameters, mucur, sigmacur, 2)
[ stop ] = StoppingcPDELower( cfSoln, cgSoln, parameters, mucur, sigmacur )
[ stop ] = StoppingcPDEUpperNoOpt( cfSoln, cgSoln, parameters, mucur, sigmacur )
[ stop ] = StoppingcPDEUpperOpt( cfSoln, cgSoln, parameters, mucur, sigmacur)
