% PlotFig1.m:
% PURPOSE: A macro with the code to:
%   1) Merge simulation replications generated by SimforFig1.m into a
%   single .mat file for each problem setup and each allocation rule 
%   (4x9=36 .mat files in total)
%   2) Generate four figures referred in Section 6.2 and save these as 
%   .fig and .eps 
%   3) Calculate the mean difference and standard error matrices for each
%   problem setup at period 100 and saves it to a variable for each problem
%   setup.
%
% OUTPUTS: Generates 9x4 = 36 .mat files (9 policies, 4 problem setups), 
% four .fig files, four .eps files, and saves 8 variables to workspace 
% (meandOCp6a100, sedOCp6a100, meandOCp8a100, sedOCp8a100, meandOCp6a16, 
% sedOCp6a16, meandOCp8a16, sedOCp8a16).
%
% WORKFLOW: Called in ReplicateFiguresRev1.m after defining sec62folder and
% calling SimforFig1.m

%% Merge data for each simulation replication to a single file for for each
%% allocation rule and each problem setup
alphaval = 100;
pval = 6;
names = {'Equal', 'ESPcapB', 'Random-pis1', 'Variance',  'cKG1(ratio)', 'cKGstar(ratio)', 'cPDEUpper(equal)-tiekg', 'cPDELower-tiekg','cPDE-tiekg'};
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

