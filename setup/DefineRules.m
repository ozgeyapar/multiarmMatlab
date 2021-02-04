% DefineRules.m:
% PURPOSE: A macro to define funciton handles for allocation policies and 
% stopping times as function handles
% Common input for function handles for allocation policies: 
%       @(undissoln, dissoln, parameters, muin,sigmain, t, p)
% Common input for function handles for stopping times: 
%       @(undissoln, dissoln, parameters, muin,sigmain, t)
%
% OUTPUTS: Generates a set of function handles in Workplace

%%
% Defining Allocation Policies
aPDEUpper = @(undissoln, dissoln, parameters, muin,sigmain, t, p) AllocationcPDEUpperOpt( undissoln, dissoln, parameters, muin, sigmain );
aPDEUpperNO = @(undissoln, dissoln, parameters, muin,sigmain, t, p) AllocationcPDEUpperNoOpt( undissoln, dissoln, parameters, muin, sigmain );
aPDELower = @(undissoln, dissoln, parameters, muin,sigmain, t, p) AllocationcPDELower( undissoln, dissoln, parameters, muin, sigmain );
aVar = @(undissoln, dissoln, parameters, muin,sigmain, t, p) AllocationVariance( parameters, muin, sigmain );
aKGStarLowerold = @(undissoln, dissoln,parameters,  muin,sigmain, t, p) AllocationcKGstar( parameters, muin, sigmain );
aKGStarLower = @(undissoln, dissoln,parameters,  muin,sigmain, t, p) AllocationcKGstarRatio( parameters, muin, sigmain );
aCKGold = @(undissoln, dissoln, parameters, muin,sigmain, t, p) AllocationcKG1(  parameters, muin, sigmain );
aCKG = @(undissoln, dissoln, parameters, muin,sigmain, t, p) AllocationcKG1Ratio(  parameters, muin, sigmain );
aESPb = @(undissoln, dissoln, parameters, muin,sigmain, t, p) AllocationIndESPb( parameters, muin, sigmain );
aESPB = @(undissoln, dissoln, parameters, muin,sigmain, t, p) AllocationIndESPcapB( undissoln, parameters, muin, sigmain );
aEqual = @(undissoln, dissoln, parameters, muin,sigmain, t, p) AllocationEqual( parameters, t );
aPDE = @(undissoln, dissoln, parameters, muin,sigmain, t, p) AllocationcPDE( parameters, muin, sigmain );
aPDELowerURand = @(undissoln, dissoln, parameters, muin, sigmain, t, p) AllocationcPDELowerUnif( undissoln, dissoln, parameters, muin, sigmain, p);
TTVSLower = @(undissoln, dissoln, parameters, muin, sigmain, t, p) AllocationcPDELowerTTVS( undissoln, dissoln, parameters, muin, sigmain, p);

% Defining Stopping Times
sPDEUpper = @(undissoln, dissoln, parameters, muin,sigmain,t) StoppingcPDEUpperOpt( undissoln, dissoln, parameters,  muin, sigmain );
sPDEUpperNO = @(undissoln, dissoln, parameters, muin,sigmain,t) StoppingcPDEUpperNoOpt( undissoln, dissoln, parameters,  muin, sigmain );
sPDELower = @(undissoln, dissoln,parameters,  muin,sigmain,t) StoppingcPDELower( undissoln, dissoln, parameters,  muin, sigmain );
sfixed = @(undissoln, dissoln, parameters, muin,sigmain,t) StoppingFixed( parameters, t );
sKGStarLowerold = @(undissoln, dissoln, parameters, muin,sigmain,t) StoppingcKGstar( parameters, muin, sigmain );
sKGStarLower = @(undissoln, dissoln, parameters, muin,sigmain,t) StoppingcKGstarRatio( parameters, muin, sigmain );
sCKGold = @(undissoln, dissoln, parameters, muin,sigmain,t) StoppingcKG1( parameters, muin, sigmain );
sCKG = @(undissoln, dissoln, parameters, muin,sigmain,t) StoppingcKG1Ratio( parameters, muin, sigmain );
sESPb = @(undissoln, dissoln, parameters, muin,sigmain,t) StoppingIndESPb( parameters, muin, sigmain );
sPDE = @(undissoln, dissoln,parameters,  muin,sigmain,t) StoppingcPDE( parameters, muin, sigmain );
sPDEHeu = @(undissoln, dissoln,parameters,  muin,sigmain,t) StoppingcPDEHeu(undissoln, dissoln, parameters, muin, sigmain, t);
