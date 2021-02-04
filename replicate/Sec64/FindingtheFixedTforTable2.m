% FindingtheFixedTforTable2.m:
% PURPOSE: Use Monte Carlo simulation to find the best fixed stopping time 
% to be used with cKG1 allocation policy for the problem in Sec 6.4.
%
% OUTPUTS: Generates 12000 .mat files (3 priors, 4000 simulation for each),
% three .mat files that contain all simulation replication results for each
% prior, threee .fig and three .eps files which support the fixed stopping
% times used in Table 2 and used in Figure 3 of correlated multiarm paper.
%
% WORKFLOW: Called in ReplicateFiguresRev1.m after defining sec64folder 

%% To calculate the best fixed stopping time with cKG1 allocation policy
%% for the problem in Section 6.4. for each prior
Tfixed = 3000; %Period to simulate to
%Run replications using a different set of random numbers than the 
%simulation in Table 2
for n = 1:1000
    FuncSec64OC(0, n, 'aCKG', {'cKG1'}, [0], Tfixed, 'Dose-OC-GPR', 'gpr', 'variables/btw1001and2000', 1000, sec64folder);
end
for n = 1:1000
    FuncSec64OC(0, n, 'aCKG', {'cKG1'}, [0], Tfixed, 'Dose-OC-robust', 'robust', 'variables/btw1001and2000', 1000, sec64folder);
end
for n = 1:1000
    FuncSec64OC(0, n, 'aCKG', {'cKG1)'}, [0], Tfixed, 'Dose-OC-tilted', 'tilted', 'variables/btw1001and2000', 1000, sec64folder);
end

for n = 1:1000
    FuncSec64OC(0, n, 'aCKG', {'cKG1'}, [0], Tfixed, 'Dose-OC-GPR', 'gpr', 'variables/btw2001and3000', 2000, sec64folder);
end
for n = 1:1000
    FuncSec64OC(0, n, 'aCKG', {'cKG1'}, [0], Tfixed, 'Dose-OC-robust', 'robust', 'variables/btw2001and3000', 2000, sec64folder);
end
for n = 1:1000
    FuncSec64OC(0, n, 'aCKG', {'cKG1)'}, [0], Tfixed, 'Dose-OC-tilted', 'tilted', 'variables/btw2001and3000', 2000, sec64folder);
end

for n = 1:1000
    FuncSec64OC(0, n, 'aCKG', {'cKG1'}, [0], Tfixed, 'Dose-OC-GPR', 'gpr', 'variables/btw3001and4000', 3000, sec64folder);
end
for n = 1:1000
    FuncSec64OC(0, n, 'aCKG', {'cKG1'}, [0], Tfixed, 'Dose-OC-robust', 'robust', 'variables/btw3001and4000', 3000, sec64folder);
end
for n = 1:1000
    FuncSec64OC(0, n, 'aCKG', {'cKG1)'}, [0], Tfixed, 'Dose-OC-tilted', 'tilted', 'variables/btw3001and4000', 3000, sec64folder);
end

for n = 1:1000
    FuncSec64OC(0, n, 'aCKG', {'cKG1'}, [0], Tfixed, 'Dose-OC-GPR', 'gpr', 'variables/btw4001and5000', 4000, sec64folder);
end
for n = 1:1000
    FuncSec64OC(0, n, 'aCKG', {'cKG1'}, [0], Tfixed, 'Dose-OC-robust', 'robust', 'variables/btw4001and5000', 4000, sec64folder);
end
for n = 1:1000
    FuncSec64OC(0, n, 'aCKG', {'cKG1)'}, [0], Tfixed, 'Dose-OC-tilted', 'tilted', 'variables/btw4001and5000', 4000, sec64folder);
end

%% Merge the simulation replications into a single file, GPR prior
foldername = sec64folder;
priortype = 'GPR';
NUMOFREPS = 4000;
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

%%% Plot for GPR
Tstoplot = [1,100:100:Tfixed];
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

