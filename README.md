# Automating MountainSort analysis for Opatz lab
This is an interface for automating MountainSort analysis for the Opatz developmental neurophysiology lab (http://www.opatzlab.com/)

MountainSort GitHub: https://github.com/flatironinstitute/mountainsort

Specifically, it works on Windows Subsystem for Linux (WSL) (more details in ./_MountainSort_OpatzLab/resources)

Organized and written by Benjamin Li with mentorship from Sebastian Bitzenhofer and Mattia Chini (http://www.opatzlab.com/team-members/) during IPAN 2018 (http://www.eecs.umich.edu/ipan/). Hope this may be helpful!

## Folder structure
*After cloning, please create the empty folders "input" and "output" in ./_MountainSort_OpatzLab to hold the automatically genearted MountainSort input and output files, see **Preprocessing pipeline** and **Analysis pipeline***

The main interface is in ./_MountainSort_OpatzLab. Examples are in ./mountainsort_examples-master and zips from GitHub are in ./zips from GitHub

## Software
MountainSort version 1 runs on Ubuntu, MountainSort version 2 runs on any Linux flavor or Mac. GPU support is not necessary but sorting larger files may benefit from more working memory. This summary is for MountainSort v1 (code development now frozen)

WSL on Windows 10: https://docs.microsoft.com/en-us/windows/wsl/install-win10

X server for GUI support with WSL: https://seanthegeek.net/234/graphical-linux-applications-bash-ubuntu-windows/

## Installation and test
### Downloading this repository
```shell
git clone https://github.com/benyli/MountainSort-OpatzLab.git
```
or download zip with top left green button

Install MountainSort and the supporting MountainLab and co. here: https://mountainsort.readthedocs.io/en/latest/

If you are behind a firewall or something like that, add-apt-repository -y ppa:magland/mountainlab may not work. See https://askubuntu.com/questions/452595/cannot-add-ppa-behind-proxy-ubuntu-14-04

Test the installation using the examples provided. The examples folder from MountainSort is included in the MountainSort-OpatzLab folder

## Sort your own data
Edit the geom.csv and params.json files as needed for your experiment, see documentation here: https://mountainsort.readthedocs.io/en/latest/first_sort.html

Be careful when changing the params.json files because .json files can be finicky with formatting. Currently, we are using a default preprocessing pipeline, mountainsort3.mlp

## nlx to sorted data
*Paths are specified below in relation to ./_MountainSort_OpatzLab/code*

_MountainSort_OpatzLab has a folder structure that organizes the following analysis pipeline. First run ./mfiles/prepare_raw_data_MountainSort.m and then ./MountainSort.sh, followed by ./MountainView.sh. Do not change the _MountainSort_OpatzLab folder name to more than one word or the sorter may not work (trouble finding sorter files)

MountainSort input and output files are in a .mda format (https://mountainsort.readthedocs.io/en/latest/first\_sort.html, https://github.com/flatironinstitute/mountainlab/blob/master/docs/source/mda\_file\_format.rst)


### Preprocessing pipeline
./mfiles/prepare_raw_data_MountainSort.m will take raw nlx data and save it in mda format in ./input. It will call ./mfiles/nlx_to_mda.m, where you can change the number of channels and recording period to sort

Be sure to update geom.csv as you update the channels

### Analysis pipeline
- prepare_raw_data_MountainSort.m converts nlx data to mda format
- ./MountainSort.sh will sort input files in ./input and visualize the last experiment sorted when it finishes
- ./MountainView.sh will use MountainView to visualize output files in ./output
- analyze_MS_output.m analyzes the mda output files

### USAGE: MountainSort.sh and MountainView.sh
- run in ./
- provide no input parameters to sort all mda files in ./input (e.g., ./MountainSort.sh)
- provide an input filename (not necessary to include the .mda) to sort an individual file in ./input (e.g., ./MountainSort.sh raw_data.2018-02-22_10-18-08)
- right-click to paste in WSL

### USAGE: mfiles
- in prepare_raw_data_MountainSort.m, change datadir_folder to where your nlx recording data is stored

## Reference Linux commands that are automated in ./MountainSort.sh and ./MountainView.sh
Originally from https://mountainsort.readthedocs.io/en/latest/

### Run sorting without curation
note cluster metrics output does not work with --curate=false
```
mlp-run ./pipelines/mountainsort3.mlp sort --raw=./input/YOUR_FILENAME_HERE.mda --geom=./params/geom.csv --firings_out=./output/YOUR_FILENAME_HERE.no_curation.mda --_params=./params/params.json --curate=false
```

### View results
```bash
mountainview --raw=./input/raw2.mda --firings=./output/firings2.mda --geom=./params/geom.csv --samplerate=32000
```

### Run sorting with curation
```bash
mlp-run ./pipelines/mountainsort3.mlp sort --raw=./input/YOUR_FILENAME_HERE.mda --geom=./params/geom.csv --firings_out=./output/YOUR_FILENAME_HERE.with_curation.mda --_params=./params/params.json --curate=true --cluster_metrics_out=./output/cluster_metrics.YOUR_FILENAME_HERE.json
```

### View results with and without curation
```bash
mountainview --raw=./input/YOUR_FILENAME_HERE.mda --firings=./output/YOUR_FILENAME_HERE.no_curation.mda --geom=./params/geom.csv --samplerate=32000 --cluster_metrics=./output/cluster_metrics.YOUR_FILENAME_HERE.json
```

```bash
mountainview --raw=./input/YOUR_FILENAME_HERE.mda --firings=./output/YOUR_FILENAME_HERE.with_curation.mda --geom=./params/geom.csv --samplerate=32000 --cluster_metrics=./output/cluster_metrics.YOUR_FILENAME_HERE.json
```
