% SimforFig4.m:
% PURPOSE: A macro with the code to generate the simulation results to 
% generate figures referred in Section 7.2 of correlated multiarms paper.
% If the user have access to multiple CPUs, different simulation 
% replications can be run on different CPUs instead of using this macro
% which runs all replications sequentially on a single CPU.
%
% OUTPUTS: Generates 4x4x1000 = 16000 .mat files (4 policies, 4 problem 
% setups, 1000 simulation replicaitons). Each .mat file holds
% the sampling cost, opportunity cost and total cost at each period for 
% given simulation replication.
%
% WORKFLOW: Called in ReplicateFiguresRev1.m after defining sec72folder 

%% To run all 1000 sample paths for alpha = 100/(M-1)^2 and P = 10^6
NUMOFREPS = 1000; %number of replications for the simulation, 1000 in the paper
alphaval = 100;
pval = 6;
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDELowerURand', {'cPDELower-tiekg-02'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, 0.2, sec72folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDELowerURand', {'cPDELower-tiekg-04'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, 0.4, sec72folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'TTVSLower', {'cPDELower-TTVS-02'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, 0.2, sec72folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'TTVSLower', {'cPDELower-TTVS-04'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, 0.4, sec72folder); 
end

%% To run all 1000 sample paths for alpha = 100/(M-1)^2 and P = 10^8
alphaval = 100;
pval = 8;
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDELowerURand', {'cPDELower-tiekg-02'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, 0.2, sec72folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDELowerURand', {'cPDELower-tiekg-04'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, 0.4, sec72folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'TTVSLower', {'cPDELower-TTVS-02'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, 0.2, sec72folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'TTVSLower', {'cPDELower-TTVS-04'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, 0.4, sec72folder); 
end

%% To run all 1000 sample paths for alpha = 16/(M-1)^2 and P = 10^6
alphaval = 16;
pval = 6;
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDELowerURand', {'cPDELower-tiekg-02'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, 0.2, sec72folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDELowerURand', {'cPDELower-tiekg-04'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, 0.4, sec72folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'TTVSLower', {'cPDELower-TTVS-02'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, 0.2, sec72folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'TTVSLower', {'cPDELower-TTVS-04'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, 0.4, sec72folder); 
end

%% To run all 1000 sample paths for alpha = 16/(M-1)^2 and P = 10^8
alphaval = 16;
pval = 8;
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDELowerURand', {'cPDELower-tiekg-02'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, 0.2, sec72folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDELowerURand', {'cPDELower-tiekg-04'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, 0.4, sec72folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'TTVSLower', {'cPDELower-TTVS-02'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, 0.2, sec72folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'TTVSLower', {'cPDELower-TTVS-04'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, 0.4, sec72folder); 
end