# MATLAB CODE FOR MULTIPLE CORRELATED ARMS

This site provides Matlab code to implement the allocation policies and stopping times for multiarm clinical trials and numerical experiements that are described in the following paper: 

Chick, Stephen E. and Gans, Noah and Yapar, Ozge, Bayesian Sequential Learning for Clinical Trials of Multiple Correlated Medical Interventions (August 31, 2020). INSEAD Working Paper No. 2020/40/TOM/ACGRE, Available at SSRN: https://ssrn.com/abstract=3184758 or http://dx.doi.org/10.2139/ssrn.3184758

The code requires (a) some setup that must be done once per machine, to create code to describe the local installation, to create data files that store solutions to certain standardized optimal stopping problems and to create standardized random variables that will be used in the simulations, and then (b) some code to execute each time you wish to use the code for your applications, or to recreate the graphs from the paper.

# SETUP (ONCE PER MACHINE)
Below stages should be implemented once per machine to create code to describe the local installation, to create data files that store solutions to certain standardized optimal stopping problems and to create standardized random variables that will be used in the simulations
1. Install code from Peter Frazier et al's correlated KG, https://people.orie.cornell.edu/pfrazier/src.html under MatlabKG library. Extract from the zip. (Default folder name is "matlabKG". If the folder name is different, either change it to "matlabKG" or modify following steps according to your folder name.)
2. Install code from Chick, Frazier, Gans PDE solution, https://github.com/sechick/pdestop. (Default folder name is "pdestop". If the folder name is different, either change it to "pdestop" or modify following steps according to your folder name.)
3. Install the code from this repo. (Default folder name is "multiarmMatlab". If the folder name is different, either change it to "multiarmMatlab" or modify following steps according to your folder name.)
4. Put multarmcode, pdestop, and matlabKG folders into the same directory. 
5. Make multiarmMatlab folder the current directory. 
6. Create a file called **SetPaths.m**, which has the following:

> pdecorrfolder = 'multiarmMatlab';
> pdecodefolder = 'pdestop';
> kgcbfolder = 'matlabKG';
> 
> [corrbasefol,name,ext] = fileparts(pwd);
> 
> pdecorr = [ corrbasefol strcat('\', pdecorrfolder,'\')];
> addpath(genpath(pdecorr));
> 
> pdecode = [ corrbasefol strcat('\', pdecodefolder,'\')];
> addpath(genpath(pdecode));
> 
> kgcb = [ corrbasefol strcat('\', kgcbfolder,'\')];
> addpath(genpath(kgcb));
	
If your directory structure or folder names are different, adjust the SetPaths.m code accordingly. pdecorr, pdecode and kgcb should contain the directories of multiarmMatlab, pdestop and matlabKG codes.

7. Run SetSolFiles.m, which creates the standardized PDE solution files to be used in cPDELower and cPDEUpper policies. This step is needed to run only once per machine.
8. Run SetRandomVars.m, which creates the files that contain the random numbers that will to be used in simulation replications. This step is needed to run only once per machine. 

# IN A SESSION TO RUN ALLOCATION POLICIES AND STOPPING TIMES
The code can be used to calculate the allocation policy and stopping time results for a given problem. 
	1. Run SetPaths.m to perform some initializations for the path variables.
	2. ExamplePolicies.m is intended to be copied and pasted to the command window. It includes code that sets up an example problem and calls allocation policies and stopping times for this example problem. 

# IN A SESSION TO OBTAIN EVI VALUES FROM CPDE, CPDELOWER and CPDEUPPER
The code can be used to calculate the expected value of information (EVI) approximations for a given problem. 
	1. Run SetPaths.m to perform some initializations for the path variables.
	2. ExamplecallingcPDEs.m is intended to be copied and pasted to the command window. It contains examples that show how to get EVI values estimated with cPDE, cPDELower and cPDEUpper, how to get the arm from cPDE, cPDELower and cPDEUpper allocation policies, and how to get whether cPDE, cPDELower and cPDEUpper stopping times stop or continue for an example problem. 

# TO REPLICATE THE FIGURES AND TABLES IN CHICK, GANS, YAPAR (2020)
The code can be used to produce all graphs and tables in the above paper. 
	1. Run SetPaths.m to perform some initializations for the path variables.
	2. ReplicateFiguresRev1.m is intended to be copied and pasted to the command window. The code that corresponds to each section of the paper is labeled with comments.