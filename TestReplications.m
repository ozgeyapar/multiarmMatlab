% TestReplications.m:
% PURPOSE: A macro to run a subset of simulation replications from the 
% 	paper Chick, Gans, Yapar (2020) for a test.

SetPaths

%% Section 6.2
sec62folder = strcat(pdecorr, 'Outputs\Sec62\');  %path to the folder that contains all merged files for 1000 replications
mkdir(sec62folder);

% SimforFig1
NUMOFREPS = 2; %number of replications for the simulation, 1000 in the paper
alphaval = 100;
pval = 6;
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aEqual', {'Equal'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aKGStarLower', {'cKGstar(ratio)'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDELower', {'cPDELower-tiekg'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, -1, sec62folder); 
end

% PlotFig1
alphaval = 100;
pval = 6;
names = {'Equal', 'cKGstar(ratio)', 'cPDELower-tiekg'};
for j = 1:size(names,2)
    for i = 1:NUMOFREPS
        load(strcat(sec62folder,'80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval),'-c0-',names{j},'-repnum-',num2str(i),'.mat'))
        mergedOC.allrule = X.allrule;
        mergedOC.parameters = X.parameters;
        mergedOC.detailed(i) = X.detailed(i);
    end  
    mymat = strcat(sec62folder,'merged-80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval),'-c0-',names{j},'.mat');
    save(mymat,'mergedOC');
end

clear result
namesneworder = {'Equal', 'cKGstar(ratio)','cPDELower-tiekg'};
alpha = '100';
cost = '0';
p = '6';
for i = 1:size(namesneworder,2)
    load(strcat(sec62folder,'merged-80alt-OC-alpha',alpha,'-P',p,'-c',cost,'-',namesneworder{i},'.mat'))
    result.rule(i) = mergedOC;
end
%names = {'Equal', 'iKG1', 'ESPb', 'ESPB', 'Random', 'Variance', 'cKG\fontsize{20}1', 'cKG\fontsize{20}\ast', 'cPDEUpper', 'cPDE', 'cPDELower'};
namesforlegend = {'Equal','cKG\fontsize{20}\ast', 'cPDELower'};
linS = {'-+r','-sr','-.b'};
figurename = strcat(sec62folder,'sec62-P6-alpha100');
PlotLogOCCurves( result, namesforlegend, 0, NUMOFREPS, NUMOFREPS, 100,linS, figurename)
PlotLogOCCurves( result, namesforlegend, 1, NUMOFREPS, NUMOFREPS, 100,linS, figurename)

%Confidence intervals at t = 100
names = {'Equal', 'cKG*', 'cPDELower'};
[meandOCp6a100, sedOCp6a100] = CalculateandPlotCIofOC( result, NUMOFREPS, NUMOFREPS, names, 100, linS, 100, 0);

%% Section 6.3
sec63folder = strcat(pdecorr, 'Outputs\Sec63\'); 
mkdir(sec63folder);

% SimforTab1
for n = 1:2
    Func80altTC(0, n, 'aCKG:sKGStarLower', 100, 0.1, 0, '80alt-TC-alpha100-cost0-p6-cKG1-cKGstar', 1, 0, 6, 'variables', 0, sec63folder);
end

% MergeandGenerateTable1
cnames = {'Allocation Rule','Stopping Rule','E[Sampling Cost]','Standard error','E[Opportunity Cost]','Standard error','E[Total Cost]','Standard error','Prob. of Correct Selection','Total Computation Time','E[T]','E[Reward]','Standard Error', 'EVPI'};
toCopyMat63(1, :) = cnames;
[ toCopy ] = MergeReplicationsforTab1( 'cKG1-cKGstar', 100, 2, sec63folder );
toCopyMat63(2, :) = toCopy;

save(strcat(sec63folder,'Sec63-tab1.mat'),'toCopyMat63');

% FindingtheFixedTforTable1
NUMOFREPS = 2; %Total number of simulation replications
Tfixed = 10; %Period to simulate to

for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aCKG', {'cKG1'}, [0], Tfixed, '80alt-OC-alpha100-P6-bestT', 100, 0.1, 6, -1, sec63folder); 
end

for i = 1:NUMOFREPS
    load(strcat(sec63folder,'80alt-OC-alpha100-P6-bestT-cKG1-repnum-',num2str(i),'.mat'))
    mergedOC.allrule = X.allrule;
    mergedOC.parameters = X.parameters;
    mergedOC.detailed(i) = X.detailed(i);
end  
mymat = strcat(sec63folder,'merged-80alt-OC-alpha100-P6-bestT-cKG1','.mat');
save(mymat,'mergedOC');

Tstoplot = [1:1:Tfixed];
f1 = figure;
hold on

meanOCeach = mean(reshape([mergedOC.detailed.OCeach],[Tfixed+1,NUMOFREPS])',1);
SEOCeach = std(reshape([mergedOC.detailed.OCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
meanOCupper = meanOCeach + SEOCeach;
logmeanOCeach = log10(meanOCeach);
logmeanOCupper = log10(meanOCupper);
%plot(logmeanOCeach,'--r','LineWidth',2, 'MarkerSize',10)
errorbar(Tstoplot,logmeanOCeach(Tstoplot),logmeanOCupper(Tstoplot)-logmeanOCeach(Tstoplot),'--r','LineWidth',2, 'MarkerSize',10)

meanTCeach = mean(reshape([mergedOC.detailed.TCeach],[Tfixed+1,NUMOFREPS])',1);
SETCeach = std(reshape([mergedOC.detailed.TCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
meanTCupper = meanTCeach + SETCeach;
logmeanTCeach = log10(meanTCeach);
logmeanTCupper = log10(meanTCupper);
%plot(logmeanTCeach,'-k','LineWidth',2, 'MarkerSize',10)
errorbar(Tstoplot,logmeanTCeach(Tstoplot),logmeanTCupper(Tstoplot)-logmeanTCeach(Tstoplot),'-k','LineWidth',2, 'MarkerSize',10)

meanSCeach = mean(reshape([mergedOC.detailed.SCeach],[Tfixed+1,NUMOFREPS])',1);
SESCeach = std(reshape([mergedOC.detailed.SCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
meanSCupper = meanSCeach + SESCeach;
logmeanSCeach = log10(meanSCeach);
logmeanSCupper = log10(meanSCupper);
plot(Tstoplot,logmeanSCeach(Tstoplot),'-.b','LineWidth',2, 'MarkerSize',10)
%errorbar(Tstoplot,logmeanSCeach(Tstoplot),logmeanSCupper(Tstoplot)-logmeanSCeach(Tstoplot),'-.b','LineWidth',2, 'MarkerSize',10)

%set(gca, 'YScale', 'log');
hold off;
set(gca,'xlim',[0 Tfixed]);
xlabel('Sample size');
ylabel('log_{10}($)');
legend('E[OC]','E[TC]','E[SC]');
set(gca,'FontSize',36)
set(gca,'fontname','times')

figurename = strcat(sec63folder,'80alt-OC-alpha100-P6-bestT-cKG1');
savefig(f1, strcat(figurename, '.fig'));
saveas(f1, figurename, 'epsc')

%% Section 6.4
sec64folder = strcat(pdecorr, 'Outputs\Sec64\');
mkdir(sec64folder);

% SimforTab2
NUMOFREPS = 2;
for n = 1:NUMOFREPS
    FuncSec64TC(0, n, 'aCKG:sfixed', 0, 'dose-GPR-sampleeach-cKG1-Fixed1060', 1, 'gpr', 'variables', 0, sec64folder, 1060);
end

% MergeandGenerateTable2
cnames = {'Allocation Rule','Stopping Rule','E[Sampling Cost]','Standard error','E[Opportunity Cost]','Standard error','E[Total Cost]','Standard error','Prob. of Correct Selection','Total Computation Time','E[T]','E[Reward]','Standard Error', 'EVPI', 'Prob of stopping at t=0', 'Prob of reaching t=3000', 'Frac of low  early'};
NUMOFREPS = 2; %number of replications for the simulation, 1000 in the paper
toCopyMat64(1, :) = cnames;
[ toCopy ] = MergeReplicationsforTab2( 'cKG1-Fixed1060', 'GPR', NUMOFREPS, sec64folder );
toCopyMat64(2, :) = toCopy;
save(strcat(sec64folder,'Sec64-tab2.mat'),'toCopyMat64');

% GenerateFig2
n = 5;
FuncSec64TC(0, n, 'aCKG:sfixed', 0, 'forFigure2', 1, 'gpr', 'variables', 0, sec64folder, 1, 1/2, 1);
savefig(gcf, strcat(sec64folder,'Sec64-fig1-priors.fig'));
saveas(gcf, strcat(sec64folder,'Sec64-fig1-priors'), 'epsc')

% FindingtheFixedTforTable2
Tfixed = 10; %Period to simulate to
for n = 1:2
    FuncSec64OC(0, n, 'aCKG', {'cKG1'}, [0], Tfixed, 'Dose-OC-GPR', 'gpr', 'variables/btw1001and2000', 1000, sec64folder);
end
for n = 1:2
    FuncSec64OC(0, n, 'aCKG', {'cKG1'}, [0], Tfixed, 'Dose-OC-robust', 'robust', 'variables/btw1001and2000', 1000, sec64folder);
end

foldername = sec64folder;
priortype = 'GPR';
NUMOFREPS = 2;
for i = 1:NUMOFREPS
    repnum = 1000 + i;
    load(strcat(foldername,'Dose-OC-',priortype,'-cKG1-repnum-',num2str(repnum),'.mat'))
    mergedOC.allrule = X.allrule;
    %mergedOC.parameters = X.parameters;
    j = mod(i,1000);
    if j == 0
        j = 1000;
    end
    mergedOC.detailed(i) = X.detailed(j);
end
mymat = strcat(foldername,'Dose-OC-',priortype,'-cKG1','.mat'); 
save(mymat,'mergedOC');

Tstoplot = [1:1:Tfixed];
figure;
hold on

meanOCeach = mean(reshape([mergedOC.detailed.OCeach],[Tfixed+1,NUMOFREPS])',1);
SEOCeach = std(reshape([mergedOC.detailed.OCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
meanOCupper = meanOCeach + SEOCeach;
logmeanOCeach = log10(meanOCeach);
logmeanOCupper = log10(meanOCupper);
%plot(logmeanOCeach,'--r','LineWidth',2, 'MarkerSize',10)
errorbar(Tstoplot,logmeanOCeach(Tstoplot),logmeanOCupper(Tstoplot)-logmeanOCeach(Tstoplot),'--r','LineWidth',2, 'MarkerSize',10)

meanTCeach = mean(reshape([mergedOC.detailed.TCeach],[Tfixed+1,NUMOFREPS])',1);
SETCeach = std(reshape([mergedOC.detailed.TCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
meanTCupper = meanTCeach + SETCeach;
logmeanTCeach = log10(meanTCeach);
logmeanTCupper = log10(meanTCupper);
%plot(logmeanTCeach,'-k','LineWidth',2, 'MarkerSize',10)
errorbar(Tstoplot,logmeanTCeach(Tstoplot),logmeanTCupper(Tstoplot)-logmeanTCeach(Tstoplot),'-k','LineWidth',2, 'MarkerSize',10)

meanSCeach = mean(reshape([mergedOC.detailed.SCeach],[Tfixed+1,NUMOFREPS])',1);
SESCeach = std(reshape([mergedOC.detailed.SCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
meanSCupper = meanSCeach + SESCeach;
logmeanSCeach = log10(meanSCeach);
logmeanSCupper = log10(meanSCupper);
plot(Tstoplot,logmeanSCeach(Tstoplot),'-.b','LineWidth',2, 'MarkerSize',10)
%errorbar(Tstoplot,logmeanSCeach(Tstoplot),logmeanSCupper(Tstoplot)-logmeanSCeach(Tstoplot),'-.b','LineWidth',2, 'MarkerSize',10)

%set(gca, 'YScale', 'log');
hold off;
set(gca,'xlim',[0 Tfixed+1]);
xlabel('Sample size');
ylabel('log_{10}($)');
legend('E[OC]','E[TC]','E[SC]');
set(gca,'FontSize',36)
set(gca,'fontname','times')

priortype = 'robust';
NUMOFREPS = 2;
for i = 1:NUMOFREPS
    repnum = 1000 + i;
    load(strcat(foldername,'Dose-OC-',priortype,'-cKG1-repnum-',num2str(repnum),'.mat'))
    mergedOC.allrule = X.allrule;
    %mergedOC.parameters = X.parameters;
    j = mod(i,1000);
    if j == 0
        j = 1000;
    end
    mergedOC.detailed(i) = X.detailed(j);
end
mymat = strcat(foldername,'Dose-OC-',priortype,'-cKG1','.mat'); 
save(mymat,'mergedOC');

Tstoplot = [1:1:Tfixed];
figure;
hold on

meanOCeach = mean(reshape([mergedOC.detailed.OCeach],[Tfixed+1,NUMOFREPS])',1);
SEOCeach = std(reshape([mergedOC.detailed.OCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
meanOCupper = meanOCeach + SEOCeach;
logmeanOCeach = log10(meanOCeach);
logmeanOCupper = log10(meanOCupper);
%plot(logmeanOCeach,'--r','LineWidth',2, 'MarkerSize',10)
errorbar(Tstoplot,logmeanOCeach(Tstoplot),logmeanOCupper(Tstoplot)-logmeanOCeach(Tstoplot),'--r','LineWidth',2, 'MarkerSize',10)

meanTCeach = mean(reshape([mergedOC.detailed.TCeach],[Tfixed+1,NUMOFREPS])',1);
SETCeach = std(reshape([mergedOC.detailed.TCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
meanTCupper = meanTCeach + SETCeach;
logmeanTCeach = log10(meanTCeach);
logmeanTCupper = log10(meanTCupper);
%plot(logmeanTCeach,'-k','LineWidth',2, 'MarkerSize',10)
errorbar(Tstoplot,logmeanTCeach(Tstoplot),logmeanTCupper(Tstoplot)-logmeanTCeach(Tstoplot),'-k','LineWidth',2, 'MarkerSize',10)

meanSCeach = mean(reshape([mergedOC.detailed.SCeach],[Tfixed+1,NUMOFREPS])',1);
SESCeach = std(reshape([mergedOC.detailed.SCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
meanSCupper = meanSCeach + SESCeach;
logmeanSCeach = log10(meanSCeach);
logmeanSCupper = log10(meanSCupper);
plot(Tstoplot,logmeanSCeach(Tstoplot),'-.b','LineWidth',2, 'MarkerSize',10)
%errorbar(Tstoplot,logmeanSCeach(Tstoplot),logmeanSCupper(Tstoplot)-logmeanSCeach(Tstoplot),'-.b','LineWidth',2, 'MarkerSize',10)

%set(gca, 'YScale', 'log');
hold off;
set(gca,'xlim',[0 Tfixed+1]);
xlabel('Sample size');
ylabel('log_{10}($)');
legend('E[OC]','E[TC]','E[SC]');
set(gca,'FontSize',36)
set(gca,'fontname','times')

%% Section 7.2
sec72folder = strcat(pdecorr, 'Outputs\Sec72\');
mkdir(sec72folder);

% SimforFig4
NUMOFREPS = 2; %number of replications for the simulation, 1000 in the paper
alphaval = 100;
pval = 6;
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aPDELowerURand', {'cPDELower-tiekg-02'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, 0.2, sec72folder); 
end
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'TTVSLower', {'cPDELower-TTVS-02'}, [0], 100, strcat('80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval)','-c0'), alphaval, 0.1, pval, 0.2, sec72folder); 
end

% PlotFig4
alphaval = '100';
pval = '6';
names = {'cPDELower-tiekg-02', 'cPDELower-TTVS-02'};
for j = 1:size(names,2)
    for i = 1:NUMOFREPS
        load(strcat(sec72folder,'80alt-OC-alpha',alphaval,'-P',pval,'-c0-',names{j},'-repnum-',num2str(i),'.mat'))
        mergedOC.allrule = X.allrule;
        mergedOC.parameters = X.parameters;
        mergedOC.detailed(i) = X.detailed(i);
    end  
    mymat = strcat(sec72folder,'merged-80alt-OC-alpha',alphaval,'-P',pval,'-c0-',names{j},'.mat');
    save(mymat,'mergedOC');
end

clear result
alpha = '100';
cost = '0';
p = '6';
pvalues = {'02'};
NUMOFPS = size(pvalues,2);
names =  {'Equal', 'Random-pis1', 'Variance'};
lastind = 0;
lastind2 = lastind + 0;
names = {'cPDELower-tiekg'};
for j = 1:size(pvalues, 2)
    load(strcat(sec72folder, 'merged-80alt-OC-alpha',alpha,'-P',p,'-c',cost,'-',names{1},'-',pvalues{j},'.mat'))
    result.rule(j+lastind2) = mergedOC;
    lastind3 = j+lastind2;
end
names =  {'cPDELower-TTVS'};
pvalues = {'02'};
for j = 1:size(pvalues,2)
    load(strcat(sec72folder,'merged-80alt-OC-alpha',alpha,'-P',p,'-c',cost,'-',names{1},'-',pvalues{j},'.mat'))
    result.rule(lastind3+j) = mergedOC;
    lastind4 = lastind3+j;
end
names =  { 'cPDELower with p = 0.2', 'TTVS-Lower with p = 0.2'};
%names =  { 'cPDELower', 'cPDELower with p = 0.2', 'cPDELower with p = 0.4',  'Equal', 'Variance', 'Random', 'TTVS with p = 0.2', 'TTVS with p = 0.4'};
linS = {':*g','-.b'};
figurename = strcat(sec72folder,'sec72-alpha',alpha,'-P',p);
PlotLogOCCurves( result, names, 0, NUMOFREPS, NUMOFREPS, 100, linS,figurename)
PlotLogOCCurves( result, names, 1, NUMOFREPS, NUMOFREPS, 100, linS,figurename)

%% Appendix C.1
appc1folder = strcat(pdecorr, 'Outputs\AppC1\'); 
mkdir(appc1folder);

% SimforTabEC2
NUMOFREPS = 2;
for n = 1:NUMOFREPS
    Func80altTC(0, n, 'aPDEUpperNO:sKGStarLowerold', 100, 0.1, 0, '80alt-TC-alpha100-p4-cPDEUpperNO-cKGstar', 1, 0, 4, 'variables', 0, appc1folder);
end

% MergeandGenerateTableEC2
NUMOFREPS = 2;
cnames = {'Allocation Rule','Stopping Rule','E[Sampling Cost]','Standard error','E[Opportunity Cost]','Standard error','E[Total Cost]','Standard error','Prob. of Correct Selection','Total Computation Time','E[T]','E[Reward]','Standard Error', 'EVPI'};
toCopyMatAppC(1, :) = cnames;
[ toCopy ] = MergeReplicationsEC2( 'cPDEUpperNO-cKGstar', 100, NUMOFREPS, appc1folder);
toCopyMatAppC(3, :) = toCopy;
save(strcat(appc1folder,'AppC1-tabec2.mat'),'toCopyMatAppC');

%% Appendix C.2 and C.3
appc23folder = strcat(pdecorr, 'Outputs\AppC2andC3\'); 
mkdir(appc23folder);

PlotsAppC

%% Appendix D
appdfolder = strcat(pdecorr, 'Outputs\AppD1\');
mkdir(appdfolder);

% SimforAppD1
NUMOFREPS = 2; %number of replications for the simulation, 1000 in the paper

[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDEUpperNO:sfixed', [0], 'powercurve-21alt-03-Upper-fixed', 1, 0.3, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDEUpperNO:sfixed', [0], 'powercurve-21alt-05-Upper-fixed', 1, 0.5, 21, appdfolder);

% PlotFigEC5
names = {'Upper-fixed'};
deltanames = {'03','05'};
NUMOFDELTAS = size(deltanames,2);
for i = 1:size(names,2)
    for j = 1:size(deltanames,2)
    load(strcat(appdfolder,'powercurve-21alt-',deltanames{j},'-',names{i},'.mat'))
    all.deltarule((i-1)*NUMOFDELTAS+j) = result;
    end
end
names = {'cPDEUpper - Fixed at 150'};
deltas = [0.3,0.5];

PlotPowerCurve( all, names, deltas, appdfolder, strcat('PowerCurve','-','AppD1FigEC5') )
