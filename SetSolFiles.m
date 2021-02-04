% SetSolFiles.m:
% PURPOSE: A macro to generate the standardized PDE solution
%
% OUTPUTS: files of name CF<n>.mat for n=1,2,...,numfiles which contain
% solutions for PDE in standardized coordinates, also creates CF0.mat, 
% with summary information for files. See the documentation for 
% PDECreateSolnFiles for more details.

%% SET PATHS
SetPaths
%% CREATE SOLUTION FILES FOR PDE, RUN ONCE
%Run once to create solution files
%Offline learning, infinite horizon
onflag = false;
THoriz = -1;
PDELocalInit;
[rval] = PDECreateSolnFiles(PDEmatfilebase, onflag, THoriz);  
