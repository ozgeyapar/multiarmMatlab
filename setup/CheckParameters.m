function [ rval ] = CheckParameters( parameters )
%CheckParameters
% PURPOSE: Checks the validity of parameters that is created by 
% SetParametersFunc.m, throws an error and returns 0 if there are issues,
% called in SetParametersFunc.m
%
% INPUTS: 
% parameters: struct, problem parameters are included as fields (See 
%   ExampleProblemSetup.m for an example of how to generate this struct)
%
% OUTPUTS: 
% rval: 1 if everything is fine, 0 if there is an issue with parameters
%
% SUGGESTED WORKFLOW: See ExampleProblemSetup.m for an example of 
% generating the 'parameters' input

%%
rval =1;
if(~isscalar(parameters.M)||~isscalar(parameters.P))
    warning('M and P has to be scalars.');
    rval = 0;
end
if (parameters.M<=0||parameters.P<=0||all(parameters.c<0)||all(parameters.I<0))
    warning('M and P has to be positive and c and I has to be nonegative.');
    rval = 0;
end
if (parameters.delta<=0||parameters.delta>1)
    warning('Discount factor delta should be between (0,1]');
    rval = 0;
end
llambdav = length(parameters.lambdav);
lnlambdav = length(parameters.naturelambdav);
lmu0 = length(parameters.mu0);
[rsigma0,csigma0] = size(parameters.sigma0);
if size(parameters.thetav,1) > 1 %theta is given, no need to check
        naturemu0 = zeros(parameters.M,1);
        naturesigma0 = zeros(parameters.M);
        naturesigma0(eye(parameters.M)==1) = 1;
elseif  parameters.thetav ~= -1  %theta is given as rpi, no need to check
        naturemu0 = zeros(parameters.M,1);
        naturesigma0 = zeros(parameters.M);
        naturesigma0(eye(parameters.M)==1) = 1;
else
    if parameters.beta == 0
        naturemu0 = parameters.rpimu0;
        naturesigma0 = parameters.rpisigma0;
    else
        naturemu0 = parameters.rpibetamu0;
        naturesigma0 = parameters.rpibetasigma0;
    end
end
lrpimu0 = length(naturemu0);
[rrpisigma0,crpisigma0] = size(naturesigma0);
lI = length(parameters.I);
lc = length(parameters.c);
if (parameters.M~=lnlambdav||parameters.M~=llambdav||parameters.M~=lmu0||parameters.M~=rsigma0||...
        parameters.M~=csigma0||parameters.M~=lrpimu0||parameters.M~=rrpisigma0||...
        parameters.M~=crpisigma0||parameters.M~=lc||parameters.M~=lI)
    warning('Array dimensions do not match number of samples, M.');
    rval = 0;
end
if(sum(sum((parameters.sigma0~=parameters.sigma0')))>0)
    warning('sigma0 has to be symmetric.');
    rval = 0;
end

if(sum(sum((naturesigma0~=naturesigma0')))>0)
    warning('rpisigma0 has to be symmetric.');
    rval = 0;
end
[~,D] = eig(parameters.sigma0); %eigenvalues
if(~all(D(:) >= 0))
    warning('sigma0 has to be positive semidefinite.');
    rval = 0;
end
[~,rpiD] = eig(naturesigma0); %eigenvalues
if(~all(rpiD(:) >= 0))
    warning('rpisigma0 has to be positive semidefinite.');
    rval = 0;
end

end

