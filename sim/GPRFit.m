function [predmu, predsigma, predlambdav, zeta, sigmasq] = GPRFit(data, doses)
%GPRFit
% PURPOSE: Implements the 'Fit' stage of Algorithm 2 of Chick, Gans, 
%   Yapar (2020). Matlab predict function does not return covariances so 
%   implmented my own version. 
%
% INPUTS: 
% data: matrix containing doses that were sampled from and responses 
%   obtained, throws an error if there is nan
% doses: the vector of points that needs to be estimated
%
% OUTPUTS: 
% predmu: means estimated for all doses
% predsigma: covariances estimated for all doses
% predlambdav: sampling variance estimated
% zeta: estimated zeta value, that is used to generate predsigma
% sigmasq: estimated sigma value, that is used to generate predsigma
%
%%
    %% Check inputs
    %need to be a column vector
    if size(doses,2)>1
        doses=doses';
    end

    %no nan
    if all(all(isnan(data)))
        warning('nan in the data');
        return; 
    end
    
    %% Estimate the GPR model parameters
    %convert data to table  
    datatable = array2table(data,'VariableNames',{'dose','response'});

    %Fit GPR model with zero mean prior
    gprMdl = fitrgp(datatable,'response','BasisFunction', 'none','KernelFunction','squaredexponential');

    %estimated sampling variance
    predlambdav = gprMdl.Sigma^2;
 
    %fitrgp returns length scale sigma_l. 1/(2*sigma_l^2) = zeta = 
    %alpha/(M-1)^2 is the length scale we use in the experiment.
    zeta = 1/(2*gprMdl.KernelInformation.KernelParameters(1)^2);
    %alphaval = (M-1)^2/(2*gprMdl.KernelInformation.KernelParameters(1)^2);
    
    %prior variance value
    sigmasq = gprMdl.KernelInformation.KernelParameters(2)^2;

    %% Predict the covariance matrix for all doses
    dosesfromdata = data(:,1);
    N = size(dosesfromdata,1); %size of the training set
    M = size(doses,1); %total number of doses

    %Calculate the covariance between test points (doses)
    Kxstarxstar = zeros(M,M);
    for i=1:M
        for j=1:M
            Kxstarxstar(i,j) = sigmasq*exp(-zeta*(doses(i)-doses(j))^2);
        end
    end
    %Calculate the covariance between training points (dosesfromdata)
    Kxx = zeros(N,N);
    for i=1:N
        for j=1:N
            Kxx(i,j) = sigmasq*exp(-zeta*(dosesfromdata(i)-dosesfromdata(j))^2);
        end
    end
    %Calculate the covariance between training and test points
    Kxxstar = zeros(M,N);
    for i=1:M
        for j=1:N
            Kxxstar(i,j) = sigmasq*exp(-zeta*(doses(i)-dosesfromdata(j))^2);
        end
    end
    %Add noise to the observed training points
    Kstarstarnoise = Kxx+predlambdav*eye(N);

    %Predict mean and covariance matrix
    predsigma = Kxstarxstar - Kxxstar*(Kstarstarnoise\Kxxstar'); 
    predbaselevel = 0;
    predmu = predbaselevel + (Kxxstar/Kstarstarnoise)*(data(:,2)-predbaselevel);

    %%% Test with Bayesian update function
    % predmuBay = predbaselevel*ones(M,1);
    % predsigmaBay = Kxstarxstar;
    % % for i = 1:size(data,1)
    % %     ind = find(doses == data(i,1));
    % %     [ predmuBay, predsigmaBay ] = BayesianUpdate(predmuBay, predsigmaBay, ind, data(i,2), predlambdav);
    % % end
    % for i = 1:size(data,1)
    %     ind(i) = find(doses == data(i,1));
    % end
    % [predmuBay, predsigmaBay] = BayesUpdateBlockNaive(predmuBay, predsigmaBay, ind', data(:,2), predlambdav*ones(50,1));
    % diffinmu = abs(predmu - predmuBay);
    % diffinsigma = abs(predsigma - predsigmaBay);
    % 
    % fprintf('max difference for Bayesian is %2.4e for predicted means, and %2.4e for predicted covariances', max(diffinmu(:)), max(diffinsigma(:)));
    % fprintf('\n')
    %%%
    % Predict function does not return the covariances, so I am calculating them 
    % myself above. The following portion is to test the above calculations against
    % matlab's predict function: predictmu and predmu should match
    % diag(predsigma) and predictstd^2-naturelambdav.
    % [predictmu, predictstd] = predict(gprMdl, doses);
    % 
    % diffinmu = abs(predictmu - predmu);
    % diffinsigma = abs(diag(predsigma) - (predictstd.^2 - predlambdav));
    % 
    % fprintf('max difference is %2e for predicted means, and %2e for predicted variance', max(diffinmu), max(diffinsigma));
    % fprintf('\n')

    %% Ensure symmetry
    predsigma = (predsigma+predsigma')/2;
    k = min(eig(predsigma));
    if k<0 %to correct the numerical error add small value to the diagonals
      predsigma = predsigma - 1.5*k*eye(size(predsigma));
    end

end