SETUP
	1. Install code from Peter Frazier et al's correlated KG, https://people.orie.cornell.edu/pfrazier/src.html under MatlabKG library. Extract from the zip. (Default folder name is "matlabKG". If the folder name is different, either change it to "matlabKG" or modify following steps according to your folder name.)
	2. Install code from Chick, Frazier, Gans PDE solution, https://github.com/sechick/pdestop. (Default folder name is "pdestop". If the folder name is different, either change it to "pdestop" or modify following steps according to your folder name.)
	3. Install the code from this repo. (Default folder name is "multiarmMatlab". If the folder name is different, either change it to "multiarmMatlab" or modify following steps according to your folder name.)
	4. Put multarmcode, pdestop, and matlabKG folders into the same directory. 
	5. Make multiarmMatlab folder the current directory. 
	6. Create a file called SetPaths.m, which has the following:

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
	
	(If your directory structure or folder names are different, adjust the SetPaths.m code accordingly. pdecorr, pdecode and kgcb should contain 	the directories of multiarmMatlab, pdestop and matlabKG codes.)

	7. Run SetSolFiles.m, which creates the standardized PDE solution files to be used in cPDELower and cPDEUpper policies. This step is needed to run only once per machine.

ALLOCATION POLICIES AND STOPPING TIMES
ExamplePolicies.m and ExamplecallingcPDEs.m contains examples that show how to call allocation policies and stopping times defined in Chick, Gans, Yapar (2020).

TO REPLICATE THE FIGURES AND TABLES IN CHICK, GANS, YAPAR (2020)
Run ReplicateFiguresRev1.m to generate the simulation results needed for figures and tables, and to generate figures and tables themselves. NOTE: Be aware that ReplicateFiguresRev1.m runs all simulation replications reported in the paper sequentially, therefore takes a consirable amount of time to be completed. It is possible to run simulation repliations in different CPUs in parallel, collect all simulation data to the same folder, and calculate summary statistics needed for figures and tables.