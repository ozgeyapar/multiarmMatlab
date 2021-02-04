function [ parameters, rval ] = SetParametersFunc( parameterlist )
%SetParametersFunc
% PURPOSE: Creates a struct array which includes the problem and simulation
%   parameters
%
% INPUTS: 
% parameterlist: an string array, variable name followed by the value i.e. 
%        parameterlist = { 'c', 2, 'M', 5 }(See 
%   ExampleProblemSetup.m for an example of how to generate this struct)
%
% OUTPUTS: 
% parameters: a struct array with variables as fields
% rval: 1 if everything is fine, 0 if there is an issue with parameters
%
% SUGGESTED WORKFLOW: See ExampleProblemSetup.m for an example of 
% generating the 'parameterlist' input

%%
rval =1;
%Use default, if no input is passed
if (nargin<1)
    warning('Default problem instance with two alterantives is used');
    %Default problem instance, number of alternatives is 2
    parameters.M=2; %number of alternatives
    parameters.lambdav=[10^(5),10^(5)]; %vector of known sample variances
    parameters.mu0=[0;0]; %mean of prior distribution, column matrix
    parameters.sigma0=[ 10^(5) , 10^(4);
                        10^(4), 10^(5)  ]; %variance-covariance matrix of prior distribution, need to be positive definite                
    parameters.P=1; %number of patients to be affected by the decision
    parameters.I=[0;0]; %fixed cost for implementing the decision
    parameters.c=[1,1]; %sampling costs
    parameters.delta = 1; %discount factor per unit time, capital delta, 1 if undiscounted and <1 if discounted
    parameters.efns = [5,5]; %effective number of samples 
    parameters.disc = 1; %discount rate, little delta
    parameters.crn = 1; %common random numbers is used by default
    parameters.thetav = -1; %no theta is given, RPI from given distribution
    parameters.rpimu0 =  parameters.mu0; %Mean of the distribution to be used to create rpi
    parameters.rpisigma0 =  parameters.sigma0; %Covariance of the distribution to be used to create rpi
    parameters.Tfixed = 100;
    parameters.tieoption = 'random'; %use random tie breaking for all
    parameters.pdetieoption = 'random';
    parameters.randomps = 0 ;%do not random sample at every perfect square used if 1
    parameters.beta=0;
    parameters.summary = 'Default Problem';
    
