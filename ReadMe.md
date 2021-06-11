# MATLAB CODE FOR MULTIPLE CORRELATED ARMS

This site provides Matlab code to implement the allocation policies and stopping times for multiarm clinical trials and numerical experiements that are described in the following paper: 

Chick, Stephen E. and Gans, Noah and Yapar, Ozge, 2021, Bayesian Sequential Learning for Clinical Trials of Multiple Correlated Medical Interventions, Management Science (to appear). 

(Earlier versions of the paper available as: INSEAD Working Paper No. 2020/40/TOM/ACGRE, Available at SSRN: https://ssrn.com/abstract=3184758 or http://dx.doi.org/10.2139/ssrn.3184758)

The Matlab code requires (a) some setup that must be done once per machine, to create code to describe the local installation, to create data files that store solutions to certain standardized optimal stopping problems, and then (b) some code to execute each time you wish to use the code for your applications, or to recreate the graphs from the paper. 

The code in this repo has been tested with Matlab version 2021a on a Windows machine.  

# SETUP (ONCE PER MACHINE)
Below stages should be implemented once per machine to create code to describe the local installation, to create data files that store solutions to certain standardized optimal stopping problems.

1. Install code from Peter Frazier et al's correlated KG, https://people.orie.cornell.edu/pfrazier/src.html under MatlabKG library. Extract from the zip. (Default folder name is "matlabKG". If the folder name is different, either change it to "matlabKG" or modify following steps according to your folder name.)
2. Install code from Chick, Frazier, Gans PDE solution, https://github.com/sechick/pdestop. (Default folder name is "pdestop". If the folder name is different, either change it to "pdestop" or modify following steps according to your folder name.)
3. Install the code from this repo. (Default folder name is "multiarmMatlab". If the folder name is different, either change it to "multiarmMatlab" or modify following steps according to your folder name.)
4. Put multiarmMatlab, pdestop, and matlabKG folders into the same directory. 
5. Make multiarmMatlab folder the current directory. 
6. Create a Matlab code file called **SetPaths.m**, which has the following lines of codes, and save it to the same directory as ReplicateCGY.m:
```
    pdecorrfolder = 'multiarmMatlab';
    pdecodefolder = 'pdestop';
    kgcbfolder = 'matlabKG';
    
    [corrbasefol,name,ext] = fileparts(pwd);

    pdecorr = [ corrbasefol strcat('\', pdecorrfolder,'\')];
    addpath(genpath(pdecorr));

    pdecode = [ corrbasefol strcat('\', pdecodefolder,'\')];
    addpath(genpath(pdecode));
    
    kgcb = [ corrbasefol strcat('\', kgcbfolder,'\')];
    addpath(genpath(kgcb));
```	
If your directory structure or folder names are different, adjust the SetPaths.m code accordingly. When SetPaths.m is executed, variables pdecorr, pdecode and kgcb should contain the directories of multiarmMatlab, pdestop and matlabKG folders, respectively.

7. Run SetSolFiles.m, which creates the standardized PDE solution files to be used in cPDELower and cPDEUpper policies. This step is needed to run only once per machine.

# AT THE BEGINNING OF EACH SESSION
1. Run SetPaths.m to perform initializations for the path variables.
2. Run the following to load the standardized PDE solution files.
```
PDELocalInit;
[cgSoln, cfSoln, ~, ~] = PDELoadSolnFiles(PDEmatfilebase, false);
```
There are then three files with code that demonstrate the usage of the arm allocation policies and adaptive stopping times in the paper. The first two files are demonstrations of calling codes (for allocation policies and stopping times in the first, and to compute expected value of information approximations in the second). The third file gives code that can be used to generate the tables and figures in the paper and electronic companion.

# IN A SESSION TO RUN ALLOCATION POLICIES AND STOPPING TIMES
The code can be used to calculate the allocation policy and stopping time results for a given problem. ExamplePolicies.m is intended to be copied and pasted to the command window. It includes code that sets up an example problem and calls allocation policies and stopping times for this example problem. 

# IN A SESSION TO OBTAIN EVI VALUES FROM CPDE, CPDELOWER and CPDEUPPER
The code can be used to calculate the expected value of information (EVI) approximations for a given problem. ExamplecallingcPDEs.m is intended to be copied and pasted to the command window. It contains examples that show how to get EVI values estimated with cPDE, cPDELower and cPDEUpper. 

# TO MAKE FIGURES AND TABLES SIMILAR TO THE FIGURES AND TABLES IN CHICK, GANS, YAPAR (2021)
The code in ReplicateCGY.m can be used to produce all graphs and tables in the above paper. ReplicateCGY.m is intended to be copied and pasted to the Matlab command window, chunk by chunk. There is statistical noise reported in the simulation output, which may cause graphs to differ in specifics. 

The experiments reported in the paper were actually run on a set of servers, because some of the curves and table entries in the paper required a computationally highly expensive amount of work (most notably, the cPDE arm allocation; but some of the others also are somewhat computationally expensive). Thus, ReplicateCGY.m allows the end user to specify two variables: DOSLOWPAIRS as true or false, depending on whether one wishes to run the most computationally challenging outputs, and DOPAPER as true or false, depending on whether one wishes to run some demo runs or to run experiments as described in the paper. The end user can also set the number of simulation replications for running the experiments for the paper. 

Please see the comments in ReplicateCGY.m for further information.

If the figures and graphs are generated with Monte Carlo analysis with 12 replications per sample path, then the following are the run times on a Win64 machine with Matlab 2021a, Intel i7-chip at 2.5Ghz, 2 cores, 16Gb RAM, even without running the analysis for the cPDE allocation). Note that the paper typically had 500, 1000, or 2000 replications per sample path (so expect very long run times if running on a typical laptop), and that the run times vary for the several graphs and tables.
```
analysis for Sec 6.2 fig 1: Nreps = 12, doslowpairs = 0.
Elapsed time is 752.905698 seconds.
analysis for Sec 7.2 fig 4: Nreps = 12, doslowpairs = 0.
Elapsed time is 1639.834095 seconds.
analysis for Sec 6.4 fig 3: Nreps = 12, doslowpairs = 0.
Elapsed time is 85.565114 seconds.
analysis for sec 6.3 table 1: Nreps = 12, doslowpairs = 0.
Elapsed time is 1698.219284 seconds.
analysis for Sec 6.4 table 2: Nreps = 12, doslowpairs = 0.
Elapsed time is 3136.298123 seconds.
analysis for App C.2 fig EC.1: Nreps = 12, doslowpairs = 0.
Elapsed time is 757.905811 seconds.
analysis for App C.2 fig EC.2: Nreps = 12, doslowpairs = 0.
Elapsed time is 328.416114 seconds.
analysis for App C.2 fig EC.3 and fig EC.4: Nreps = 12, doslowpairs = 0.
Elapsed time is 106.330059 seconds.
analysis for App C.2 fig EC.5: Nreps = 12, doslowpairs = 0.
Elapsed time is 4563.797243 seconds.
miscellany code to plot E[OC], E[TC], E[SC]: Nreps = 50, doslowpairs = 0.
Elapsed time is 422.477464 seconds.
analysis for app C.1 table EC.2: Nreps = 12, doslowpairs = 0.
Elapsed time is 236.660793 seconds.
speed test for sPDE related to sec 6.3 table 1: Nreps = 10, doslowpairs = 0.
Elapsed time is 493.178816 seconds.
```

(c) 2017-2021 The authors, creative commons. If you use the code, please acknowledge this repo and the paper Chick, Gans, Yapar, 2021, Bayesian Sequential Learning for Clinical Trials of Multiple Correlated Medical Interventions, Management Science (to appear). 
