function [result,parameters] = FuncAppCEVIandCompTime( myJobNum, repn, alttograph, periodtograph, expname, alphaval, stdev, costv, foldername)
%FuncAppCEVIandCompTime
% PURPOSE: Generates figures that depict EVI and computation times for
% problems with 5:5:100 arms for allocation policies cKG1, cKG*, cPDELower, 
% cPDEUpper, and cPDE.
%
% INPUTS: 
% myJobNum: sometimes used for submitting to a server, otherwise any number
%   works
% repn: number, sample path number (uses random variables and seed for that
%   sample path)
% alttograph: number, which alterantive's EVI to calculate, must be below 5
% periodtograph: number, calcualte EVI after how many periods
% expname: string, experiment name
% alphaval: number, determines zeta = alphaval/(M-1)^2
% stdev: number, sampling standard deviation (sqrt(lambda))
% costv: number, sampling cost c_i= 10^(costv)
% foldername: string, folder name to save the .mat file
%
% OUTPUTS: Generates and saves two .fig and two .eps files
%
% WORKFLOW: Called in PlotsAppC.m

%%
    %% Initilization work
    % needed for the server
    addpath(genpath(kgcbfolder),genpath(pdecodefolder),genpath(pdecorrfolder));
    
    % load standardized solution files
    PDELocalInit;
    [cgSoln, cfSoln, cgOn, cfOn] = PDELoadSolnFiles(strcat(pdecode, 'Matfiles/'), false); %load solution files
    
    %Defines rules
    DefineRules;
    
    % Number of arms in the problem to test over
    Mvec = 5:5:100;
    
    % Initilization
    evilower = zeros(1,size(Mvec,2));
    eviupper = zeros(1,size(Mvec,2));
    evionline = zeros(1,size(Mvec,2));
    evickgstar = zeros(1,size(Mvec,2));
    evickg = zeros(1,size(Mvec,2));

    elapsedtimelower = zeros(1,size(Mvec,2));
    elapsedtimeupper = zeros(1,size(Mvec,2));
    elapsedtimeonline = zeros(1,size(Mvec,2));
    elapsedtimeckgstar = zeros(1,size(Mvec,2));
    elapsedtimeckg = zeros(1,size(Mvec,2));

    %Calculate EVI and record the computation time for each M
    for m = 1:size(Mvec,2)
        M = Mvec(m);
        P = 10^4;
        I = zeros(M,1);
        c = (10^costv)*ones(1,M);
        delta=1; % undiscounted
        lambdav = (stdev^2)*ones(1,M);

        %Define the modeler's prior on thetas
        mu0=zeros(M,1);
        alphaval = alphaval;
        %alpha0 = alphaval/(M-1)^2;
        beta0 = 1/2;
        %This method creates a non-positive semidefinite matrix for M=80.
        %Therefore, I use PowExpCov from matlabKG code. Both method give the same
        %results for M=20, but PowExpCov is more accurate as M gets larger.
        % for i=1:M
        %     for j=1:M
        %         sigma0(i,j) = beta0*exp(-alpha0*(i-j)^2);
        %     end
        % end
        [sigma0,~] = PowExpCov(beta0,(M-1)/sqrt(alphaval),2,M,1);
        
        %Define the nature's prior on
        rpimu0=mu0;
        rpisigma0 = sigma0;
        efns = lambdav./diag(sigma0)';
        
        pdetieoption = 'kgstar';
        list = {'M',M,'efns',efns, 'lambdav',lambdav,'mu0',mu0,'P',P,'I',I,'c',c,'delta',delta,'sigma0',sigma0,'rpisigma0',rpisigma0,'rpimu0',rpimu0,'pdetieoption',pdetieoption, 'randomps', 0};
        %list = {'M',M,'rho',rho,'efns',efns, 'lambdav',lambdav,'mu0',mu0,'P',P,'I',I,'c',c,'delta',delta,'Tfixed',Tfixed,'sigma0',sigma0,'thetav',thetav};
        [ parameters, rval ] = SetParametersFunc( list );

        % simulation
        rng(parameters.seed(repn),'twister');
        thetavalue = TrueMeanCreator( parameters, repn); %actual mean value
        if(parameters.crn==1)
            observ = parameters.observ(:,:,repn); %observation for ith replication
        else
            observ = [];
        end

        %Mu and sigma values
        mucur=parameters.mu0;
        sigmacur=parameters.sigma0;

        %Update mean by sampling randomly
        for j = 1:periodtograph
            i = randi([1 M]);
            y = normrnd(thetavalue(i),sqrt(parameters.lambdav(i))); 
            [mucur,sigmacur] = BayesianUpdate(mucur,sigmacur,i, y, parameters.lambdav(i));
        end

        [~,~,~,Mprime] = TransformtoLinearVersion( mucur, sigmacur, parameters, alttograph );
        fprintf('M = %d, Mprime = %d \n', M, Mprime)

        Tstart = tic;
        evilower(m) = cPDELowerUndis( cfSoln, parameters, mucur, sigmacur, alttograph );
        elapsedtimelower(m) = toc(Tstart);
        Tstart = tic;
        eviupper(m) = cPDEUpperUndisNoOpt( cfSoln, parameters, mucur, sigmacur, alttograph );
        elapsedtimeupper(m) = toc(Tstart);
        Tstart = tic;
        evionline(m) = cPDEUndis( parameters, mucur, sigmacur, alttograph );
        elapsedtimeonline(m) = toc(Tstart);
        Tstart = tic;
        [ ~, kgistar] = cKGstarUndis( parameters, mucur, sigmacur, alttograph );
        evickgstar(m) = parameters.P*log(kgistar);
        elapsedtimeckgstar(m) = toc(Tstart);
        Tstart = tic;
        kgi = cKG1Undis( parameters, mucur, sigmacur, alttograph);
        evickg(m) = parameters.P*log(kgi);
        elapsedtimeckg(m) = toc(Tstart);
    end

    allevis = [evilower; eviupper; evionline; evickgstar; evickg];
    alltimes = [elapsedtimelower; elapsedtimeupper; elapsedtimeonline; elapsedtimeckgstar; elapsedtimeckg];

    % result.thetavalue = thetavalue;
    result.alttograph = alttograph;
    result.periodtograph = periodtograph;
    result.alphaval = alphaval;
    result.stdev = stdev;
    result.costv = costv;

    % results.t = time;
    % results.lastt = t; %period in which the algorithm stopped
    % results.alt = alt;
    % results.mu = muvec;
    % results.sigma = sigmavec;
    % results.y = yvec;
    % result.evilower = evilower;
    % result.eviupper = eviupper;
    % result.evionline = evionline;
    % result.evickgstar = evickgstar;
    % result.evickg = evickg;

    result.allevis = allevis;
    result.alltimes = alltimes;

    %% Create a graph of the computation time
    % linS = {'-k','--b',':g','-.r','-sc','-*m','-ok','-+r','-db','+g'};
    f1 = figure;
    axes1 = axes;
    hold(axes1,'on');
    logalltimes = log10(alltimes);
    h = plot(Mvec',logalltimes,'MarkerSize',10,'LineWidth',2);
    set(h,{'Marker'},{'x'; 'd'; '+'; 's'; 'o'})
    set(h,{'Color'},{[0 0.4470 0.7410]; [0.8500,0.3250,0.0980]; [0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880]})
    legend('cPDELower', 'cPDEUpper', 'cPDE', 'cKG\fontsize{20}\ast', 'cKG\fontsize{20}1')
    xlabel('Number of Alternatives in the Problem')
    ylabel('Log_{10}(CPU Time)')
    set(axes1,'FontName','Times New Roman','FontSize',36);
    legend(axes1,'show');

    % Save figure to a file
    if  ~strcmpi(expname,'deneme')
        myfigure = strcat(foldername,'CompTime','-',expname,'-rep',num2str(repn), '-alt', num2str(alttograph), '-period', num2str(periodtograph));
        savefig(f1, strcat(myfigure, '.fig'));
        saveas(f1, myfigure, 'epsc');
    end

    %% Create a graph of the difference between EVIs
    % linS = {'-k','--b',':g','-.r','-sc','-*m','-ok','-+r','-db','+g'};
    allevisdiff = allevis(3,:) - allevis; % subtract from evionline, lower the better

    f2 = figure;
    axes1 = axes;
    hold(axes1,'on');
    h = plot(Mvec',allevisdiff([1,2,4,5],:),'MarkerSize',10,'LineWidth',2);
    set(h,{'Marker'},{'x'; 'd'; 's'; 'o'})
    set(h,{'Color'},{[0 0.4470 0.7410]; [0.8500,0.3250,0.0980]; [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880]})
    legend('cPDE - cPDELower', 'cPDE - cPDEUpper', 'cPDE - cKG\fontsize{20}\ast', 'cPDE - cKG\fontsize{20}1')
    xlabel('Number of Alternatives in the Problem')
    ylabel(strcat('EVI of Alternative ', num2str(alttograph), 'at Period ', num2str(periodtograph)))
    set(axes1,'FontName','Times New Roman','FontSize',36);
    legend(axes1,'show');

    % %%%%%%%%% Save figure to a file %%%%%%%%
    if  ~strcmpi(expname,'deneme')
        myfigure = strcat(foldername,'EVIDiff','-',expname,'-rep',num2str(repn), '-alt', num2str(alttograph),'-period', num2str(periodtograph));
        savefig(f2, strcat(myfigure, '.fig'));
        saveas(f2, myfigure, 'epsc');
    end

% %%%%%%%%% Creates a graph of EVIs %%%%%%%%
% % linS = {'-k','--b',':g','-.r','-sc','-*m','-ok','-+r','-db','+g'};
% f3 = figure;
% h = plot(Mvec',allevis);
% set(h,{'Marker'},{'x'; 'd'; '+'; 's';'o'})
% legend('cPDELower', 'cPDEUpper', 'cPDE', 'cKG*', 'cKG')
% title('EVI')
% xlabel('Number of Alternatives in the Problem')
% ylabel(strcat('EVI of Alternative ', num2str(alttograph), 'at Period ', num2str(periodtograph)))
% 
% 
% % %%%%%%%%% Save figure to a file %%%%%%%%
% if  ~strcmpi(expname,'deneme')
%     myfigure = strcat(foldername,'EVIs','-',expname,'-rep',num2str(repn), '-alt', num2str(alttograph),'-period', num2str(periodtograph));
%     savefig(f3, strcat(myfigure, '.fig'));
%     saveas(f3, myfigure, 'epsc');
% end
end