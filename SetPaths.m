% SetPaths.m: 
% PURPOSE: updates the matlab path variable so that pdestop, matlabKG and
% multiarmMatlab can all be accessed.

%%
[corrbasefol,name,ext] = fileparts(pwd);

pdecorr = [ corrbasefol '\multiarmMatlab\'];
addpath(genpath(pdecorr));

pdecode = [ corrbasefol '\pdestop\'];
addpath(genpath(pdecode));

kgcb = [ corrbasefol '\matlabKG\'];
addpath(genpath(kgcb));