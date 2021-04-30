function [ parameters ] = ProblemSetup80Arms( alphaval, pval)
%ProblemSetup80Arms 
% PURPOSE: Generates the parameters struct that contains the
% parameters for the 80 arm problem in Chick, Gans, Yapar (2020)
%
% INPUTS: 
% alphaval: for alpha = alphaval/(M-1)^2
% pval: for P = 10^pval

% OUTPUTS: 
% parameters: struct, holds the problem parameters

    %% Generate the problem
    M = 80;
    P = 10^pval;
    I = zeros(M,1); %zero fixed cost
    c = 1*ones(1,M);
    delta = 1; % undiscounted
    lambdav = 0.01*ones(1,M);
 
    %Define the modeler's prior on thetas
    mu0=zeros(M,1);
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
    
    %Define the nature's prior on theta
    rpimu0 = mu0;
    rpisigma0 = sigma0;
    
    %Simulation details and generate the problem parameters
    list = {'M',M,'efns',lambdav./diag(sigma0)', 'lambdav',lambdav,'mu0',mu0,'P',P,'I',I,'c',c,'delta',delta,'sigma0',sigma0,'rpisigma0',rpisigma0,'rpimu0',rpimu0};
    %list = {'M',M,'rho',rho,'efns',efns, 'lambdav',lambdav,'mu0',mu0,'P',P,'I',I,'c',c,'delta',delta,'Tfixed',Tfixed,'sigma0',sigma0,'thetav',thetav};
    [ parameters, ~ ] = SetParametersFunc( list );
    
end

