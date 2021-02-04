function [ ybar ] = getybar( muittau, muit, lambdai, tau, sigmait )
%getybar.m 
% PURPOSE: Calculates mean of samples (ybar) from the posterior of i at
% t+tau
% INPUTS: muittau = mean for i at time t+tau
%       muit = mean for i at time t
%       lambdai = sample variance of alternative i
%       tau = number of samples taken
%       sigmait = variance over unknown mean for i at time t
% OUTPUTS: ybar = mean of tau samples taken

diff = muittau - muit;
varovertau = lambdai/tau;
varterm = varovertau/sigmait;

ybar = diff*varterm + muittau;

end