%input is passed
else
    %Start with empty summary
    parameters.summary ='';
    % Assign values from the input array
    paralength = length(parameterlist);
    for i=1:(paralength/2)
        parameters.(parameterlist{2*i-1}) = parameterlist{2*i};
    end
    
    %Random sample at every perfect square used if 1, default is 0
    if(~isfield(parameters, 'randomps'))
        parameters.randomps = 0 ;
    end
    if parameters.randomps == 1
        parameters.summary = strcat(parameters.summary, ', randomly at perfect sq');
    end
    %common random numbers
    if(~isfield(parameters, 'crn') || parameters.crn ~= 0)
        parameters.crn = 1; %use CRN by default
    end
    if (parameters.crn == 0)
        warning('no crn');
        parameters.summary = strcat(parameters.summary, ', no crn');
    end
    %is theta or ksi, used for slippage configuration, given
    if(~isfield(parameters, 'thetav') && ~isfield(parameters, 'ksi'))
        %warning('RPI');
        parameters.thetav = -1; %no theta is given, RPI from prior distribution
    elseif(isfield(parameters, 'ksi'))
        if(~isfield(parameters, 'ksibest'))
            %warning('1st alternative is best (ksi)');
            parameters.ksibest = 1;
        end
        parameters.thetav = -parameters.ksi * ones(1,parameters.M);
        parameters.thetav(parameters.ksibest) = 0;
    end
    % are the inputs from beta coordinates
    if(isfield(parameters, 'rpibetamu0') && isfield(parameters, 'rpibetasigma0'))
        %warning('RPI from beta coordinates');
        parameters.beta=1;
    else
        parameters.beta=0;
    end
    if parameters.beta ==1 && ~isfield(parameters, 'cvec')
        %warning('No c vector is given');
        parameters.cvec = [1,0,0,0;1,1,0,0;1,0,1,0;1,1,1,1];
    end
    % check M
    if(~isfield(parameters, 'M'))
        warning('default M value, 4, is used.');
        parameters.M = 4;
    end
    % check lambdav
    if(~isfield(parameters, 'lambdav'))
        warning('default lambdav value, 10^6, is used.');
        parameters.lambdav = 10^6*ones(1,parameters.M);
    elseif(isscalar(parameters.lambdav))
        parameters.lambdav = parameters.lambdav*ones(1,parameters.M);
    end
    if(isfield(parameters, 'nu'))
        parameters.lambdav = (10^4)/(1+parameters.nu)* ones(1,parameters.M);
        parameters.lambdav(1) = (10^4*parameters.nu)/(1+parameters.nu);
    end
    if(~isfield(parameters, 'naturelambdav'))
        parameters.naturelambdav = parameters.lambdav;
    elseif(isscalar(parameters.lambdav))
        warning('naturelambdav is given, possibly different than lambdav.');
        parameters.summary = strcat(parameters.summary, ', naturelambdav is given');
    end
    % check mu0, for theta coordinates
    if(~isfield(parameters, 'mu0'))
        if (isfield(parameters, 'betamu0'))
            parameters.mu0 = parameters.cvec*parameters.betamu0;
        else
            warning('default mu0 value, 0, is used.');
            parameters.mu0 = zeros(parameters.M,1);
        end
    end
    if(isscalar(parameters.mu0))
        parameters.mu0 = parameters.mu0*ones(parameters.M,1);
    end
    % check efns
    if(~isfield(parameters, 'efns'))
        warning('default efns value, 20, is used.');
        parameters.efns = 20*ones(1,parameters.M);
    elseif(isscalar(parameters.efns)) 
        parameters.efns = parameters.efns*ones(1,parameters.M);
    end    
    % check P
    if(~isfield(parameters, 'P'))
        warning('default P value, 1, is used.');
        parameters.P = 1;
    end   
    % check I
    if(~isfield(parameters, 'I'))
        warning('default I value, 0, is used.');
        parameters.I = zeros(parameters.M,1);
    elseif(isscalar(parameters.I))
        parameters.I = parameters.I*ones(parameters.M,1);
    end 
    % Tfixed, used in fixed stopping rule
    if(~isfield(parameters, 'Tfixed'))
        %warning('default Tfixed value, 100, is used.');
        parameters.Tfixed = 100;
    end
    % check tie option
    if(~isfield(parameters, 'tieoption'))
        parameters.tieoption = 'random'; %by default
    end
    if(~isfield(parameters, 'pdetieoption'))
        parameters.pdetieoption = 'random'; %by default
    else
        parameters.summary = strcat(parameters.summary, ', pdetieoption =', parameters.pdetieoption);
    end
    % check c
    if(~isfield(parameters, 'c'))
        warning('default c value, 1, is used.');
        parameters.c = ones(1,parameters.M);
    elseif(isscalar(parameters.c))
        parameters.c = parameters.c*ones(1,parameters.M);
    end 
    
    % check delta
    if(~isfield(parameters, 'delta'))
        warning('default delta value, 1, is used.');
        parameters.delta = 1;
    end 
    if(parameters.delta == 1)
        parameters.disc = 1; %discount rate, little delta
    else
        parameters.disc = log(1/parameters.delta)/1; %one period takes one unit time
    end

    % Set covariance matrix using variance and correlation
    if(~isfield(parameters, 'sigma0'))
        if (isfield(parameters, 'betasigma0'))
            parameters.sigma0 = parameters.cvec*betasigma0*parameters.cvec.';
        else
            if (~isfield(parameters, 'rho'))
            warning('default rho value, independent, is used.');
            parameters.rho = zeros(parameters.M);
            parameters.rho(eye(parameters.M)==1) = 1;
            parameters.summary = strcat(parameters.summary, ', independent');
            end
        std = sqrt(parameters.lambdav./parameters.efns);
        parameters.sigma0 = parameters.rho.*(std'*std);
        end
    end
    %Given distribution for RPI
    if (parameters.thetav == -1)
        if (parameters.beta==0)    
            if(~isfield(parameters, 'rpimu0'))
                warning('RPI mu0 from prior distribution');
                parameters.rpimu0 = parameters.mu0;
                parameters.summary = strcat(parameters.summary, ', mu0 is consistent');
            end
            if(~isfield(parameters, 'rpisigma0'))
                warning('RPI sigma0 from prior distribution');
                parameters.rpisigma0 = parameters.sigma0;
                parameters.summary = strcat(parameters.summary, ', sigma0 is consistent');
            end
        end
    end
end
%For CRN and RPI, load pregenerated values
if ~isfield(parameters, 'matlocfile')
    parameters.matlocfile = 'variables';
end
if (parameters.crn == 1)
    if parameters.M <= 100   
        o = load(strcat(parameters.matlocfile, '/observ'));
        parameters.observ = o.observ(1:parameters.M,:,:);
    else
        warning('obvervation matrix is not big enough');
        rval = 0;
    end
    if (parameters.thetav == -1)
        if parameters.M <= 100   
            t = load(strcat(parameters.matlocfile, '/thetav'));
            parameters.thetamat = t.thetav(1:parameters.M,:);
        else
            warning('theta matrix is not big enough');
            rval = 0;
        end
    end
end
if (isfield(parameters, 'sampleeach') && parameters.sampleeach == 1)
    t = load(strcat(parameters.matlocfile, '/doserespv'));
    warning('prior will be estimated from the pilot for each replication, loading doserespv ');
    parameters.doserespv = t.doserespv;
    %t = load(strcat(parameters.matlocfile, '/doserespv2'));
    %parameters.doserespv2 = t.doserespv2;
    %mu0 and sigma0 will be assigned during the simulation
    parameters.mu0 = zeros(1,parameters.M);
    parameters.sigma0 = eye(parameters.M);
    parameters.lambdav = 1*ones(parameters.M,1);
    parameters.summary = strcat(parameters.summary, ', new prior at each iteration');
end
o = load(strcat(parameters.matlocfile, '/seed'));
parameters.seed = o.seed;
rval = CheckParameters(parameters)*rval;
if(rval==0)
    parameters = [];
end
end

