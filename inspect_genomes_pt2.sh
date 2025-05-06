#!/bin/bash

# exit on error
set -e

# -------------------
# 1. Micromamba Activation
# -------------------

eval "$(micromamba shell hook --shell bash)"
micromamba activate mngs_env


# -------------------------
# 4. Assembly using Megabit
# -------------------------

 echo "[2] MEGAHIT"

megahit -1 working_files/wuhan1_clean_1.fastq -2 working_files/wuhan1_clean_2.fastq -o working_files/w1_megahit_out.fa --min-contig-len 500

megahit -1 working_files/wuhan2_clean_1.fastq -2 working_files/wuhan2_clean_2.fastq -o working_files/w2_megahit_out.fa --min-contig-len 500

