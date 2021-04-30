function [ parameters, rval ] = SetParametersFunc( parameterlist )
%SetParametersFunc
% PURPOSE: Creates a struct array which includes the problem and simulation
%   parameters
%
% INPUTS: 
% parameterlist: an string array, variable name followed by the value i.e. 
%        parameterlist = { 'c', 2, 'M', 5 }
%
% OUTPUTS: 
% parameters: a struct array with variables as fields
% rval: 1 if everything is fine, 0 if there is an issue with parameters

%%
    rval = 1;
    %% Assign values from the input array
    paralength = length(parameterlist);
    for i=1:(paralength/2)
        parameters.(parameterlist{2*i-1}) = parameterlist{2*i};
    end
    
    %% Check
    % check M
    if(~isfield(parameters, 'M'))
        warning('M needs to be specified')
        rval = 0;
        parameters = [];
        return
    end
    
    % Is there a pilot study to estimate the prior
    if(~isfield(parameters, 'runpilot'))
        parameters.runpilot = 0; % No pilot
    end
    if(isfield(parameters, 'runpilot') && parameters.runpilot == 1)
        parameters.lambda = 1; %will be calculated from the pilot
        parameters.sigma0 = eye(parameters.M); %will be calculated from the pilot
        parameters.mu0 = zeros(parameters.M,1); %will be calculated from the pilot
        parameters.lambdav = parameters.lambda*ones(1,parameters.M); %will be calculated from the pilot
        parameters.efns = parameters.lambdav./diag(parameters.sigma0)'; %will be calculated from the pilot
        if (~isfield(parameters, 'doses'))
            warning('runpilot is 1, therefore doses needs to be specified')
            rval = 0;
            parameters = [];
            return
        end
        if (~isfield(parameters, 'indicestosample'))
            warning('runpilot is 1, therefore indicestosample needs to be specified')
            rval = 0;
            parameters = [];
            return
        end
        if (~isfield(parameters, 'N'))
            warning('runpilot is 1, therefore N needs to be specified')
            rval = 0;
            parameters = [];
            return
        end
        if (~isfield(parameters, 'priortype'))
            warning('runpilot is 1, therefore priortype needs to be specified')
            rval = 0;
            parameters = [];
            return
        end
        if (~isfield(parameters, 'graphforprior'))
            warning('runpilot is 1, therefore graphforprior needs to be specified')
            rval = 0;
            parameters = [];
            return
        end
        if (~isfield(parameters, 'zalpha'))
            warning('runpilot is 1, therefore zalpha needs to be specified')
            rval = 0;
            parameters = [];
            return
        end
    end
    % is theta vector given?
    if(~isfield(parameters, 'thetav'))
        parameters.thetav = -1; %no theta is given, RPI from prior distribution
    end
    
    % are the inputs from beta coordinates
    if(isfield(parameters, 'rpibetamu0') && isfield(parameters, 'rpibetasigma0'))
        parameters.beta=1;
    else
        parameters.beta=0;
    end
    if parameters.beta ==1 && ~isfield(parameters, 'cvec')
        warning('cvec vector needs to be specified')
        rval = 0;
        parameters = [];
        return
    end
    
    % check lambdav
    if(~isfield(parameters, 'lambdav'))
        warning('lambdav needs to be specified')
        rval = 0;
        parameters = [];
        return
    end
    if(isscalar(parameters.lambdav))
        parameters.lambdav = parameters.lambdav*ones(1,parameters.M);
    end
    if(~isfield(parameters, 'naturelambdav'))
        parameters.naturelambdav = parameters.lambdav;
    end
    
    % check mu0, for theta coordinates
    if(~isfield(parameters, 'mu0'))
        if (isfield(parameters, 'betamu0'))
            parameters.mu0 = parameters.cvec*parameters.betamu0;
        else
            warning('mu0 needs to be specified')
            rval = 0;
            parameters = [];
            return    
        end
    end
    if(isscalar(parameters.mu0))
        parameters.mu0 = parameters.mu0*ones(parameters.M,1);
    end
    
   
    % Set covariance matrix using variance and correlation
    if(~isfield(parameters, 'sigma0') && ~isfield(parameters, 'efns'))
        warning('either sigma0 or efns needs to be specified')
        rval = 0;
        parameters = [];
        return
    elseif(~isfield(parameters, 'sigma0'))
        if(isscalar(parameters.efns)) 
            parameters.efns = parameters.efns*ones(1,parameters.M);
        end 
        if (isfield(parameters, 'betasigma0'))
            parameters.sigma0 = parameters.cvec*betasigma0*parameters.cvec.';
        elseif (isfield(parameters, 'rho'))
            std = sqrt(parameters.lambdav./parameters.efns);
            parameters.sigma0 = parameters.rho.*(std'*std);
        end
    elseif(~isfield(parameters, 'efns'))
        parameters.efns = parameters.lambdav./diag(parameters.sigma0)';
    end
        
    % check I
    if(~isfield(parameters, 'I'))
        warning('I needs to be specified')
        rval = 0;
        parameters = [];
        return
    end
    if(isscalar(parameters.I))
        parameters.I = parameters.I*ones(parameters.M,1);
    end 
    
    % check tie option
    if(~isfield(parameters, 'tieoption'))
        parameters.tieoption = 'random'; %by default
    end
    if(~isfield(parameters, 'pdetieoption'))
        parameters.pdetieoption = 'kgstar'; %by default
    end
    
    % check c
    if(~isfield(parameters, 'c'))
        warning('c needs to be specified')
        rval = 0;
        parameters = [];
        return
    end
    if(isscalar(parameters.c))
        parameters.c = parameters.c*ones(1,parameters.M);
    end 
    
    % check delta
    if(~isfield(parameters, 'delta'))
        warning('delta needs to be specified')
        rval = 0;
        parameters = [];
        return
    end
    if(parameters.delta == 1)
        parameters.disc = 1; %discount rate, little delta
    else
        parameters.disc = log(1/parameters.delta)/1; %one period takes one unit time
    end

    % Given distribution for RPI
    if (parameters.thetav == -1)
        if (parameters.beta == 0)    
            if(~isfield(parameters, 'rpimu0'))
                parameters.rpimu0 = parameters.mu0;
            end
            if(~isfield(parameters, 'rpisigma0'))
                parameters.rpisigma0 = parameters.sigma0;
            end
        end
    end

    rval = CheckParameters(parameters)*rval;
    if(rval==0)
        parameters = [];
    end
end

