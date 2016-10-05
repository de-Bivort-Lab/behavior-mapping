This code is provided to facilitate understanding of the methods described in "Systematic exploration of unsupervised methods for mapping behavior". It is not intended to be run as a whole. Instead, individual data preparation, processing and presentation methods are documented in the hope that they can be adapted to run on foreign data sets without great effort.

The codebase was developed to run on MATLAB (2015b or later) under OS X and Linux. This is mostly due to the use of the hard-coded paths relative to ~.

1) The MotionMapper code (required for t-SNE mapping methods) has C modules which require compilation. Precompiled versions for OS X are provided with this source code. To run the MotionMapper under Linux you first need to compile the required mex files by running the compile_mex_files command. Please be sure to change to the MotionMapper directory before issuing this command. See MotionMapper/README.txt
for details.

2) Most of the code assumes that all modules are part of the current MATLAB path, so it is recommended that you copy the code to ~/motifs and run:
addpath(genpath('~/motifs'));

3) Some mapping methods make use of MATLAB's support for parallel computing. To take advantage of it run:
parpool(2);
or adjust based on the number of processing cores you want to make available to MATLAB.

Structure of codebase (assumed relative to ~ under OS X and Linux, paths will require modification for the code to run under Windows):

motifs/                code repository root
motifs/MotionMapper    code from (Berman et al 2014)
motifs/prep            prepare data for processing, populates ~/data folder (subfolders in ~/data must exist)
motifs/mapping         support for all mapping methods referenced in the paper
motifs/metrics         support for all metrics referenced in the paper
motifs/plots           render figures and movies
motifs/odyssey         scripts to submit jobs to Harvard's Odyssey computing cluster (not required)

data/               input to algorithms, download here: https://zenodo.org/record/159191/files/raw%20data.zip
data/cfs            frame-normalized wavelet data for each fly
data/cfspc          PCA-compressed high-variance frame-normalized wavelet data for each fly
data/datastarts     starting frame for each fly's data
data/movies         raw movies, download here: https://zenodo.org/record/159191#.V_QIq5MrJE4
data/moviesyncinfo  starting frame for each fly's movie, used to synchronize movies to data sets
data/shufpcs        results from PCA shuffling procedure, used to determine how many PCs to keep
data/raw            raw data
data/varthresholds  variance thresholds, used to separate low- and high- variance frames

results/       results from processing
results/jobs   job files submitted to Harvard's Odyssey computing cluster (not required)


-------------------
This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License. To
view a copy of this license, visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to
Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

-------------------
Modifications to MotionMapper are shared under the same conditions as the MotionMapper code itself, see MotionMapper/README.txt for details.
