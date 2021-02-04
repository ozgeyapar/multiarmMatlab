function [ mu0, sigma0, lambdav, efns, pilotdetails ] = SimPilotandDetPriorSec64( parameters, samplingparameters, j)
%SimPilotandDetPrior
% PURPOSE: Simulates a pilot dose-response data from the true theta and 
% actual sampling variance, uses this data to estimate a prior
% distribution using Algorithm 2 of Chick, Gans, Yapar (2020), modifies the
% estimated prior distribution as 'robust' or 'tilted' if specified 
% in samplingparameters.priortype.
% BE CAREFUL that this function designed to work when NBASE = 10 and the 
% pilot samples from 5 doses. This function might throw errors if NBASE 
% and number of doses are different.
%
% INPUTS: 
% parameters: struct, problem parameters are included as fields (See 
%   ExampleProblemSetup.m or ExampleProblemSetupwithPilot.m for examples 
%   of how to generate this struct)
% samplingparameters: struct, parameters related to pilot simulation are 
%    included as fields, see ExampleProblemSetupwithPilot.m for an example 
%    of creating this struct
% j: numeric scalar, the simulation replication we are in
%
% OUTPUTS: 
% mu0: estimated prior mean vector
% sigma0: estimated prior covariance matrix
% lambdav: estimated sampling variance vector
% efns: estimated effective number of samples vector
% pilotdetails: includes per-replication details
%   pilotdetails.samplesize: sample size of the pilot,
%   pilotdetails.lessthanNperarm: fraction of times we added extra
%       observations to pilot due to having unusually low efns
%   pilotdetails.higherthanN: fraction of times we added extra
%       observations to pilot due to having unusually high efns
%
% SUGGESTED WORKFLOW: Uses pregenerated standard normal random variables to 
% simulate the pilot data, call after calling SetRandomVars.m for 
% pregeneration. SetRandomVars.m pregenerates 
% values assuming NBASE = 10 and doses has length 5. 

