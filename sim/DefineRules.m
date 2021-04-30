% DefineRules.m:
% PURPOSE: A macro to define funciton handles for allocation policies and 
% stopping times as function handles
% Common input for function handles for allocation policies: 
%       @(undissoln, dissoln, parameters, muin,sigmain, t, randtype, randprob)
% Common input for function handles for stopping times: 
%       @(undissoln, dissoln,parameters,  muin,sigmain,Tfixed,t)
%
% OUTPUTS: Generates a set of function handles in Workplace

%%
% Defining Allocation Policies
aPDEUpper = @(undissoln, dissoln, parameters, muin,sigmain, t, randtype, randprob)AllocationcPDEUpperOpt( undissoln, dissoln, parameters, muin, sigmain, randtype, randprob );
aPDEUpperNO = @(undissoln, dissoln, parameters, muin,sigmain, t, randtype, randprob) AllocationcPDEUpperNoOpt( undissoln, dissoln, parameters, muin, sigmain, randtype, randprob );
aPDELower = @(undissoln, dissoln, parameters, muin,sigmain, t, randtype, randprob) AllocationcPDELower( undissoln, dissoln, parameters, muin, sigmain, randtype, randprob );
aVar = @(undissoln, dissoln, parameters, muin,sigmain, t, randtype, randprob) AllocationVariance( parameters, muin, sigmain );
aKGStarLowerold = @(undissoln, dissoln,parameters,  muin,sigmain, t, randtype, randprob) AllocationcKGstar( parameters, muin, sigmain, randtype, randprob );
aKGStarLower = @(undissoln, dissoln,parameters,  muin,sigmain, t, randtype, randprob) AllocationcKGstarRatio( parameters, muin, sigmain, randtype, randprob );
aCKGold = @(undissoln, dissoln, parameters, muin,sigmain, t, randtype, randprob) AllocationcKG1(  parameters, muin, sigmain, randtype, randprob );
aCKG = @(undissoln, dissoln, parameters, muin,sigmain, t, randtype, randprob) AllocationcKG1Ratio(  parameters, muin, sigmain, randtype, randprob );
aESPb = @(undissoln, dissoln, parameters, muin,sigmain, t, randtype, randprob) AllocationIndESPb( parameters, muin, sigmain, randtype, randprob );
aESPB = @(undissoln, dissoln, parameters, muin,sigmain, t, randtype, randprob) AllocationIndESPcapB( undissoln, parameters, muin, sigmain, randtype, randprob );
aEqual = @(undissoln, dissoln, parameters, muin,sigmain, t, randtype, randprob) AllocationEqual( parameters, t );
aPDE = @(undissoln, dissoln, parameters, muin,sigmain, t, randtype, randprob) AllocationcPDE( parameters, muin, sigmain, randtype, randprob );
aRandom = @(undissoln, dissoln, parameters, muin,sigmain, t, randtype, randprob) AllocationRandom( parameters );

% Defining Stopping Times
sPDEUpper = @(undissoln, dissoln, parameters, muin,sigmain,Tfixed, t) StoppingcPDEUpperOpt( undissoln, dissoln, parameters,  muin, sigmain );
sPDEUpperNO = @(undissoln, dissoln, parameters, muin,sigmain,Tfixed,t) StoppingcPDEUpperNoOpt( undissoln, dissoln, parameters,  muin, sigmain );
sPDELower = @(undissoln, dissoln,parameters,  muin,sigmain,Tfixed,t) StoppingcPDELower( undissoln, dissoln, parameters,  muin, sigmain );
sfixed = @(undissoln, dissoln, parameters, muin,sigmain,Tfixed,t) StoppingFixed( Tfixed, t );
sKGStarLowerold = @(undissoln, dissoln, parameters, muin,sigmain,Tfixed,t) StoppingcKGstar( parameters, muin, sigmain );
sKGStarLower = @(undissoln, dissoln, parameters, muin,sigmain,Tfixed,t) StoppingcKGstarRatio( parameters, muin, sigmain );
sCKGold = @(undissoln, dissoln, parameters, muin,sigmain,Tfixed,t) StoppingcKG1( parameters, muin, sigmain );
sCKG = @(undissoln, dissoln, parameters, muin,sigmain,Tfixed,t) StoppingcKG1Ratio( parameters, muin, sigmain );
sESPb = @(undissoln, dissoln, parameters, muin,sigmain,Tfixed,t) StoppingIndESPb( parameters, muin, sigmain );
sPDE = @(undissoln, dissoln,parameters,  muin,sigmain,Tfixed,t) StoppingcPDE( parameters, muin, sigmain );
sPDEHeu = @(undissoln, dissoln,parameters,  muin,sigmain,Tfixed,t) StoppingcPDEHeu(undissoln, dissoln, parameters, muin, sigmain);
