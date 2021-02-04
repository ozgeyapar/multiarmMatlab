% SimforAppD1.m:
% PURPOSE: A macro with the code to generate the simulation results to 
% generate figure Appendix D1 of correlated multiarms paper. 
% The simulations are for a triangular shaped ground truth curve.
% If the user have access to multiple CPUs, different simulation 
% replications can be run on different CPUs instead of using this macro
% which runs all replications sequentially on a single CPU.
%
% OUTPUTS: Generates 42000 .mat files (6 policies, 7 problem 
% setups, 1000 simulatin replicaitons). Each .mat file holds information 
% about the results of the replication (e.g. ground truth mean, which arms 
% were sampled at each period, at which period sampling stopped etc.)
%
% WORKFLOW: Called in ReplicateFiguresRev1.m after defining appdfolder 

%%
NUMOFREPS = 1000; %number of replications for the simulation, 1000 in the paper

[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDEUpperNO:sfixed', [0], 'powercurve-21alt-03-Upper-fixed', 1, 0.3, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDEUpperNO:sfixed', [0], 'powercurve-21alt-05-Upper-fixed', 1, 0.5, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDEUpperNO:sfixed', [0], 'powercurve-21alt-07-Upper-fixed', 1, 0.7, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDEUpperNO:sfixed', [0], 'powercurve-21alt-09-Upper-fixed', 1, 0.9, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDEUpperNO:sfixed', [0], 'powercurve-21alt-11-Upper-fixed', 1, 1.1, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDEUpperNO:sfixed', [0], 'powercurve-21alt-13-Upper-fixed', 1, 1.3, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDEUpperNO:sfixed', [0], 'powercurve-21alt-15-Upper-fixed', 1, 1.5, 21, appdfolder);

[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aKGStarLower:sfixed', [0], 'powercurve-21alt-03-cKGstar-fixed', 1, 0.3, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aKGStarLower:sfixed', [0], 'powercurve-21alt-05-cKGstar-fixed', 1, 0.5, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aKGStarLower:sfixed', [0], 'powercurve-21alt-07-cKGstar-fixed', 1, 0.7, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aKGStarLower:sfixed', [0], 'powercurve-21alt-09-cKGstar-fixed', 1, 0.9, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aKGStarLower:sfixed', [0], 'powercurve-21alt-11-cKGstar-fixed', 1, 1.1, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aKGStarLower:sfixed', [0], 'powercurve-21alt-13-cKGstar-fixed', 1, 1.3, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aKGStarLower:sfixed', [0], 'powercurve-21alt-15-cKGstar-fixed', 1, 1.5, 21, appdfolder);

[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDELower:sfixed', [0], 'powercurve-21alt-03-Lower-fixed', 1, 0.3, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDELower:sfixed', [0], 'powercurve-21alt-05-Lower-fixed', 1, 0.5, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDELower:sfixed', [0], 'powercurve-21alt-07-Lower-fixed', 1, 0.7, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDELower:sfixed', [0], 'powercurve-21alt-09-Lower-fixed', 1, 0.9, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDELower:sfixed', [0], 'powercurve-21alt-11-Lower-fixed', 1, 1.1, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDELower:sfixed', [0], 'powercurve-21alt-13-Lower-fixed', 1, 1.3, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDELower:sfixed', [0], 'powercurve-21alt-15-Lower-fixed', 1, 1.5, 21, appdfolder);

[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDEUpperNO:sPDEUpperNO', [0], 'powercurve-21alt-03-Upper', 1, 0.3, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDEUpperNO:sPDEUpperNO', [0], 'powercurve-21alt-05-Upper', 1, 0.5, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDEUpperNO:sPDEUpperNO', [0], 'powercurve-21alt-07-Upper', 1, 0.7, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDEUpperNO:sPDEUpperNO', [0], 'powercurve-21alt-09-Upper', 1, 0.9, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDEUpperNO:sPDEUpperNO', [0], 'powercurve-21alt-11-Upper', 1, 1.1, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDEUpperNO:sPDEUpperNO', [0], 'powercurve-21alt-13-Upper', 1, 1.3, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDEUpperNO:sPDEUpperNO', [0], 'powercurve-21alt-15-Upper', 1, 1.5, 21, appdfolder);

[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aKGStarLower:sKGStarLower', [0], 'powercurve-21alt-03-cKGstar', 1, 0.3, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aKGStarLower:sKGStarLower', [0], 'powercurve-21alt-05-cKGstar', 1, 0.5, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aKGStarLower:sKGStarLower', [0], 'powercurve-21alt-07-cKGstar', 1, 0.7, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aKGStarLower:sKGStarLower', [0], 'powercurve-21alt-09-cKGstar', 1, 0.9, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aKGStarLower:sKGStarLower', [0], 'powercurve-21alt-11-cKGstar', 1, 1.1, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aKGStarLower:sKGStarLower', [0], 'powercurve-21alt-13-cKGstar', 1, 1.3, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aKGStarLower:sKGStarLower', [0], 'powercurve-21alt-15-cKGstar', 1, 1.5, 21, appdfolder);

[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDELower:sPDELower', [0], 'powercurve-21alt-03-Lower', 1, 0.3, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDELower:sPDELower', [0], 'powercurve-21alt-05-Lower', 1, 0.5, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDELower:sPDELower', [0], 'powercurve-21alt-07-Lower', 1, 0.7, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDELower:sPDELower', [0], 'powercurve-21alt-09-Lower', 1, 0.9, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDELower:sPDELower', [0], 'powercurve-21alt-11-Lower', 1, 1.1, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDELower:sPDELower', [0], 'powercurve-21alt-13-Lower', 1, 1.3, 21, appdfolder);
[~,~] = FuncAppDPowerCurveSeq( 0, NUMOFREPS, 'aPDELower:sPDELower', [0], 'powercurve-21alt-15-Lower', 1, 1.5, 21, appdfolder);
