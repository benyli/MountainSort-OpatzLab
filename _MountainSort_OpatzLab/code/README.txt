## these are instructions for automating MountainSort analysis for Opatz lab
# MountainSort GitHub: https://github.com/flatironinstitute/mountainsort
# Benjamin Li (benyli@umich.edu) 2018-07

# at risk of annoyance, I tried to be thorough in the description here. More details for running MountainSort on WSL are in ./MountainSort_OpatzLab/resources. Hope this may be helpful!

# software
MountainSort version 1 runs on Ubuntu, MountainSort version 2 runs on any Linux flavor or Mac. GPU support is not necessary but sorting larger files may benefit from more working memory
This summary is for MountainSort v1 (code development now frozen)
Windows Subsystem for Linux (WSL) on Windows 10: https://docs.microsoft.com/en-us/windows/wsl/install-win10
VcXsrv X server for GUI support with WSL: https://seanthegeek.net/234/graphical-linux-applications-bash-ubuntu-windows/

# installation and test
install MountainSort and the supporting MountainLab and co. here: https://mountainsort.readthedocs.io/en/latest/
if you are behind a firewall or something like that, add-apt-repository -y ppa:magland/mountainlab may not work. See https://askubuntu.com/questions/452595/cannot-add-ppa-behind-proxy-ubuntu-14-04
test the installation using the examples provided. The examples folder is included in the MountainSort_OpatzLab folder

# sort your own data
edit the geom.csv and params.json files as needed for your experiment, see documentation here: https://mountainsort.readthedocs.io/en/latest/first_sort.html.
Be careful when changing the params.json files because .json files can be finicky with formatting. Currently, we are using a default preprocessing pipeline, mountainsort3.mlp

# nlx to sorted data
*Paths are specified below in relation to _MountainSort_OpatzLab/code*

_MountainSort_OpatzLab has a folder structure that organizes the following analysis pipeline. First run ./mfiles/prepare_raw_data_MountainSort.m and then ./MountainSort.sh, followed by ./MountainView.sh
Do not change the _MountainSort_OpatzLab folder name to more than one word or the sorter may not work (trouble finding sorter files)

MountainSort input and output files are in a .mda format (https://mountainsort.readthedocs.io/en/latest/first_sort.html, https://github.com/flatironinstitute/mountainlab/blob/master/docs/source/mda_file_format.rst)
./mfiles/prepare_raw_data_MountainSort.m will take raw nlx data and save it in mda format in ./input. It will call ./mfiles/nlx_to_mda.m, where you can change the number of channels and recording period to sort
Be sure to update geom.csv as you update the channels

prepare_raw_data_MountainSort.m converts nlx data to mda format
./MountainSort.sh will sort input files in ./input and visualize the last experiment sorted when it finishes
./MountainView.sh will use MountainView to visualize output files in ./output
analyze_MS_output.m analyzes the mda output files

USAGE: MountainSort.sh and MountainView.sh
- run in ./
- provide no input parameters to sort all mda files in ./input (e.g., ./MountainSort.sh)
- provide an input filename (not necessary to include the .mda) to sort an individual file in ./input (e.g., ./MountainSort.sh raw_data.2018-02-22_10-18-08)
- right-click to paste in WSL

USAGE: mfiles
- in prepare_raw_data_MountainSort.m, change datadir_folder to where your nlx recording data is stored





# reference Linux commands that are automated in ./MountainSort.sh and ./MountainView.sh

# run sorting without curation
# note cluster metrics output does not work with --curate=false
mlp-run ./pipelines/mountainsort3.mlp sort --raw=./input/YOUR_FILENAME_HERE.mda --geom=./params/geom.csv --firings_out=./output/YOUR_FILENAME_HERE.no_curation.mda --_params=./params/params.json --curate=false

# view results
mountainview --raw=./input/raw2.mda --firings=./output/firings2.mda --geom=./params/geom.csv --samplerate=32000

# run sorting with curation
mlp-run ./pipelines/mountainsort3.mlp sort --raw=./input/YOUR_FILENAME_HERE.mda --geom=./params/geom.csv --firings_out=./output/YOUR_FILENAME_HERE.with_curation.mda --_params=./params/params.json --curate=true --cluster_metrics_out=./output/cluster_metrics.YOUR_FILENAME_HERE.json

# view results with and without curation
mountainview --raw=./input/YOUR_FILENAME_HERE.mda --firings=./output/YOUR_FILENAME_HERE.no_curation.mda --geom=./params/geom.csv --samplerate=32000 --cluster_metrics=./output/cluster_metrics.YOUR_FILENAME_HERE.json
mountainview --raw=./input/YOUR_FILENAME_HERE.mda --firings=./output/YOUR_FILENAME_HERE.with_curation.mda --geom=./params/geom.csv --samplerate=32000 --cluster_metrics=./output/cluster_metrics.YOUR_FILENAME_HERE.json
