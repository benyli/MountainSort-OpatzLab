#/bin/bash
# sorts input files in ./input with MountainSort and sends output files to ./output
echo "MountainSort script"

function sort() {
  raw_data_filename=$1
  echo "----------"
  echo "Analyzing " $raw_data_filename
  echo -e "----------\n\n\n\n\n"
  raw_data_name=$(echo $raw_data_filename | cut -d'.' -f 3)

  # without curation
  mlp-run ./pipelines/mountainsort3.mlp sort --raw=$raw_data_filename --geom=./params/geom.csv \
    --firings_out="./output/firing.$raw_data_name.no_curation.mda" --_params=./params/params.json --curate=false
  # with curation
  mlp-run ./pipelines/mountainsort3.mlp sort --raw=$raw_data_filename --geom=./params/geom.csv \
    --firings_out="./output/firing.$raw_data_name.with_curation.mda" --_params=./params/params.json --curate=true \
    --cluster_metrics_out="./output/cluster_metrics.$raw_data_name.json"
}

if [ -n "$1" ]; then
    raw_data_filename="./input/$1.mda"
    sort $raw_data_filename
  else
    for raw_data_filename in ./input/*.mda
    do
      sort $raw_data_filename
    done
fi

# view last sorted experiment
mountainview --raw=$raw_data_filename --firings="./output/firing.$raw_data_name.with_curation.mda" --geom=./params/geom.csv \
  --samplerate=32000 --cluster_metrics="./output/cluster_metrics.$raw_data_name.json"
