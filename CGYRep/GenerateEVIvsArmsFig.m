function GenerateEVIvsArmsFig(armstotest, cfSoln, parameters, foldername, filename)
%GenerateEVIvsArmsFig
% PURPOSE: Plots EVIs approximated by cPDELower, cPDEUpper, cPDE, cKG1 and 
% cKG* methods for across all arms given as input.
%
% INPUTS: 
% armstotest: arms to include in the figure
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
    % Initilize
    evilower = zeros(1,size(armstotest,2));
    eviupper = zeros(1,size(armstotest,2));
    evionline = zeros(1,size(armstotest,2));
    evickgstar = zeros(1,size(armstotest,2));
    evickg = zeros(1,size(armstotest,2));
    
    % Calculate EVIs
    for i = 1:size(armstotest,2)
        ind = armstotest(i);
        evilower(i) = cPDELowerUndis( cfSoln, parameters, parameters.mu0, parameters.sigma0, ind );
        eviupper(i) = cPDEUpperUndisNoOpt( cfSoln, parameters, parameters.mu0, parameters.sigma0, ind );
        evionline(i) = cPDEUndis( parameters, parameters.mu0, parameters.sigma0, ind );
        [ ~, kgistar] = cKGstarUndis( parameters, parameters.mu0, parameters.sigma0, ind );
        evickgstar(i) = parameters.P*log(kgistar);
        kgi = cKG1Undis( parameters, parameters.mu0, parameters.sigma0, ind );
        evickg(i) = parameters.P*log(kgi);
    end
    allevis = [evilower; eviupper; evionline; evickgstar; evickg];

    fec = figure;
    axes1 = axes;
    hold(axes1,'on');
    h = plot(repmat(armstotest,5,1)',allevis','MarkerSize',10,'LineWidth',2);
    set(h,{'Marker'},{'x'; 'd'; '+'; 's'; 'o'})
    set(h,{'Color'},{[0 0.4470 0.7410]; [0.8500,0.3250,0.0980]; [0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880]})
    legend('cPDELower', 'cPDEUpper', 'cPDE', 'cKG\fontsize{20}\ast', 'cKG\fontsize{20}1')
    xlabel('Arm i')
    ylabel('EVI')
    set(axes1,'FontName','Times New Roman','FontSize',36);
    legend(axes1,'show');
    
   if foldername ~= -1
        %Save the figure
        CheckandCreateDir( foldername )
        savefig(fec, strcat(foldername, filename, '.fig'));
        saveas(fec, strcat(foldername, filename), 'epsc')
    end

end

