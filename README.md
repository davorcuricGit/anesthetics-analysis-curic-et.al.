# anestheticsAnalysis
repository for the code used in the analysis of the manuscript titled "Existence of multiple transitions of the critical state due to anesthetics"


This is documentation for the code provided along with the manuscript:Existence of multiple transitions of the critical state due to anesthetics
Link to article will go here
Corresponding Author: Davor Curic, dcuric@ucalgary.ca

Contents:
1. System requirements
2. Installation guide
3. Demo
4. Instructions for use

1. System requirements
This code is run on MATLAB R2022a, Windows 10. Code should work on linux but file path delimiters might need to be changed.
Demo code should run on earlier versions of MATLAB (tested on 2020a), but allignment to Allan atlas may require R2022a (the sample data is already aligned)

IMPORTANT
This demo also requires the NCCtoolbox (in particular plmle and pvcalc)
https://github.com/nctoolbox/nctoolbox

All other coustom functions are located in functions subdirectory


2. Instillation guide
Make sure that the code has path access to both the functions subdirectory and NCCtoolbox. Otherwise it should work as-is.

3.DEMO
The demo includes code to derive avalanches from a quiet-wakefulness recording. IMPORTANT: Due to file size limitations, the recording is hosted seperately at the following Zenodo repository: 10.5281/zenodo.12725849 (DOI). The Zenodo repository also included avalanches (size and duration) across all recordings for a threshold of 1 standard deviation above the mean. The recording is sampled at 50Hz and has been filtered to be between 0.1-15hz.
The recording has already been aligned to the Allan atlas and periods of excessive movement have been removed (replaced by zeros).
The recording is also spatially downsampled from 256x256 to 128x128 which is size used in the manuscript

The included demo does the following:
	a. Generates avalanches by clustering calcium activations in an extended neighbourhood (generateAvalanches.m)
		The code outputs avalanches in a .mat to be analyzed in a seperate code (saved here as 'samplerecording_avalanches.mat')
    IMPORTANT: the sample recording was to large to be included in the git repository. This can be shared upon reasonable request to the corresponding authour. 
    The avalanches generated from this sample recording for a threshold of 1stdev above the mean (per pixel) is included in the repository ('samplerecording_avalanches.mat')
	b. Analyze the avalanche distributions by calculating critical exponents (tau, alpha, gamma), and the scaling relation (loadAvalanches.m). 
		The code takes 'samplerecording_avalanches.mat' as input
    
    c. generatePhaseSpaceRep.m takes the demo recording and generates and plots the hilbert transform representation shown in the supplementary material.
    
    d. plotAvalancheProfile.m takes the avalanches generated in generateAvalanches.m and plots their initiation points in the XY plane.


Notes:	Generating the avalanches can take a while if there are a lot of activations. 
    In the demo the threhsold is set to 3standard deviations to reduce the runtime. 
	Total run time on AMD 3600 was 170 sec.


4. Instructions for use
Step 1. Run generateAvalanches.m
	This this requires a clustering radius to be defined. In the paper we used 8 pixels from the partial correlation function.
	Also requires a threshold to be set. In the paper we use 1stdev but the demo uses 3 for reducing run time

Step 2. Run loadAvalanches.m

	This loads the file generated in the previous step. 
	Avalanches are logarithmically binned and maximum likelihood is used to calculate critical exponents.
	The only free parameters are smin,smax, dmin,dmax which determine the fitting range.
	In the paper we varied varied these parameters to find the largest possible range where the pvalue is > 0.1.

Step 3. run plotAvalancheProfile.m
    
    This plots the avalanche initiation points found in Step1. 
    The only parameter to set is an exclusion size - avalanches smaller than this size will not be plotted
    This is typically set to the value of Smin found in Step2.
    the

Step 4. generatePhaseSpaceRep
    This code does not rely on any of the others and takes no inputs. Simply plots the phase space representation of the sample recording.