%% 
    %% 1.Do the base number NBASE observations for each dose i in the pilot. 
    responses = zeros(samplingparameters.N,size(samplingparameters.indicestosample,2));
    for i = 1:size(samplingparameters.indicestosample,2)
        ind = samplingparameters.indicestosample(i);
        responses(:,i) = parameters.doserespv(1:samplingparameters.N,i,j)*sqrt(parameters.naturelambdav(ind))+ parameters.thetav(ind);
    end

    data = [repmat(samplingparameters.doses(samplingparameters.indicestosample)',samplingparameters.N,1),reshape(responses',[],1)];

    % % Graph the data set created together with the true theta curve
    % figure
    % hold on
    % plot(samplingparameters.doses,parameters.thetav)
    % scatter(data(:,1),data(:,2)) 

    %% 2.Fit GPR model and get estimates for parameters
    [predmu, predsigma, predlambdav, zeta, sigmasq] = GPRFit(data, samplingparameters.doses);

    %% 3. If the effective sample size (from GPR) of any of the arms tested 
    %  is >= NBASE*(number of arms in the pilot) OR the effective sample 
    %  size (from GPR) of any of the arms tested is <= NBASE,
    %  add 1 observation for each arm in the pilot. Recompute the GPR
    %  estimator,
    %  repeat until the sample size per arm in the pilot exceeds 2*NBASE.
    NBASE = samplingparameters.N*size(samplingparameters.indicestosample,2);
    NofPilot = NBASE;
    sigmaforsampled = predsigma(samplingparameters.indicestosample,samplingparameters.indicestosample);
    efnsvec = predlambdav./diag(sigmaforsampled);
    addsample = 1;
    lessthanN = 0;
    higherthanfullN = 0;
    %%% This portion assumes that is there are 5 doses to be sampled from
    %%% doserespv matrix created in SetRandomVars needs to bigger if more 
    %%% doses wants to be sampled from
    while NofPilot < 2*NBASE && (min(efnsvec) < NofPilot/size(samplingparameters.indicestosample,2) || max(efnsvec) >= NofPilot)
        lessthanN = lessthanN + (min(efnsvec) < NofPilot/size(samplingparameters.indicestosample,2)) ;
        higherthanfullN =  higherthanfullN + (max(efnsvec) >= NofPilot);
        for i = 1:size(samplingparameters.indicestosample,2)
            ind = samplingparameters.indicestosample(i);
            responses(samplingparameters.N+addsample,i) = parameters.doserespv(addsample,size(samplingparameters.indicestosample,2)+i,j)*sqrt(parameters.naturelambdav(ind))+ parameters.thetav(ind);
        end
        data = [repmat(samplingparameters.doses(samplingparameters.indicestosample)',samplingparameters.N+addsample,1),reshape(responses',[],1)];

        [predmu, predsigma, predlambdav, zeta, sigmasq] = GPRFit(data, samplingparameters.doses);
        sigmaforsampled = predsigma(samplingparameters.indicestosample,samplingparameters.indicestosample);
        efnsvec = predlambdav./diag(sigmaforsampled);

        NofPilot = NofPilot + size(samplingparameters.indicestosample,2);
        addsample = addsample + 1;
    end
    
    %% 4. Use alternative fit if 2*NBASE is reached
    if max(efnsvec) >= NofPilot
        [predmu, predsigma, predlambdav, ~, ~] = GPRAltFit(data, samplingparameters.doses, zeta, sigmasq, predlambdav);
    end
    pilotdetails.samplesize = NofPilot;
    pilotdetails.lessthanNperarm = lessthanN/(addsample-1);
    pilotdetails.higherthanN = higherthanfullN/(addsample-1);
    
    %% 5.	Use GPR estimator from full pilot.
    %%% Calculate sample mean per dose
    meanresp = mean(responses, 1);

    %%% Modify the estimated prior if needed
    if strcmp(samplingparameters.priortype, 'gpr')
        mu0=predmu;
        sigma0 = predsigma;
    elseif strcmp(samplingparameters.priortype, 'robust')
        z = samplingparameters.zalpha; %z_alpha in the paper
        maxmu = max([predmu(:); meanresp(:)]);
        maxSigma0sqrt = max(diag(sqrt(predsigma)));
        mu0 = (maxmu+z*maxSigma0sqrt)*ones(parameters.M,1);
        sigma0 = 4*predsigma;
    elseif strcmp(samplingparameters.priortype, 'tilted')
        z = samplingparameters.zalpha; %z_alpha in the paper
        maxmu = max([predmu(:); meanresp(:)]);
        maxSigma0sqrt = max(diag(sqrt(predsigma)));
        mu0 = ones(parameters.M,1);
        for i = 1:parameters.M
            mu0(i) = maxmu + 2*z*(1-i/parameters.M)*maxSigma0sqrt;
        end
        sigma0 = 4*predsigma;
    end

    if samplingparameters.priorind ==1
        sigma0 = diag(diag(sigma0));
    end
    
    lambdav = predlambdav*ones(1,parameters.M);
    efns = lambdav./diag(sigma0)';
    
    if  samplingparameters.graphforprior == 1
        %%%% Plotting three priors for a sample path
        % GPR
        mu0gpr=predmu;
        sigma0gpr = predsigma;
        %robust
        z = samplingparameters.zalpha; %z_alpha in the paper
        maxmu = max([predmu(:); meanresp(:)]);
        maxSigma0sqrt = max(diag(sqrt(predsigma)));
        mu0robust = (maxmu+z*maxSigma0sqrt)*ones(parameters.M,1);
        sigma0robust = 4*predsigma;
        %tilted
        z = samplingparameters.zalpha; %z_alpha in the paper
        maxmu = max([predmu(:); meanresp(:)]);
        maxSigma0sqrt = max(diag(sqrt(predsigma)));
        mu0tilted = ones(parameters.M,1);
        for i = 1:parameters.M
            mu0tilted(i) = maxmu + 2*z*(1-i/parameters.M)*maxSigma0sqrt;
        end
        sigma0tilted = 4*predsigma;

        ticks = strings(1,parameters.M);
        ticks(samplingparameters.indicestosample(1)) = "0";
        ticks(samplingparameters.indicestosample(2)) = "2";
        ticks(samplingparameters.indicestosample(3)) = "4";
        ticks(samplingparameters.indicestosample(4)) = "6";
        ticks(samplingparameters.indicestosample(5)) = "8";

        doses = samplingparameters.doses;
        figure
        h1 = subplot(1,3,1);
        hold on
        plot(doses,parameters.thetav,'k','LineWidth',2, 'MarkerSize',10)
        plot(doses,mu0gpr,'--k','LineWidth',2, 'MarkerSize',10);
        upper = mu0gpr + diag(sqrt(sigma0gpr)); 
        lower = mu0gpr - diag(sqrt(sigma0gpr));
        x2 = [doses, fliplr(doses)];
        inBetween = [upper', fliplr(lower')];
        hfill = fill(x2, inBetween, [17 17 17]/255, 'LineStyle','none');
        set(hfill,'facealpha',.1)
        %scatter(doses(samplingparameters.indicestosample), meanresp, 150, 'xk','LineWidth',2); 
        xticks(doses)
        set(h1,'XTickLabel',ticks)
        set(h1,'XLim',[0,8])
        xlabel('Dose level h_i');
        ylabel('$');
        %legend('\theta_i', '\mu^{0, GPR}_i');
        set(h1,'FontSize',36)
        set(h1,'fontname','times')
        hold off
        % Enlarge figure to full screen.
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);

        h2 = subplot(1,3,2);
        hold on
        plot(doses,parameters.thetav,'k','LineWidth',2, 'MarkerSize',10)
        plot(doses,mu0robust,'--k','LineWidth',2, 'MarkerSize',10);
        upper = mu0robust + diag(sqrt(sigma0robust)); 
        lower = mu0robust - diag(sqrt(sigma0robust));
        x2 = [doses, fliplr(doses)];
        inBetween = [upper', fliplr(lower')];
        hfill = fill(x2, inBetween, [17 17 17]/255, 'LineStyle','none');
        set(hfill,'facealpha',.1)
        %scatter(doses(samplingparameters.indicestosample), meanresp, 150, 'xk','LineWidth',2); 
        xticks(doses)
        set(h2,'XTickLabel',ticks)
        set(h2,'XLim',[0,8])
        xlabel('Dose level h_i');
        ylabel('$');
        %legend('\theta_i', '\mu^{0, Robust}_i');
        set(h2,'FontSize',36)
        set(h2,'fontname','times')
        hold off

        h3 = subplot(1,3,3);
        hold on
        plot(doses,parameters.thetav,'k','LineWidth',2, 'MarkerSize',10)
        plot(doses,mu0tilted,'--k','LineWidth',2, 'MarkerSize',10);
        %scatter(doses(samplingparameters.indicestosample), meanresp, 150, 'xk','LineWidth',2); 
        upper = mu0tilted + diag(sqrt(sigma0tilted)); 
        lower = mu0tilted - diag(sqrt(sigma0tilted));
        x2 = [doses, fliplr(doses)];
        inBetween = [upper', fliplr(lower')];
        hfill = fill(x2, inBetween, [17 17 17]/255, 'LineStyle','none');
        set(hfill,'facealpha',.1)
        %scatter(doses(samplingparameters.indicestosample), meanresp, 150, 'xk','LineWidth',2); 
        xticks(doses)
        set(h3,'XTickLabel',ticks)
        set(h3,'XLim',[0,8])
        xlabel('Dose level h_i');
        ylabel('$');
        %legend('\theta_i', '\mu^{0, Tilted}_i');
        set(h3,'FontSize',36)
        set(h3,'fontname','times')
        y3 = ylim;
        hold off
        moveam = 0.02;
    %     h1.OuterPosition(1) = h1.OuterPosition(1) - moveam;
    %     h1.OuterPosition(3) = h1.OuterPosition(3) - moveam;
    %     h2.OuterPosition(1) = h2.OuterPosition(1) - moveam;
    %     h2.OuterPosition(3) = h2.OuterPosition(3) - moveam;
    %     h3.OuterPosition(1) = h3.OuterPosition(1) - moveam;
    %     h3.OuterPosition(3) = h3.OuterPosition(3) - moveam;
    % 
    %     h1.OuterPosition(2) = h1.OuterPosition(2) + 0.03;
    %     h2.OuterPosition(2) = h2.OuterPosition(2) + 0.03;
    %     h3.OuterPosition(2) = h3.OuterPosition(2) + 0.03;
        set(h1,'YLim',y3)
        set(h2,'YLim',y3)
        set(h3,'YLim',y3)
        Lgnd = legend({'$\theta_i$', '$\mu^{0}_i$', '$\pm \surd\Sigma^0_{i,i}$'});
        %Lgnd = legend({'$\theta_i$', '$\mu^{0}_i$', '$\bar{Y}_i$', '$\pm \surd\Sigma^0_{i,i}$'});
        %Lgnd.Position = [0.89 0.43 0.10 0.25];
        set(Lgnd,'interpreter','Latex')
    end
end

