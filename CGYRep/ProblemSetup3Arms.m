function [ parameters ] = ProblemSetup3Arms()
%ProblemSetup3Arms 
% PURPOSE: Generates the parameters struct that contains the
% parameters for the 3 arm problem in Appendix C2 of Chick, Gans, Yapar (2020)
%
% OUTPUTS: 
% parameters: struct, holds the problem parameters

    %% Generate the problem
    M = 3;        % number of alternatives
    c = ones(M,1);          % cost per sample
    P = 1;      % population size upon finishing
    I = zeros(M,1);
    lambdav = 1e6*ones(M,1);
    delta = 1; %no discounting
    mu0 = [0;0.5;0];
    efnsi0 = [5; 5; 5];
    rho0 = [1, 0.5, -0.5; 0.5, 1, 0.25; -0.5, 0.25, 1];
    sigma0 = lambdav./efnsi0; %vector of prior variances
    sigma0 =  rho0.*(sqrt(sigma0)*sqrt(sigma0)'); %covariance matrix
    
    %Simulation details and generate the problem parameters
    list = {'M',M,'efns',efnsi0, 'lambdav',lambdav,'mu0',mu0,'P',P,'I',I,'c',c,'delta',delta,'sigma0',sigma0};
    [ parameters, ~ ] = SetParametersFunc( list );
    
end

