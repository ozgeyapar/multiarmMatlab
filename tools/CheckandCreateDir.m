function CheckandCreateDir( foldertosave )
%CheckandCreateDir 
% PURPOSE: Checks if the inputted directory exists, if it does not, it creates
% the directory
% INPUTS: foldertosave: directory to check
%
    if ~exist(foldertosave, 'dir')
       mkdir(foldertosave)
    end
end

