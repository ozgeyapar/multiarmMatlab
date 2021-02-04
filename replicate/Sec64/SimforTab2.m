% SimforTab2.m:
% PURPOSE: A macro with the code to generate the simulation results used
% in Section 6.4 of correlated multiarms paper.
% If the user have access to multiple CPUs, different simulation 
% replications can be run on different CPUs instead of using this macro
% which runs all replications sequentially on a single CPU.
%
% OUTPUTS: Generates 21000 .mat files (7 policies, 3 priors, 1000 simulation 
% replications). Each .mat file holds information about the results of
% the replication (e.g. ground truth mean, which arms were sampled at each 
% period, at which period sampling stopped etc.)
%
% WORKFLOW: Called in ReplicateFiguresRev1.m after defining sec64folder 

%% Dose finding problem in Sec 6.4
NUMOFREPS = 1000; %number of replications for the simulation, 1000 in the paper
%GPR Prior
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aCKG:sfixed', 0, 'dose-GPR-sampleeach-cKG1-Fixed1060', 1, 'gpr', 'variables', 0, sec64folder, 1060);
end
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aPDELower:sfixed', 0, 'dose-GPR-sampleeach-cPDELower-Fixed1060', 1, 'gpr', 'variables', 0, sec64folder, 1060);
end
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aVar:sfixed', 0, 'dose-GPR-sampleeach-Variance-Fixed1060', 1, 'gpr', 'variables', 0, sec64folder, 1060);
end
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aCKG:sPDEHeu', 0, 'dose-GPR-sampleeach-cKG1-cPDE', 1, 'gpr', 'variables', 0, sec64folder);
end
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aCKG:sPDEUpperNO', 0, 'dose-GPR-sampleeach-cKG1-cPDEUpperNO', 1, 'gpr', 'variables', 0, sec64folder);
end
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aPDELower:sPDEHeu', 0, 'dose-GPR-sampleeach-aPDELower-cPDE', 1, 'gpr', 'variables', 0, sec64folder);
end
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aPDELower:sPDEUpperNO', 0, 'dose-GPR-sampleeach-aPDELower-cPDEUpperNO', 1, 'gpr', 'variables', 0, sec64folder);
end
%Robust Prior
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aCKG:sfixed', 0, 'dose-robust-sampleeach-cKG1-Fixed565', 1, 'robust', 'variables', 0, sec64folder, 565);
end
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aPDELower:sfixed', 0, 'dose-robust-sampleeach-cPDELower-Fixed565', 1, 'robust', 'variables', 0, sec64folder, 565);
end
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aVar:sfixed', 0, 'dose-robust-sampleeach-Variance-Fixed565', 1, 'robust', 'variables', 0, sec64folder, 565);
end
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aCKG:sPDEHeu', 0, 'dose-robust-sampleeach-cKG1-cPDE', 1, 'robust', 'variables', 0, sec64folder);
end
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aCKG:sPDEUpperNO', 0, 'dose-robust-sampleeach-cKG1-cPDEUpperNO', 1, 'robust', 'variables', 0, sec64folder);
end
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aPDELower:sPDEHeu', 0, 'dose-robust-sampleeach-aPDELower-cPDE', 1, 'robust', 'variables', 0, sec64folder);
end
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aPDELower:sPDEUpperNO', 0, 'dose-robust-sampleeach-aPDELower-cPDEUpperNO', 1, 'robust', 'variables', 0, sec64folder);
end
%Tilted Prior
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aCKG:sfixed', 0, 'dose-tilted-sampleeach-cKG1-Fixed595', 1, 'tilted', 'variables', 0, sec64folder, 595);
end
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aPDELower:sfixed', 0, 'dose-tilted-sampleeach-cPDELower-Fixed595', 1, 'tilted', 'variables', 0, sec64folder, 595);
end
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aVar:sfixed', 0, 'dose-tilted-sampleeach-Variance-Fixed595', 1, 'tilted', 'variables', 0, sec64folder, 595);
end
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aCKG:sPDEHeu', 0, 'dose-tilted-sampleeach-cKG1-cPDE', 1, 'tilted', 'variables', 0, sec64folder);
end
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aCKG:sPDEUpperNO', 0, 'dose-tilted-sampleeach-cKG1-cPDEUpperNO', 1, 'tilted', 'variables', 0, sec64folder);
end
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aPDELower:sPDEHeu', 0, 'dose-tilted-sampleeach-aPDELower-cPDE', 1, 'tilted', 'variables', 0, sec64folder);
end
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aPDELower:sPDEUpperNO', 0, 'dose-tilted-sampleeach-aPDELower-cPDEUpperNO', 1, 'tilted', 'variables', 0, sec64folder);
end