% %%% LOG-LOG PLOT 
% Tstoplot = [1,100:100:Tfixed];
% figure;
% hold on
% 
% meanOCeach = mean(reshape([mergedOC.detailed.OCeach],[Tfixed+1,NUMOFREPS])',1);
% SEOCeach = std(reshape([mergedOC.detailed.OCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
% meanOCupper = meanOCeach + SEOCeach;
% logmeanOCeach = log10(meanOCeach);
% logmeanOCupper = log10(meanOCupper);
% %plot(logmeanOCeach,'--r','LineWidth',2, 'MarkerSize',10)
% errorbar(log10(Tstoplot),logmeanOCeach(Tstoplot),logmeanOCupper(Tstoplot)-logmeanOCeach(Tstoplot),'--r','LineWidth',2, 'MarkerSize',10)
% 
% meanTCeach = mean(reshape([mergedOC.detailed.TCeach],[Tfixed+1,NUMOFREPS])',1);
% SETCeach = std(reshape([mergedOC.detailed.TCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
% meanTCupper = meanTCeach + SETCeach;
% logmeanTCeach = log10(meanTCeach);
% logmeanTCupper = log10(meanTCupper);
% %plot(logmeanTCeach,'-k','LineWidth',2, 'MarkerSize',10)
% errorbar(log10(Tstoplot),logmeanTCeach(Tstoplot),logmeanTCupper(Tstoplot)-logmeanTCeach(Tstoplot),'-k','LineWidth',2, 'MarkerSize',10)
% 
% meanSCeach = mean(reshape([mergedOC.detailed.SCeach],[Tfixed+1,NUMOFREPS])',1);
% SESCeach = std(reshape([mergedOC.detailed.SCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
% meanSCupper = meanSCeach + SESCeach;
% logmeanSCeach = log10(meanSCeach);
% logmeanSCupper = log10(meanSCupper);
% plot(log10(Tstoplot),logmeanSCeach(Tstoplot),'-.b','LineWidth',2, 'MarkerSize',10)
% %errorbar(Tstoplot,logmeanSCeach(Tstoplot),logmeanSCupper(Tstoplot)-logmeanSCeach(Tstoplot),'-.b','LineWidth',2, 'MarkerSize',10)
% 
% %set(gca, 'YScale', 'log');
% hold off;
% %set(gca,'xlim',[0 Tfixed+1]);
% xlabel('log_{10}(Sample size)');
% ylabel('log_{10}($)');
% legend('E[OC]','E[TC]','E[SC]');
% set(gca,'FontSize',36)
% set(gca,'fontname','times')

%% Merge the simulation replications into a single file, Robust prior
priortype = 'robust';
NUMOFREPS = 4000;
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

%%% Plot for Robust
Tstoplot = [1,100:100:Tfixed];
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

% %%% LOG-LOG PLOT 
% Tstoplot = [1,100:100:Tfixed];
% figure;
% hold on
% 
% meanOCeach = mean(reshape([mergedOC.detailed.OCeach],[Tfixed+1,NUMOFREPS])',1);
% SEOCeach = std(reshape([mergedOC.detailed.OCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
% meanOCupper = meanOCeach + SEOCeach;
% logmeanOCeach = log10(meanOCeach);
% logmeanOCupper = log10(meanOCupper);
% %plot(logmeanOCeach,'--r','LineWidth',2, 'MarkerSize',10)
% errorbar(log10(Tstoplot),logmeanOCeach(Tstoplot),logmeanOCupper(Tstoplot)-logmeanOCeach(Tstoplot),'--r','LineWidth',2, 'MarkerSize',10)
% 
% meanTCeach = mean(reshape([mergedOC.detailed.TCeach],[Tfixed+1,NUMOFREPS])',1);
% SETCeach = std(reshape([mergedOC.detailed.TCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
% meanTCupper = meanTCeach + SETCeach;
% logmeanTCeach = log10(meanTCeach);
% logmeanTCupper = log10(meanTCupper);
% %plot(logmeanTCeach,'-k','LineWidth',2, 'MarkerSize',10)
% errorbar(log10(Tstoplot),logmeanTCeach(Tstoplot),logmeanTCupper(Tstoplot)-logmeanTCeach(Tstoplot),'-k','LineWidth',2, 'MarkerSize',10)
% 
% meanSCeach = mean(reshape([mergedOC.detailed.SCeach],[Tfixed+1,NUMOFREPS])',1);
% SESCeach = std(reshape([mergedOC.detailed.SCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
% meanSCupper = meanSCeach + SESCeach;
% logmeanSCeach = log10(meanSCeach);
% logmeanSCupper = log10(meanSCupper);
% plot(log10(Tstoplot),logmeanSCeach(Tstoplot),'-.b','LineWidth',2, 'MarkerSize',10)
% %errorbar(Tstoplot,logmeanSCeach(Tstoplot),logmeanSCupper(Tstoplot)-logmeanSCeach(Tstoplot),'-.b','LineWidth',2, 'MarkerSize',10)
% 
% %set(gca, 'YScale', 'log');
% hold off;
% %set(gca,'xlim',[0 Tfixed+1]);
% xlabel('log_{10}(Sample size)');
% ylabel('log_{10}($)');
% legend('E[OC]','E[TC]','E[SC]');
% set(gca,'FontSize',36)
% set(gca,'fontname','times')

%% Merge the simulation replications into a single file, Tilted prior
priortype = 'tilted';
NUMOFREPS = 4000;
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

%%% Plot for Tilted 
Tstoplot = [1,100:100:Tfixed];
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

%%% LOG-LOG PLOT 
% Tstoplot = [1,100:100:Tfixed];
% figure;
% hold on
% 
% meanOCeach = mean(reshape([mergedOC.detailed.OCeach],[Tfixed+1,NUMOFREPS])',1);
% SEOCeach = std(reshape([mergedOC.detailed.OCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
% meanOCupper = meanOCeach + SEOCeach;
% logmeanOCeach = log10(meanOCeach);
% logmeanOCupper = log10(meanOCupper);
% %plot(logmeanOCeach,'--r','LineWidth',2, 'MarkerSize',10)
% errorbar(log10(Tstoplot),logmeanOCeach(Tstoplot),logmeanOCupper(Tstoplot)-logmeanOCeach(Tstoplot),'--r','LineWidth',2, 'MarkerSize',10)
% 
% meanTCeach = mean(reshape([mergedOC.detailed.TCeach],[Tfixed+1,NUMOFREPS])',1);
% SETCeach = std(reshape([mergedOC.detailed.TCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
% meanTCupper = meanTCeach + SETCeach;
% logmeanTCeach = log10(meanTCeach);
% logmeanTCupper = log10(meanTCupper);
% %plot(logmeanTCeach,'-k','LineWidth',2, 'MarkerSize',10)
% errorbar(log10(Tstoplot),logmeanTCeach(Tstoplot),logmeanTCupper(Tstoplot)-logmeanTCeach(Tstoplot),'-k','LineWidth',2, 'MarkerSize',10)
% 
% meanSCeach = mean(reshape([mergedOC.detailed.SCeach],[Tfixed+1,NUMOFREPS])',1);
% SESCeach = std(reshape([mergedOC.detailed.SCeach],[Tfixed+1,NUMOFREPS])',0,1)./sqrt(NUMOFREPS);
% meanSCupper = meanSCeach + SESCeach;
% logmeanSCeach = log10(meanSCeach);
% logmeanSCupper = log10(meanSCupper);
% plot(log10(Tstoplot),logmeanSCeach(Tstoplot),'-.b','LineWidth',2, 'MarkerSize',10)
% %errorbar(Tstoplot,logmeanSCeach(Tstoplot),logmeanSCupper(Tstoplot)-logmeanSCeach(Tstoplot),'-.b','LineWidth',2, 'MarkerSize',10)
% 
% %set(gca, 'YScale', 'log');
% hold off;
% %set(gca,'xlim',[0 Tfixed+1]);
% xlabel('log_{10}(Sample size)');
% ylabel('log_{10}($)');
% legend('E[OC]','E[TC]','E[SC]');
% set(gca,'FontSize',36)
% set(gca,'fontname','times')