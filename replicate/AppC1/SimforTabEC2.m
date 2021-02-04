% SimforTabEC2.m:
% PURPOSE: A macro with the code to generate the simulation results used
% in Appendix C1 of correlated multiarms paper.
% If the user have access to multiple CPUs, different simulation 
% replications can be run on different CPUs instead of using this macro
% which runs all replications sequentially on a single CPU.
%
% OUTPUTS: Generates 4000 .mat files (4 policies, 1000 simulation 
% replications). Each .mat file holds information about the results of
% the replication (e.g. ground truth mean, which arms were sampled at each 
% period, at which period sampling stopped etc.)
%
% WORKFLOW: Called in ReplicateFiguresRev1.m after defining appc1folder 

%% To run all sample paths for alpha = 100/(M-1)^2 and P = 10^4
NUMOFREPS = 1000;
for n = 1:NUMOFREPS
    Func80altTC(0, n, 'aPDEUpper:sKGStarLowerold', 100, 0.1, 0, '80alt-TC-alpha100-p4-cPDEUpper-cKGstar', 1, 0, 4, 'variables', 0, appc1folder);
end
for n = 1:NUMOFREPS
    Func80altTC(0, n, 'aPDEUpperNO:sKGStarLowerold', 100, 0.1, 0, '80alt-TC-alpha100-p4-cPDEUpperNO-cKGstar', 1, 0, 4, 'variables', 0, appc1folder);
end
for n = 1:NUMOFREPS
    Func80altTC(0, n, 'aPDEUpper:aPDELower', 100, 0.1, 0, '80alt-TC-alpha100-p4-cPDEUpper-cPDELower', 1, 0, 4, 'variables', 0, appc1folder);
end
for n = 1:NUMOFREPS
    Func80altTC(0, n, 'aPDEUpperNO:aPDELower', 100, 0.1, 0, '80alt-TC-alpha100-p4-cPDEUpperNO-cPDELower', 1, 0, 4, 'variables', 0, appc1folder);
end