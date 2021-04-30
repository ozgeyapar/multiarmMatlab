function [ thetavalue ] = TrueThetaCreator( parameters, stdtheta, crn)
%TrueThetaCreator
% PURPOSE: Generates the ground truth to be used in the simulation
% replication based on problem parameters
%
% INPUTS: 
% parameters: struct, problem parameters are included as fields (See 
%   ExampleProblemSetup.m for an example of how to generate this struct)
% stdtheta: a matrix of standardized normals, used for observation noise if crn is asked
% crn: 1 if crn is asked
%
% OUTPUTS: 
% thetavalue: numerical vector, ground truth vector
%
%%
    % no crn and no rpi, theta given
    if(~isscalar(parameters.thetav))
        thetavalue = parameters.thetav;
    % no crn and rpi
    elseif(parameters.thetav == -1 && crn == 0)
        thetavalue = mvnrnd(parameters.rpimu0,parameters.rpisigma0);
    % crn and rpi
    elseif(parameters.thetav == -1 && crn == 1)
        if parameters.beta == 0
            A =  cholcov(parameters.rpisigma0)'; %A*A' = sigma0
            if size(A,2)<parameters.M %a quick fix if needed
                A = cholcov(parameters.rpisigma0*20)'/sqrt(20);
            end
            thetavalue = A*stdtheta+parameters.rpimu0;
        else
            A =  cholcov(parameters.rpibetasigma0)'; %A*A' = sigma0
            if size(A,2)<parameters.M
                A = cholcov(parameters.rpibetasigma0*20)'/sqrt(20);
            end
            betavalue = A*stdtheta+parameters.rpibetamu0;
            thetavalue = parameters.cvec*betavalue;
        end
    end
    if size(thetavalue, 2) ~= 1 %make sure that thetavalue is a column array
        thetavalue = thetavalue';
    end
end

