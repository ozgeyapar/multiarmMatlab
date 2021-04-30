function [predmu, predsigma, predlambdav, zeta, sigmasq] = GPRAltFit(data, doses, zeta, sigmasq, predlambdav)
%GPRAltFit
% PURPOSE: Implements the 'Alternative Fit' stage of Algorithm 2 of Chick, 
%   Gans, Yapar (2020). Matlab predict function does not return covariances  
%   so implemented my own version. 
%
% INPUTS: 
% data: matrix containing doses that were sampled from and responses 
%   obtained, throws an error if there is nan
% doses: the vector of points that needs to be estimated
% zeta: zeta estimated from Fit stage, see GPRFit.m
% sigmasq: sigma^2 estimated from Fit stage, see GPRFit.m
% predlambdav: lambda estimated from Fit stage, see GPRFit.m
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
    
    rng default
    datatable = array2table(data,'VariableNames',{'dose','response'});
    gprMdl = fitrgp(datatable,'response','BasisFunction', 'none', 'KernelFunction','squaredexponential',...
        'KernelParameters',[sqrt(1/(2*zeta)), sqrt(sigmasq)],'Sigma',sqrt(predlambdav),...
    'OptimizeHyperparameters','KernelScale','HyperparameterOptimizationOptions',...
    struct('AcquisitionFunctionName','expected-improvement-plus', 'ShowPlots', false, 'Verbose', 0));

    M = size(doses,1);
    dosesfromdata = data(:,1);
    N = size(dosesfromdata,1);

    predlambdav = gprMdl.Sigma^2;
    zeta = 1/(2*gprMdl.KernelInformation.KernelParameters(1)^2);
    sigmasq = gprMdl.KernelInformation.KernelParameters(2)^2;
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

    %predicted parameters
    predsigma = Kxstarxstar - Kxxstar*(Kstarstarnoise\Kxxstar'); 

    if isempty(gprMdl.Beta)
        predbaselevel = 0;
    else
        predbaselevel = gprMdl.Beta;
    end
    predmu = predbaselevel + (Kxxstar/Kstarstarnoise)*(data(:,2)-predbaselevel);

    predsigma = (predsigma+predsigma')/2;
    k = min(eig(predsigma));
    if k<0 %to correct the numerical error add small value to the diagonals
      predsigma = predsigma - 1.5*k*eye(size(predsigma));
    end
end