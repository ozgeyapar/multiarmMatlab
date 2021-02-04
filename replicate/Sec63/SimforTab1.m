% SimforTab1.m:
% PURPOSE: A macro with the code to generate the simulation results used
% in Section 6.3 of correlated multiarms paper.
% If the user have access to multiple CPUs, different simulation 
% replications can be run on different CPUs instead of using this macro
% which runs all replications sequentially on a single CPU.
%
% OUTPUTS: Generates 121000 .mat files (15 policies, 1000+ simulation 
% replications). Each .mat file holds information about the results of
% the replication (e.g. ground truth mean, which arms were sampled at each 
% period, at which period sampling stopped etc.)
%
% WORKFLOW: Called in ReplicateFiguresRev1.m after defining sec63folder 

%% Problem setup is for zeta = 100/(M-1)^2 and P = 10^6
%% Run sample paths #1-#1000 for all 15 policies
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sKGStarLower', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-cKGstar', 1, 0, 6, 'variables', 0, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sPDELower', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-cPDELower', 1, 0, 6, 'variables', 0, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sPDEHeu', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-cPDE', 1, 0, 6, 'variables', 0, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sPDEUpperNO', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-cPDEUpperNO', 1, 0, 6, 'variables', 0, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sfixed', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-fixed130', 1, 0, 6, 'variables', 0, sec63folder, 130);
end
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sfixed', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-fixed200', 1, 0, 6, 'variables', 0, sec63folder, 200);
end
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sfixed', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-fixed493', 1, 0, 6, 'variables', 0, sec63folder, 493);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sKGStarLower', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-cKGstar', 1, 0, 6, 'variables', 0, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sPDELower', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-cPDELower', 1, 0, 6, 'variables', 0, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sPDEHeu', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-cPDE', 1, 0, 6, 'variables', 0, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sPDEUpperNO', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-cPDEUpperNO', 1, 0, 6, 'variables', 0, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sfixed', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-fixed150', 1, 0, 6, 'variables', 0, sec63folder, 150);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sfixed', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-fixed200', 1, 0, 6, 'variables', 0, sec63folder, 200);
end
for n = 1:1000
    Func80altTC(0, n, 'aVar:sfixed', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-Variance-fixed150', 1, 0, 6, 'variables', 0, sec63folder, 150);
end
for n = 1:1000
    Func80altTC(0, n, 'aVar:sfixed', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-Variance-fixed200', 1, 0, 6, 'variables', 0, sec63folder, 200);
end

%% Additional replication (#1001-#2000) for some policies
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sPDELower', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-cPDELower', 1, 0, 6, 'variables/btw1001and2000', 1000, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sPDEHeu', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-cPDE', 1, 0, 6, 'variables/btw1001and2000', 1000, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sPDEUpperNO', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-cPDEUpperNO', 1, 0, 6, 'variables/btw1001and2000', 1000, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sfixed', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-fixed130', 1, 0, 6, 'variables/btw1001and2000', 1000, sec63folder, 130);
end
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sfixed', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-fixed200', 1, 0, 6, 'variables/btw1001and2000', 1000, sec63folder, 200);
end
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sfixed', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-fixed493', 1, 0, 6, 'variables/btw1001and2000', 1000, sec63folder, 493);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sPDELower', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-cPDELower', 1, 0, 6, 'variables/btw1001and2000', 1000, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sPDEHeu', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-cPDE', 1, 0, 6, 'variables/btw1001and2000', 1000, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sPDEUpperNO', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-cPDEUpperNO', 1, 0, 6, 'variables/btw1001and2000', 1000, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sfixed', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-fixed150', 1, 0, 6, 'variables/btw1001and2000', 1000, sec63folder, 150);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sfixed', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-fixed200', 1, 0, 6, 'variables/btw1001and2000', 1000, sec63folder, 200);
end

%% Additional replication (#2001-#3000) for some policies
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sPDELower', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-cPDELower', 1, 0, 6, 'variables/btw2001and3000', 2000, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sPDEHeu', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-cPDE', 1, 0, 6, 'variables/btw2001and3000', 2000, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sPDEUpperNO', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-cPDEUpperNO', 1, 0, 6, 'variables/btw2001and3000', 2000, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sfixed', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-fixed130', 1, 0, 6, 'variables/btw2001and3000', 2000, sec63folder, 130);
end
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sfixed', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-fixed200', 1, 0, 6, 'variables/btw2001and3000', 2000, sec63folder, 200);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sPDELower', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-cPDELower', 1, 0, 6, 'variables/btw2001and3000', 2000, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sPDEHeu', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-cPDE', 1, 0, 6, 'variables/btw2001and3000', 2000, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sPDEUpperNO', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-cPDEUpperNO', 1, 0, 6, 'variables/btw2001and3000', 2000, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sfixed', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-fixed150', 1, 0, 6, 'variables/btw2001and3000', 2000, sec63folder, 150);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sfixed', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-fixed200', 1, 0, 6, 'variables/btw2001and3000', 2000, sec63folder, 200);
end

%% Additional replication (#3001-#4000) for some policies
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sPDEHeu', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-cPDE', 1, 0, 6, 'variables/btw3001and4000', 3000, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sPDEUpperNO', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-cPDEUpperNO', 1, 0, 6, 'variables/btw3001and4000', 3000, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sfixed', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-fixed200', 1, 0, 6, 'variables/btw3001and4000', 3000, sec63folder, 200);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sPDEHeu', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-cPDE', 1, 0, 6, 'variables/btw3001and4000', 3000, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sPDEUpperNO', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-cPDEUpperNO', 1, 0, 6, 'variables/btw3001and4000', 3000, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sfixed', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-fixed200', 1, 0, 6, 'variables/btw3001and4000', 3000, sec63folder, 200);
end

%% Additional replication (#4001-#5000) for some policies
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sPDEHeu', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-cPDE', 1, 0, 6, 'variables/btw4001and5000', 4000, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sPDEUpperNO', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-cPDEUpperNO', 1, 0, 6, 'variables/btw4001and5000', 4000, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aCKG:sfixed', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-fixed200', 1, 0, 6, 'variables/btw4001and5000', 4000, sec63folder, 200);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sPDEHeu', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-cPDE', 1, 0, 6, 'variables/btw4001and5000', 4000, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sPDEUpperNO', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-cPDEUpperNO', 1, 0, 6, 'variables/btw4001and5000', 4000, sec63folder);
end
for n = 1:1000
    Func80altTC(0, n, 'aPDELower:sfixed', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cPDELower-fixed200', 1, 0, 6, 'variables/btw4001and5000', 4000, sec63folder, 200);
end
