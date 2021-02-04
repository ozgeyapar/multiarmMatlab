% PlotsAppC.m:
% PURPOSE: A macro with the code to generate Figures EC1, EC2, EC3 and EC4 
% in Appendix of correlated multiarms paper.
%
% OUTPUTS: Generates 4. eps and 4 .fig files for each figure.
%
% WORKFLOW: Called in ReplicateFiguresRev1.m after defining appc23folder 

%% Load solutions for cPDELower and cPDEUpper
PDELocalInit;
fignum = 20;
onflag = false;
[cgSoln, cfSoln, cgOn, cfOn] = PDELoadSolnFiles(PDEmatfilebase, onflag);

%% FIGURE EC1
% Generate a problem with Mprime = 3
myk = 3;        % number of alternatives
parameters.c = ones(1,myk);          % cost per sample
parameters.P = 1;      % population size upon finishing
parameters.I = zeros(myk,1);
parameters.lambdav = 1e6*ones(1,myk);
parameters.delta = 1; %no discounting
mu0 = [0;0.5;0];
efnsi0 = [5, 5, 5];
rho0 = [1, 0.5, -0.5; 0.5, 1, 0.25; -0.5, 0.25, 1];
sigma0 = parameters.lambdav./efnsi0; %vector of prior variances
sigma0 =  rho0.*(sqrt(sigma0)'*sqrt(sigma0)); %covariance matrix

%Sampling from alternative i = 1
i = 1;
%Check Mprime is 3
[~,~,~,Mprime] = TransformtoLinearVersion( mu0, sigma0, parameters, i )

mu0istotest = (-3:0.1:3)*sqrt(sigma0(i,i));
evilower = zeros(1,size(mu0istotest,2));
eviupper = zeros(1,size(mu0istotest,2));
evionline = zeros(1,size(mu0istotest,2));
evickgstar = zeros(1,size(mu0istotest,2));
evickg = zeros(1,size(mu0istotest,2));
for ind = 1:size(mu0istotest,2)
    mu0(i) = mu0istotest(ind);
    evilower(ind) = cPDELowerUndis( cfSoln, parameters, mu0, sigma0, i );
    %eviupper(ind) = cPDEUpperUndisNoOpt( cfSoln, parameters, mu0, sigma0, i );
    %evionline(ind) = cPDEUndis( parameters, mu0, sigma0, i );
    [ ~, kgistar] = cKGstarUndisRatioCopy( parameters, mu0, sigma0, i );
    evickgstar(ind) = parameters.P*log(kgistar);
    kgi = cKG1Undis( parameters, mu0, sigma0, i );
    evickg(ind) = parameters.P*log(kgi);
    %[~,~,~,Mprimemat3(ind)] = TransformtoLinearVersion( mu0, sigma0, parameters, i );
end
allevis3 = [evilower; eviupper; evionline; evickgstar; evickg];

fec1 = figure;
axes1 = axes;
hold(axes1,'on');
h = plot(repmat(mu0istotest,5,1)',allevis3','MarkerSize',10,'LineWidth',2);
set(h,{'Marker'},{'x'; 'd'; '+'; 's'; 'o'})
set(h,{'Color'},{[0 0.4470 0.7410]; [0.8500,0.3250,0.0980]; [0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880]})
legend('cPDELower', 'cPDEUpper', 'cPDE', 'cKG\fontsize{20}\ast', 'cKG\fontsize{20}1')
%title("M'=3, sampling from i = 1")
xlabel('\mu_1^0')
ylabel('EVI')
set(axes1,'FontName','Times New Roman','FontSize',36);
legend(axes1,'show');

myfigure = strcat(appc23folder,'3alt-acrossmeans');
savefig(fec1, strcat(myfigure, '.fig'));
saveas(fec1, myfigure, 'epsc')

%% FIGURE EC2
%%% 80 alternative problem from the paper
%%% 10 random allocation later
rng default
myk = 80;        % number of alternatives
M = myk;
parameters.c = ones(1,myk);          % cost per sample
parameters.P = 10^4;      % population size upon finishing
parameters.I = zeros(myk,1);
parameters.lambdav = 0.01*ones(1,myk);
parameters.delta = 1; %no discounting
mu0=zeros(M,1);
alphaval = 16;
beta0 = 1/2;
[sigma0,~] = PowExpCov(beta0,(M-1)/sqrt(alphaval),2,M,1);
efns = parameters.lambdav./diag(sigma0)';

%Define the nature's prior on
rpimu0=mu0;
rpisigma0 = sigma0;
thetav = mvnrnd(rpimu0,rpisigma0);

mucur = mu0;
sigmacur = sigma0;

for j = 1:10
    i = randi([1 M]);
    y = normrnd(thetav(i),sqrt(parameters.lambdav(i))); 
    [mucur,sigmacur] = BayesianUpdate(mucur,sigmacur,i, y, parameters.lambdav(i), M);
end

mu0 = mucur;
sigma0 = sigmacur;

%mu0istotest = (-3.5:0.5:3.5)*sqrt(sigma0(i,i));
alts = 1:5:myk;
evilower = zeros(1,size(1:5:myk,2));
eviupper = zeros(1,size(1:5:myk,2));
evionline = zeros(1,size(1:5:myk,2));
evickgstar = zeros(1,size(1:5:myk,2));
evickg = zeros(1,size(1:5:myk,2));
for i = 1:size(1:5:myk,2)
    ind = alts(i);
    evilower(i) = cPDELowerUndis( cfSoln, parameters, mu0, sigma0, ind );
    %eviupper(i) = cPDEUpperUndisNoOpt( cfSoln, parameters, mu0, sigma0, ind );
    %evionline(i) = cPDEUndis( parameters, mu0, sigma0, ind );
    [ ~, kgistar] = cKGstarUndisRatioCopy( parameters, mu0, sigma0, ind );
    evickgstar(i) = parameters.P*log(kgistar);
    kgi = cKG1Undis( parameters, mu0, sigma0, ind );
    evickg(i) = parameters.P*log(kgi);
    %[~,~,~,Mprimemat3(ind)] = TransformtoLinearVersion( mu0, sigma0, parameters, ind );
end
allevis5 = [evilower; eviupper; evionline; evickgstar; evickg];

fec2 = figure;
axes1 = axes;
hold(axes1,'on');
h = plot(repmat(1:5:80,5,1)',allevis5','MarkerSize',10,'LineWidth',2);
set(h,{'Marker'},{'x'; 'd'; '+'; 's'; 'o'})
set(h,{'Color'},{[0 0.4470 0.7410]; [0.8500,0.3250,0.0980]; [0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880]})
legend('cPDELower', 'cPDEUpper', 'cPDE', 'cKG\fontsize{20}\ast', 'cKG\fontsize{20}1')
xlabel('Arm i')
ylabel('EVI')
set(axes1,'FontName','Times New Roman','FontSize',36);
legend(axes1,'show');

myfigure = strcat(appc23folder,'80alt-EVIperarm-after10randomall');
savefig(fec2, strcat(myfigure, '.fig'));
saveas(fec2, myfigure, 'epsc')

%% FIGURES EC3 and EC4
[result,parameters] = FuncAppCEVIandCompTime( 0, 1, 5, 5, 'figureec3andec4', 100, 0.1, 0, appc23folder);
