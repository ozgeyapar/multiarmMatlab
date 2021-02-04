function [result] = Psifunc(s)
%Psifunc
% PURPOSE: Calculates  E[(Z-s)^+] = normpdf(s) - s*(1-normcdf(s)) 
% for a scalar positive s.
% Uses the asymptotic approximation for a large s.
% Mill's ratio is normcdf(-|s|)/normpdf(s), which is
% asymptotically approximated by |s|/(s^2+1).  This gives, 
% normpdf(s) - s*(1-normcdf(s)) = normpdf(s)/(s^2+1).
%
% INPUTS: 
% s: numerical positive scalar, s value in E[(Z-s)^+]
%
% OUTPUTS: 
% result: numerical, E[(Z-s)^+]
%
%%
if s > 10
    result = normpdf(s)/(s^2+1);
else
    %normcdf(-s) is more stable than (1-normcdf(s)), remember that s is positive
    result = normpdf(s) - s*normcdf(-s);
end
result = max(result,0);
end