% SetRandomVars.m:
% PURPOSE: A macro to generate the random variables to used in the
% simulation replications for correlated multiarm paper.
%
% OUTPUTS: Saves 20 .mat files to a folder named 'variables', the final
% 'variables' folder is around 18GB.

%% SET PATHS
SetPaths
%% MONTE CARLO SIM PREPARE, RUN ONCE
% Folder to save the variables needed
variablesfolder = [ corrbasefol '\multiarmMatlab\'];
% USED FOR SIM REPLICATIONS 1-1000
rng(42,'twister');
observ = normrnd(0,1,[100,5*10^3,10^3]); %observations for 20 alternatives and 5000 periods and 10^3 replications 
rng(44,'twister');
thetav = normrnd(0,1,100,10^4); %theta values for 20 alternatives and 10^4 replications
rng(46,'twister');
doserespv = normrnd(0,1,[10,10,10^3]); %dose response values for 10 samples each from 10 doses and 10^3 replications
rng(47,'twister');
seed = randi(2^32,1,10^3); %seeds to be used in each replication
foldertosave = strcat(variablesfolder,'variables/');
mkdir(foldertosave);
save('variables/observ','observ','-v7.3');
save('variables/thetav','thetav');
save('variables/doserespv','doserespv');
save('variables/seed','seed');

% USED FOR SIM REPLICATIONS 1001-2000
rng(13234,'twister');
observ = normrnd(0,1,[100,5*10^3,10^3]); %observations for 20 alternatives and 5000 periods and 10^3 replications 
rng(9822340,'twister');
thetav = normrnd(0,1,100,10^4); %theta values for 20 alternatives and 10^4 replications
rng(214553,'twister');
doserespv = normrnd(0,1,[10,10,10^3]); %dose response values for 10 samples each from 10 doses and 10^3 replications
rng(19343,'twister');
seed = randi(2^32,1,10^3); %seeds to be used in each replication
foldertosave = strcat(variablesfolder,'variables/btw1001and2000');
mkdir(foldertosave);
save(strcat(foldertosave,'/observ'),'observ','-v7.3');
save(strcat(foldertosave,'/thetav'),'thetav');
save(strcat(foldertosave,'/doserespv'),'doserespv');
save(strcat(foldertosave,'/seed'),'seed');

% USED FOR SIM REPLICATIONS 2001-3000
rng(3213210,'twister');
observ = normrnd(0,1,[100,5*10^3,10^3]); %observations for 20 alternatives and 5000 periods and 10^3 replications 
rng(54645,'twister');
thetav = normrnd(0,1,100,10^4); %theta values for 20 alternatives and 10^4 replications
rng(5464,'twister');
doserespv = normrnd(0,1,[10,10,10^3]); %dose response values for 10 samples each from 10 doses and 10^3 replications
rng(51650,'twister');
seed = randi(2^32,1,10^3); %seeds to be used in each replication
foldertosave = strcat(variablesfolder,'variables/btw2001and3000');
mkdir(foldertosave);
save(strcat(foldertosave,'/observ'),'observ','-v7.3');
save(strcat(foldertosave,'/thetav'),'thetav');
save(strcat(foldertosave,'/doserespv'),'doserespv');
save(strcat(foldertosave,'/seed'),'seed');

% USED FOR SIM REPLICATIONS 3001-4000
rng(235423,'twister');
observ = normrnd(0,1,[100,5*10^3,10^3]); %observations for 20 alternatives and 5000 periods and 10^3 replications 
rng(433,'twister');
thetav = normrnd(0,1,100,10^4); %theta values for 20 alternatives and 10^4 replications
rng(545,'twister');
doserespv = normrnd(0,1,[10,10,10^3]); %dose response values for 10 samples each from 10 doses and 10^3 replications
rng(9951,'twister');
seed = randi(2^32,1,10^3); %seeds to be used in each replication
foldertosave = strcat(variablesfolder,'variables/btw3001and4000');
mkdir(foldertosave);
save(strcat(foldertosave,'/observ'),'observ','-v7.3');
save(strcat(foldertosave,'/thetav'),'thetav');
save(strcat(foldertosave,'/doserespv'),'doserespv');
save(strcat(foldertosave,'/seed'),'seed');

% USED FOR SIM REPLICATIONS 4001-5000
rng(4565,'twister');
observ = normrnd(0,1,[100,5*10^3,10^3]); %observations for 20 alternatives and 5000 periods and 10^3 replications 
rng(8979,'twister');
thetav = normrnd(0,1,100,10^4); %theta values for 20 alternatives and 10^4 replications
rng(40216,'twister');
doserespv = normrnd(0,1,[10,10,10^3]); %dose response values for 10 samples each from 10 doses and 10^3 replications
rng(6465156,'twister');
seed = randi(2^32,1,10^3); %seeds to be used in each replication
foldertosave = strcat(variablesfolder,'variables/btw4001and5000');
mkdir(foldertosave);
save(strcat(foldertosave,'/observ'),'observ','-v7.3');
save(strcat(foldertosave,'/thetav'),'thetav');
save(strcat(foldertosave,'/doserespv'),'doserespv');
save(strcat(foldertosave,'/seed'),'seed');