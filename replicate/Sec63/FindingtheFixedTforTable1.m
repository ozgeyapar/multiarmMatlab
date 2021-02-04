% FindingtheFixedTforTable1.m:
% PURPOSE: Use Monte Carlo simulation to find the best fixed stopping time 
% to be used with cKG1 allocation policy for the problem in Sec 6.3.
%
% OUTPUTS: Generates 1000 .mat files (each for one simulation replication),
% one .mat file that contains all simulation replication results, one .fig 
% and one .eps file, which shows 493 is the 
% best stopping time using a format similar to that of Figure 3 of
% correlated multiarm paper.
%
% WORKFLOW: Called in ReplicateFiguresRev1.m after defining sec63folder 

%% To calculate the best fixed stopping time with cKG1 allocation policy
%% for the problem in Table 1 (zeta = 100/(M-1)^2 and P = 10^6)
NUMOFREPS = 1000; %Total number of simulation replications
Tfixed = 10000; %Period to simulate to

%Run replications 
for n = 1:NUMOFREPS
    Func80altOC(0, n, 'aCKG', {'cKG1'}, [0], Tfixed, '80alt-OC-alpha100-P6-bestT', 100, 0.1, 6, -1, sec63folder); 
end

% Merge replication results and  for cKG1 for the plot
for i = 1:NUMOFREPS
    load(strcat(sec63folder,'80alt-OC-alpha100-P6-bestT-cKG1-repnum-',num2str(i),'.mat'))
    mergedOC.allrule = X.allrule;
    mergedOC.parameters = X.parameters;
    mergedOC.detailed(i) = X.detailed(i);
end  
mymat = strcat(sec63folder,'merged-80alt-OC-alpha100-P6-bestT-cKG1','.mat');
save(mymat,'mergedOC');

%%% Generate and save the plot
Tstoplot = [1,100:100:Tfixed];
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
set(gca,'xlim',[0 2500]);
xlabel('Sample size');
ylabel('log_{10}($)');
legend('E[OC]','E[TC]','E[SC]');
set(gca,'FontSize',36)
set(gca,'fontname','times')

figurename = strcat(sec63folder,'80alt-OC-alpha100-P6-bestT-cKG1');
savefig(f1, strcat(figurename, '.fig'));
saveas(f1, figurename, 'epsc')

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
% set(gca,'xlim',[log10(0) log10(2500)]);
% xlabel('log_{10}(Sample size)');
% ylabel('log_{10}($)');
% legend('E[OC]','E[TC]','E[SC]');
% set(gca,'FontSize',36)
% set(gca,'fontname','times')