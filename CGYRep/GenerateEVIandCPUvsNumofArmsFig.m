function GenerateEVIandCPUvsNumofArmsFig (Mvec, cfSoln, alttograph, periodtograph, alphaval, pval, foldername, filename)
%GenerateEVIandCPUvsNumofArmsFig
% PURPOSE: Generates figures that depict EVI and computation times for the
% syntetic problem with different number of arms for allocation policies 
% cKG1, cKG*, cPDELower, cPDEUpper, and cPDE.
%
% INPUTS: 
% Mvec: number of arms in the problem to include in the figure
% cfSoln: variable which contains the standardized solution
%   for undiscounted problem. 
% alttograph: number, which alterantive's EVI to calculate, must be below
%   minimum of Mvec
% periodtograph: number, calcualte EVI after how many periods
% alphaval: for alpha = alphaval/(M-1)^2
% pval: for P = 10^pval
% foldername: string, directory to be saved, -1 if it will not be saved
% filename: string, the name of the figure file if it will be saved
%
% OUTPUTS: Generates a plot and saves it as figurename.fig and 
% figurename.eps if specified.

%%
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
        [ parameters ] = ProblemSetupSynthetic( M, alphaval, pval);

        % simulation
        rng(44,'twister');
        thetastd = normrnd(0,1,100,1);
        A =  cholcov(parameters.rpisigma0)'; %A*A' = sigma0
        if size(A,2)<parameters.M %a quick fix if needed
           A = cholcov(parameters.rpisigma0*20)'/sqrt(20);
        end
        thetav = A*thetastd(1:parameters.M)+parameters.rpimu0;
        mucur=parameters.mu0;
        sigmacur=parameters.sigma0;
        rng(487429276,'twister');
        %Update mean by sampling randomly
        for j = 1:periodtograph
            i = randi([1 parameters.M]);
            y = normrnd(thetav(i),sqrt(parameters.lambdav(i))); 
            [mucur,sigmacur] = BayesianUpdate(mucur,sigmacur,i, y, parameters.lambdav(i));
        end

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

    %% Create a graph of the computation time
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
    if foldername ~= -1
        %Save the figure
        CheckandCreateDir( foldername )
        savefig(f1, strcat(foldername, filename, '-CompTime', '.fig'));
        saveas(f1, strcat(foldername, filename, '-CompTime'), 'epsc')
    end
    
    %% Create a graph of the difference between EVIs
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

    % Save figure to a file   
    if foldername ~= -1
        %Save the figure
        CheckandCreateDir( foldername )
        savefig(f2, strcat(foldername, filename, '-EVIDiff', '.fig'));
        saveas(f2, strcat(foldernam, filename, '-EVIDiff'), 'epsc')
    end
end