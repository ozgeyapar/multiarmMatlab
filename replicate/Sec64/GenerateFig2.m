% GenerateFig2.m:
% PURPOSE: A macro with the code to generate and plot GRP, Robust and Tilted
% priors for sample path 5 and for the problem outlined in Sec 6.4.
%
% OUTPUTS: Generates and saves one .fig file and .eps file.
%
% WORKFLOW: Called in ReplicateFiguresRev1.m after defining sec64folder 

%% Plot the estimated prior for sample path n = 5
n = 5;
FuncSec64TC(0, n, 'aCKG:sfixed', 0, 'forFigure2', 1, 'gpr', 'variables', 0, sec64folder, 1, 1/2, 1);
savefig(gcf, strcat(sec64folder,'Sec64-fig1-priors.fig'));
saveas(gcf, strcat(sec64folder,'Sec64-fig1-priors'), 'epsc')