#!/bin/bash

# exit on error
set -e

# -----------------
# SLURM SCRIPT for HPC

# Copy/paste this job script into a text file and submit with the command:
#   sbatch thefilename
# job standard output will go to the file slurm-%j.out (where %j is the job ID)
#SBATCH --time=00:30:00  # walltime limit (HH:MM:SS)
#SBATCH --nodes=1  # number of nodes
#SBATCH --ntasks-per-node=4  # 4 processor core(s) per node


# -------------------
# 1. Micromamba Activation
# -------------------

eval "$(micromamba shell hook --shell bash)"
micromamba activate mngs_env


# -------------------------
# 4. Assembly using Megahit
# -------------------------

 echo "[2] MEGAHIT"

megahit -1 working_files/wuhan1_clean_1.fastq -2 working_files/wuhan1_clean_2.fastq -o working_files/w1_megahit_out.fa --min-contig-len 500

megahit -1 working_files/wuhan2_clean_1.fastq -2 working_files/wuhan2_clean_2.fastq -o working_files/w2_megahit_out.fa --min-contig-len 500


# -------------------------
# 4.5 Taxonomy Classification (bacteria)
# -------------------------

# wuhan 1
kraken2-build --download-library bacteria --db working_files/kraken2_bacteria_db
kraken2-build --build --db working_files/kraken2_bacteria_db
kraken2 \
  --db working_files/kraken2_bacteria_db \
  --paired wuhan1_clean_1.fastq wuhan1_clean_2.fastq \
  --threads 8 \
  --use-names \
  --report wuhan1_kraken.html \
  --output wuhan1.kraken


# wuhan 2
kraken2 \
  --db working_files/kraken2_bacteria_db \
  --paired wuhan2_clean_1.fastq wuhan2_clean_2.fastq \
  --threads 8 \
  --use-names \
  --report wuhan2_kraken.html \
  --output wuhan2.kraken

# -------------------------
# end of script