% SimforFig1.m:
% PURPOSE: A macro with the code to generate the simulation results to 
% generate figures referred in Section 6.2 of correlated multiarms paper.
% If the user have access to multiple CPUs, different simulation 
% replications can be run on different CPUs instead of using this macro
% which runs all replications sequentially on a single CPU.
%
% OUTPUTS: Generates 9x4x1000 = 36000 .mat files (9 policies, 4 problem 
% setups, 1000 simulatin replicaitons). Each .mat file holds
% the sampling cost, opportunity cost and total cost at each period for 
% given simulation replication.
%
% WORKFLOW: Called in ReplicateFiguresRev1.m after defining sec62folder 

%% To run all 1000 sample paths for alpha = 100/(M-1)^2 and P = 10^6
NUMOFREPS = 1000; % number of replications for the simulation, 1000 in the paper
alphaval = 100;
pval = 6;
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aEqual', {'Equal'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aESPB', {'ESPcapB'}, [1], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aKGStarLower', {'Random-pis1'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aVar', {'Variance'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aCKG', {'cKG1(ratio)'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aKGStarLower', {'cKGstar(ratio)'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDEUpperNO', {'cPDEUpper(Equal)-tiekg'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDELower', {'cPDELower-tiekg'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDE', {'cPDE-tiekg'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end

%% To run all 1000 sample paths for alpha = 100/(M-1)^2 and P = 10^8
alphaval = 100;
pval = 8;
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aEqual', {'Equal'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aESPB', {'ESPcapB'}, [1], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aKGStarLower', {'Random-pis1'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aVar', {'Variance'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aCKG', {'cKG1(ratio)'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aKGStarLower', {'cKGstar(ratio)'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDEUpperNO', {'cPDEUpper(Equal)-tiekg'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDELower', {'cPDELower-tiekg'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDE', {'cPDE-tiekg'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
%% To run all 1000 sample paths for alpha = 16/(M-1)^2 and P = 10^6
alphaval = 16;
pval = 6;
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aEqual', {'Equal'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aESPB', {'ESPcapB'}, [1], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aKGStarLower', {'Random-pis1'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aVar', {'Variance'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aCKG', {'cKG1(ratio)'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aKGStarLower', {'cKGstar(ratio)'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDEUpperNO', {'cPDEUpper(Equal)-tiekg'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDELower', {'cPDELower-tiekg'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDE', {'cPDE-tiekg'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
%% To run all 1000 sample paths for alpha = 16/(M-1)^2 and P = 10^8
alphaval = 16;
pval = 8;
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aEqual', {'Equal'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aESPB', {'ESPcapB'}, [1], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aKGStarLower', {'Random-pis1'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aVar', {'Variance'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aCKG', {'cKG1(ratio)'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aKGStarLower', {'cKGstar(ratio)'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDEUpperNO', {'cPDEUpper(Equal)-tiekg'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDELower', {'cPDELower-tiekg'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDE', {'cPDE-tiekg'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
