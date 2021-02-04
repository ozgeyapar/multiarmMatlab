function [ wval ] = CFCRNApproxBoundW( sval, scale, param )
%CFCRNApproxBoundW: Computes approximate size of lower/upper boundary for
% optimal stopping time for Bayesian bandit problem, as in Chick Gans Yapar 
% (2018) with multiple correlated arms, positive sampling costs and zero
% discount rate. 
%
% Computations done in standardize reverse time brownian motion
% coordinates. That is, in the (w,s) scale, where the point (w,s) refers to
% a prior distribution for an unknown mean which is normal(w, s).
%
% INPUTS:
%   sval: vector of values for evaluating the approximate boundary
%   scale: structure from pde reward code
%   param: param structure from pde reward code, together with augmentation
%   needed to account for correlation structure (see CorrNoSave*.m for
%   examples and the necessary calls to TransformtoLinearVersion.m).
% OUTPUTS:
%   wval: vector of bountary values corresponding to the inputs
%
% This function is related to equation (15) of Chick Gans Yapar (2018) and
% is approximate stopping boundary, with idea that the approx may be
% bad/overshot, in order to allow the online computations of the PDE
% solution with multiple correlated arms to run more cleanly.
%
% Code is 'as is' and no guarantees for correctness.
%
% (c) 2019 Stephen E. Chick, all rights reserved

    [wval] = CFApproxBoundW(sval); % compute boundary assuming no correlation
    shiftval = 0.0;     % and assume no shift needed, unless proven otherwise
    if isfield(param,'d') % safe coding: make sure a 'd' field is available
        dvec = param.d;     % get the vector of 'd' values, consistent with correlated KG and correlated PDE model
%        if length(dvec) > 5 % safe coding: make sure we have a dvec at least 3 long as expected with multiple potential 'best' arms
%            shiftval = mean(abs(dvec(2:(length(dvec)-1)))); % make a hopefully appropriate shift to increase size of boundary.
%            shiftval = min( shiftval, 1.8*max(wval)); % don't allow the shift to be too too big
%        else
        if length(dvec) > 2 % safe coding: make sure we have a dvec at least 3 long as expected with multiple potential 'best' arms
            shiftval = min( abs(dvec(2:(length(dvec)-1)))); % make a hopefully appropriate shift to increase size of boundary.
%            shiftval = min( shiftval, 1.8*max(wval)); % don't allow the shift to be too too big
        end
    end
    wval = wval + shiftval;
    
end
