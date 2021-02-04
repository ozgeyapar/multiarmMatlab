function [ thetavalue ] = TrueMeanCreator( parameters, j)
%TrueMeanCreator
% PURPOSE: Generates the ground truth to be used in the simulation
% replication based on problem parameters
%
% INPUTS: 
% parameters: struct, problem parameters are included as fields (See 
%   ExampleProblemSetup.m for an example of how to generate this struct)
% j: number, simulation replication we are in
%
% OUTPUTS: 
% thetavalue: numerical vector, ground truth vector
%
% SUGGESTED WORKFLOW: Called in Func80altOC.m, Func80altTC.m, 
%   FuncAppCEVIandCompTime.m, FuncAppDPowerCurveSeq.m, FuncSec64OC.m, 
%   FuncSec64TC.m
%
%%
    % no crn and no rpi, theta given
    if(~isscalar(parameters.thetav))
        thetavalue = parameters.thetav;
    % no crn and rpi
    elseif(parameters.thetav == -1 && parameters.crn == 0)
        thetavalue = mvnrnd(parameters.rpimu0,parameters.rpisigma0);
    % crn and rpi
    elseif(parameters.thetav == -1 && parameters.crn == 1)
        if parameters.beta ==0
            A =  cholcov(parameters.rpisigma0)'; %A*A' = sigma0
            if size(A,2)<parameters.M %a quick fix if needed
                A = cholcov(parameters.rpisigma0*20)'/sqrt(20);
            end
            thetavalue = A*parameters.thetamat(:,j)+parameters.rpimu0;
        else
            A =  cholcov(parameters.rpibetasigma0)'; %A*A' = sigma0
            if size(A,2)<parameters.M
                A = cholcov(parameters.rpibetasigma0*20)'/sqrt(20);
            end
            betavalue = A*parameters.thetamat(:,j)+parameters.rpibetamu0;
            thetavalue = parameters.cvec*betavalue;
        end
    end
end

