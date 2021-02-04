function [ stop ] = StoppingcPDEHeu( undissoln, dissoln, parameters, muin, sigmain, t)
%StoppingcPDEHeu
% PURPOSE: Implements the cPDE stopping time defined in Chick, Gans,
% Yapar (2020) using a heuristic that is faster. Returns 1 for stopping and
% 0 for continue.
%
% INPUTS: 
% undissol: variable which contains the standardized solution
%   for undiscounted problem. SetSolFiles.m generates the standardized
%   solution and PDELoadSolnFiles is used to load it, see 
%   ExamplePolicies.m for an example.
% dissoln: variable which contains the standardized solution
%   for discounted problem. SetSolFiles.m generates the standardized
%   solution and PDELoadSolnFiles is used to load it.
% parameters: struct, problem parameters are included as fields (See 
%   ExampleProblemSetup.m for an example of how to generate this struct)
% muin: numerical vector that contains the prior mean vector
% sigmain: numerical matrix that contains the prior covariance matrix
% t: numerical scalar, used to save how many times cPDE is called 
%
% OUTPUTS: 
% stop: 1 for stopping and 0 for continue.
%
% SUGGESTED WORKFLOW: See ExampleProblemSetup.m for an example of 
% generating the 'parameters' input, and ExampleCallingcPDEs.m for an 
% example of how to call this function

%%
    cPDEcount = 0;
    evi = zeros(1,parameters.M); 
    %fileID = fopen(strcat('SimResultsGrid/cPDEUsage-',parameters.expname,'-rep-',num2str(parameters.initialrepnum + parameters.repnum),'.txt'), 'a');
    if parameters.delta == 1
        for j = 1:parameters.M
            evilower = cPDELowerUndis(undissoln, parameters, muin, sigmain, j);
            if evilower > 0
                stop = 0;
                %fprintf(fileID, '%d \n', cPDEcount);
                %fclose(fileID);
                return;
            end
        end
        for j = 1:parameters.M
            eviupper = cPDEUpperUndisNoOpt(undissoln, parameters, muin, sigmain, j);
                if eviupper <= 0
                    evi(j) = 0;
                else
                    evi(j)= cPDEUndis(parameters, muin, sigmain, j, 300, 45);
                    cPDEcount = cPDEcount + 1;
                    if evi(j) > 0
                        stop = 0;
                        %fprintf(fileID, '%d \n', cPDEcount);
                        %fclose(fileID);
                        return;
                    end
                end
        end   
    elseif parameters.delta < 1 && parameters.delta > 0
        warning('this stopping rule is not defined for discounted problems');
        return;
    else
        warning('cannot calculate undiscounted upper bound: discounting rate delta has to be between 0 and 1');
        return;
    end
    stop = all(evi<=0);
    %fprintf(fileID, '%d \n', cPDEcount);
    %fclose(fileID);
end

