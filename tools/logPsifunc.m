function [result] = logPsifunc(s)
%logPsifunc
% PURPOSE: Computes log(E[(Z-s)^+]) = log(normpdf(s)-s*(1-normcdf(s)))
% for a scalar positive s. Uses the asymptotic approximation for a large s.
% Mill's ratio is normcdf(-|s|)/normpdf(s), which is
% asymptotically approximated by |s|/(s^2+1).  This gives, 
% normpdf(s) - s*(1-normcdf(s)) = normpdf(s)/(s^2+1). 
%
% INPUTS: 
% s: numerical positive scalar, s value in E[(Z-s)^+]
%
% OUTPUTS: 
% result: numerical, log(E[(Z-s)^+])
%
%%
if  s > 10
	const = -.5*log(2*pi); % log of 1/sqrt(2pi).
	lognormalpdf = const - s^2/2;
    result = lognormalpdf - log(s^2+1);
else
    %normcdf(-s) is more stable than (1-normcdf(s)), remember that s is positive
    temp = max(normpdf(s) - s*normcdf(-s),0);
    result = log(temp);
end
end