alphaval = 100;
pval = 8;
names = {'Equal', 'ESPcapB', 'Random-pis1', 'Variance',  'cKG1(ratio)', 'cKGstar(ratio)', 'cPDEUpper(equal)-tiekg', 'cPDELower-tiekg','cPDE-tiekg'};
for j = 1:size(names,2)
    for i = 1:NUMOFREPS
        load(strcat(sec62folder,'80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval),'-c0-',names{i},'-repnum-',num2str(i),'.mat'))
        mergedOC.allrule = X.allrule;
        mergedOC.parameters = X.parameters;
        mergedOC.detailed(i) = X.detailed(i);
    end  
    mymat = strcat(sec62folder,'merged-80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval),'-c0-',names{i},'.mat');
    save(mymat,'mergedOC');
end

alphaval = 16;
pval = 6;
names = {'Equal', 'ESPcapB', 'Random-pis1', 'Variance',  'cKG1(ratio)', 'cKGstar(ratio)', 'cPDEUpper(equal)-tiekg', 'cPDELower-tiekg','cPDE-tiekg'};
for j = 1:size(names,2)
    for i = 1:NUMOFREPS
        load(strcat(sec62folder,'80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval),'-c0-',names{i},'-repnum-',num2str(i),'.mat'))
        mergedOC.allrule = X.allrule;
        mergedOC.parameters = X.parameters;
        mergedOC.detailed(i) = X.detailed(i);
    end  
    mymat = strcat(sec62folder,'merged-80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval),'-c0-',names{i},'.mat');
    save(mymat,'mergedOC');
end

alphaval = 16;
pval = 8;
names = {'Equal', 'ESPcapB', 'Random-pis1', 'Variance',  'cKG1(ratio)', 'cKGstar(ratio)', 'cPDEUpper(equal)-tiekg', 'cPDELower-tiekg','cPDE-tiekg'};
for j = 1:size(names,2)
    for i = 1:NUMOFREPS
        load(strcat(sec62folder,'80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval),'-c0-',names{i},'-repnum-',num2str(i),'.mat'))
        mergedOC.allrule = X.allrule;
        mergedOC.parameters = X.parameters;
        mergedOC.detailed(i) = X.detailed(i);
    end  
    mymat = strcat(sec62folder,'merged-80alt-OC-alpha',num2str(alphaval),'-P',num2str(pval),'-c0-',names{i},'.mat');
    save(mymat,'mergedOC');
end

%% Generate the figure and calculate the mean difference and standard errors
%% for the problem with P=10^6 and zeta = 100/(80-1)^2
clear result
namesneworder = {'Equal', 'ESPcapB', 'Random-pis1', 'Variance',  'cKG1(ratio)', 'cKGstar(ratio)', 'cPDEUpper(equal)-tiekg', 'cPDE-tiekg', 'cPDELower-tiekg'};
alpha = '100';
cost = '0';
p = '6';
for i = 1:size(namesneworder,2)
    load(strcat(sec62folder,'merged-80alt-OC-alpha',alpha,'-P',p,'-c',cost,'-',namesneworder{i},'.mat'))
    result.rule(i) = mergedOC;
end
%names = {'Equal', 'iKG1', 'ESPb', 'ESPB', 'Random', 'Variance', 'cKG\fontsize{20}1', 'cKG\fontsize{20}\ast', 'cPDEUpper', 'cPDE', 'cPDELower'};
namesforlegend = {'Equal', 'ESPB', 'Random', 'Variance', 'cKG\fontsize{20}1', 'cKG\fontsize{20}\ast', 'cPDEUpper', 'cPDE', 'cPDELower'};
linS = {'-+r','--k','-xm','-og','-sr','-dm','-^g','->k','-.b'};
figurename = strcat(sec62folder,'sec62-P6-alpha100');
PlotLogOCCurves( result, namesforlegend, 0, NUMOFREPS, NUMOFREPS, 100,linS, figurename)
PlotLogOCCurves( result, namesforlegend, 1, NUMOFREPS, NUMOFREPS, 100,linS, figurename)

%Confidence intervals at t = 100
names = {'Equal', 'ESPB', 'Random', 'Variance', 'cKG1', 'cKG*', 'cPDEUpper', 'cPDE', 'cPDELower'};
[meandOCp6a100, sedOCp6a100] = CalculateandPlotCIofOC( result, NUMOFREPS, NUMOFREPS, names, 100, linS, 100, 0);

%% Generate the figure and calculate the mean difference and standard errors
%% for the problem with P=10^8 and zeta = 100/(80-1)^2
clear result
%names = {'Equal', 'iKG1(ratio)', 'ESPb', 'ESPcapB', 'Random-pis1', 'Variance',  'cKG1(ratio)', 'cKGstar(ratio)', 'cPDEUpper(equal)-tiekg', 'cPDELower-tiekg'};
namesneworder = {'Equal', 'ESPcapB', 'Random-pis1', 'Variance',  'cKG1(ratio)', 'cKGstar(ratio)', 'cPDEUpper(equal)-tiekg', 'cPDE-tiekg', 'cPDELower-tiekg'};
alpha = '100';
cost = '0';
p = '8';
for i = 1:size(namesneworder,2)
    load(strcat(sec62folder,'merged-80alt-OC-alpha',alpha,'-P',p,'-c',cost,'-',namesneworder{i},'.mat'))
    result.rule(i) = mergedOC;
end
%names = {'Equal', 'iKG1', 'ESPb', 'ESPB', 'Random', 'Variance', 'cKG\fontsize{20}1', 'cKG\fontsize{20}\ast', 'cPDEUpper', 'cPDE', 'cPDELower'};
namesforlegend = {'Equal', 'ESPB', 'Random', 'Variance', 'cKG\fontsize{20}1', 'cKG\fontsize{20}\ast', 'cPDEUpper', 'cPDE', 'cPDELower'};
linS = {'-+r','--k','-xm','-og','-sr','-dm','-^g','->k','-.b'};
figurename = strcat(sec62folder,'sec62-P8-alpha100');
PlotLogOCCurves( result, namesforlegend, 0, NUMOFREPS, NUMOFREPS, 100,linS, figurename)
PlotLogOCCurves( result, namesforlegend, 1, NUMOFREPS, NUMOFREPS, 100,linS, figurename)

%Confidence intervals at t = 100
names = {'Equal', 'ESPB', 'Random', 'Variance', 'cKG1', 'cKG*', 'cPDEUpper', 'cPDE', 'cPDELower'};
[meandOCp8a100, sedOCp8a100] = CalculateandPlotCIofOC( result, NUMOFREPS, NUMOFREPS, names, 100, linS, 100, 0);

%% Generate the figure and calculate the mean difference and standard errors
%% for the problem with P=10^6 and zeta = 16/(80-1)^2
clear result
namesneworder = {'Equal', 'ESPcapB', 'Random-pis1', 'Variance',  'cKG1(ratio)', 'cKGstar(ratio)', 'cPDEUpper(equal)-tiekg', 'cPDE-tiekg', 'cPDELower-tiekg'};
alpha = '16';
cost = '0';
p = '6';
for i = 1:size(namesneworder,2)
    load(strcat(sec62folder,'merged-80alt-OC-alpha',alpha,'-P',p,'-c',cost,'-',namesneworder{i},'.mat'))
    result.rule(i) = mergedOC;
end
namesforlegend = {'Equal', 'ESPB', 'Random', 'Variance', 'cKG\fontsize{20}1', 'cKG\fontsize{20}\ast', 'cPDEUpper', 'cPDE', 'cPDELower'};
linS = {'-+r','--k','-xm','-og','-sr','-dm','-^g','->k','-.b'};
figurename = strcat(sec62folder,'sec62-P6-alpha16');
PlotLogOCCurves( result, namesforlegend, 0, NUMOFREPS, NUMOFREPS, 100,linS, figurename)
PlotLogOCCurves( result, namesforlegend, 1, NUMOFREPS, NUMOFREPS, 100,linS, figurename)

%Confidence intervals at t = 100
names = {'Equal', 'ESPB', 'Random', 'Variance', 'cKG1', 'cKG*', 'cPDEUpper', 'cPDE', 'cPDELower'};
[meandOCp6a16, sedOCp6a16] = CalculateandPlotCIofOC( result, NUMOFREPS, NUMOFREPS, names, 100, linS, 100, 0);

%% Generate the figure and calculate the mean difference and standard errors
%% for the problem with P=10^8 and zeta = 16/(80-1)^2
clear result
namesneworder = {'Equal', 'ESPcapB', 'Random-pis1', 'Variance',  'cKG1(ratio)', 'cKGstar(ratio)', 'cPDEUpper(equal)-tiekg', 'cPDE-tiekg', 'cPDELower-tiekg'};
alpha = '16';
cost = '0';
p = '8';
for i = 1:size(namesneworder,2)
    load(strcat(sec62folder,'merged-81alt-OC-alpha',alpha,'-P',p,'-c',cost,'-',namesneworder{i},'.mat'))
    result.rule(i) = mergedOC;
end
namesforlegend = {'Equal', 'ESPB', 'Random', 'Variance', 'cKG\fontsize{20}1', 'cKG\fontsize{20}\ast', 'cPDEUpper', 'cPDE', 'cPDELower'};
linS = {'-+r','--k','-xm','-og','-sr','-dm','-^g','->k','-.b'};
figurename = strcat(sec62folder,'sec62-P8-alpha16');
PlotLogOCCurves( result, namesforlegend, 0, NUMOFREPS, NUMOFREPS, 100,linS, figurename)
PlotLogOCCurves( result, namesforlegend, 1, NUMOFREPS, NUMOFREPS, 100,linS, figurename)

%Confidence intervals at t = 100
names = {'Equal', 'ESPB', 'Random', 'Variance', 'cKG1', 'cKG*', 'cPDEUpper', 'cPDE', 'cPDELower'};
[meandOCp8a16, sedOCp8a16] = CalculateandPlotCIofOC( result, NUMOFREPS, NUMOFREPS, names, 100, linS, 100, 0);
