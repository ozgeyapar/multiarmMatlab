function GenerateEVIvsmu0Fig(mu0istotest, i, cfSoln, parameters, foldername, filename)
%GenerateEVIvsmu0Fig
% PURPOSE: Plots EVIs approximated by cPDELower, cPDEUpper, cPDE, cKG1 and 
% cKG* methods for mu0 values arm i given as inputs.
%
% INPUTS: 
% mu0istotest: prior mean values to calculate EVI at
% i: arm to calcualte the EVI for
% cfSoln: variable which contains the standardized solution
%   for undiscounted problem. 
% parameters: struct, holds the problem parameters
% foldername: string, directory to be saved, -1 if it will not be saved
% filename: string, the name of the figure file if it will be saved
%
% OUTPUTS: Generates a plot and saves it as figurename.fig and 
% figurename.eps if specified.
%
%%  
    % Initilize the vectors to collect the evi values
    evilower = zeros(1,size(mu0istotest,2));
    eviupper = zeros(1,size(mu0istotest,2));
    evionline = zeros(1,size(mu0istotest,2));
    evickgstar = zeros(1,size(mu0istotest,2));
    evickg = zeros(1,size(mu0istotest,2));
    
    % Calculate EVi for each mu0 given as input
    mu0 = parameters.mu0;
    for ind = 1:size(mu0istotest,2)
        mu0(i) = mu0istotest(ind);
        evilower(ind) = cPDELowerUndis( cfSoln, parameters, mu0, parameters.sigma0, i );
        eviupper(ind) = cPDEUpperUndisNoOpt( cfSoln, parameters, mu0, parameters.sigma0, i );
        evionline(ind) = cPDEUndis( parameters, mu0, parameters.sigma0, i );
        [ ~, kgistar] = cKGstarUndis( parameters, mu0, parameters.sigma0, i );
        evickgstar(ind) = parameters.P*log(kgistar);
        kgi = cKG1Undis( parameters, mu0, parameters.sigma0, i );
        evickg(ind) = parameters.P*log(kgi);
    end
    allevis = [evilower; eviupper; evionline; evickgstar; evickg];

    fec1 = figure;
    axes1 = axes;
    hold(axes1,'on');
    h = plot(repmat(mu0istotest,5,1)',allevis','MarkerSize',10,'LineWidth',2);
    PDEUtilStdizeFigure(fec1,0.9,20,true); % SEC: Normalize the size of the plot
    set(h,{'Marker'},{'x'; 'd'; '+'; 's'; 'o'})
    set(h,{'Color'},{[0 0.4470 0.7410]; [0.8500,0.3250,0.0980]; [0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880]})
    legend('cPDELower', 'cPDEUpper', 'cPDE', 'cKG\fontsize{20}\ast', 'cKG\fontsize{20}1')
    %title("M'=3, sampling from i = 1")
    xlabel('\mu_1^0')
    ylabel('EVI')
    set(axes1,'FontName','Times New Roman','FontSize',36);
    legend(axes1,'show');
    
   if foldername ~= -1
        %Save the figure
        CheckandCreateDir( foldername )
        savefig(fec1, strcat(foldername, filename, '.fig'));
        saveas(fec1, strcat(foldername, filename), 'epsc')
    end



end

