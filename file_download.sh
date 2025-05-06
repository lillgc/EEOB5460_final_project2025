#!/bin/bash

set -euo pipefail

# create directories
mkdir -p  patient_raw_fastq
mkdir -p  working_files

# cd to raw data directory
cd patient_raw_fastq

# list of (filenames & urls)
declare -A files
files["SRR10903402_1.fastq"]="https://iastate.box.com/shared/static/i13hh09uhq1x5z50wgum1x3ngzjug8wh?dl=1"
files["SRR10903402_2.fastq"]="https://iastate.box.com/shared/static/hh9bq3nzl3bqd4yzo30u40dhntryxjv5?dl=1"
files["SRR10903401_2.fastq"]="https://iastate.box.com/shared/static/2iotaxl2sbjlwmpj0zc2odr5m2o6akra?dl=1"
files["SRR10903401_1.fastq"]="https://iastate.box.com/shared/static/6s1jrwmy9oj7m2dqp0jkn6y0u8r27mj8?dl=1"
files["viral_ref_genome_output.fasta"]="https://iastate.box.com/shared/static/noyt4085ve152dqgpg337ryhh6ojq4ck?dl=1"

# loop through each file and download
for filename in "${!files[@]}"; do
    url="${files[$filename]}"
    echo "Downloading $filename..."
    wget "$url" -O "$filename"
    if [ $? -eq 0 ]; then
        echo "Downloaded $filename successfully."
    else
        echo "Failed to download $filename."
    fi
done

mv viral_ref_genome_output.fasta ../working_files/

echo "All raw data files successfully downloaded."
