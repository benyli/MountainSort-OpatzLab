#!/bin/bash
# views output files in ./output with MountainView
echo "MountainView script"

function view() {
	output_data_filename=$1
	echo "----------"
	echo "Analyzing $output_data_filename"
	echo -e "----------\n\n\n\n\n"
	raw_data_name=$(echo $output_data_filename | cut -d'.' -f 3)
	mountainview --raw="./input/raw_data.$raw_data_name.mda" --firings=$output_data_filename --geom=./params/geom.csv \
	  --samplerate=32000 --cluster_metrics="./output/cluster_metrics.$raw_data_name.json"
}

if [ -n "$1" ]; then
	output_data_filename="./output/$1.mda"
	view $output_data_filename
  else
	for output_data_filename in ./output/*.mda
	do
		view $output_data_filename
	done
fi
