function [ parameters ] = ProblemSetupTriangular( M, stepsize)
%ProblemSetupTriangular 
% PURPOSE: Generates the parameters struct that contains the
% parameters for the triangular problem in Chick, Gans, Yapar (2020)
% for given difference between best and second best
%
% INPUTS: 
% M: Number of arms in the problem
% stepsize: The difference between the mean of best arm and the second best
%   arm

% OUTPUTS: 
% parameters: struct, holds the problem parameters

    %% Generate the problem
    % triangular truth curve
    thetav = zeros(1,M);
    for i = 1:(M-1)/2
        thetav((M+1)/2+i) = thetav((M+1)/2)-i*stepsize;
        thetav((M+1)/2-i) = thetav((M+1)/2)-i*stepsize;
    end
    thetav = thetav'*2000;
    naturelambda = 4.5*(2000^2);
    naturelambdav = naturelambda*ones(M,1);
    lambda = 4.5*(2000^2);
    lambdav = lambda*ones(M,1);
    P = 2000000*0.1; 
    I = zeros(M,1); % zero fixed cost
    c = 8500*ones(M,1);
    delta=1; % undiscounted

    %Define the modeler's prior on thetas
    alphaval = 16;
    efns = 0.1;
    beta0 = lambda/efns;
    %This method creates a non-positive semidefinite matrix for M.
    %Therefore, I use PowExpCov from matlabKG code. Both method give the same
    %results for M=20, but PowExpCov is more accurate as M gets larger.
    %     alpha0 = alphaval/(M-1)^2;
    %     for i=1:M
    %         for j=1:M
    %             sigma0(i,j) = beta0*exp(-alpha0*(i-j)^2);
    %         end
    %     end
    [sigma0,~] = PowExpCov(beta0,(M-1)/sqrt(alphaval),2,M,1);
    mu0 = zeros(M,1) + sqrt(sigma0((M+1)/2,(M+1)/2));
       
    %Simulation details and generate the problem parameters
    list = {'M',M,'efns',lambdav./diag(sigma0)', 'lambdav',lambdav,'mu0',mu0,'P',P,'I',I,'c',c,'delta',delta,'sigma0',sigma0,'thetav',thetav, 'naturelambdav',naturelambdav};
    [ parameters, ~ ] = SetParametersFunc( list );
    
end

