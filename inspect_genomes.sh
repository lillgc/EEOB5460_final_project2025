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
# 1. Micromamba Set Up
# -------------------

micromamba create -y -n mngs_env fastp seqtk megahit bowtie2 samtools blast diamond metaphlan2 mafft phyml bcftools -c bioconda -c conda-forge

eval "$(micromamba shell hook --shell bash)"
micromamba activate mngs_env

for tool in fastp megahit blastn diamond samtools bcftools mafft phyml; do
  if ! command -v $tool &> /dev/null; then
    echo "[ERROR] Tool '$tool' missing. Check environment setup."
    exit 1
  fi
done


# -------------------
# 2. Quality Control
# -------------------
#module load fastp

# output cleaned fastq files (trimmed adapters) and html/json qc reports

## wuhan 1
fastp -i patient_raw_fastq/SRR10903402_1.fastq -I patient_raw_fastq/SRR10903402_2.fastq \
  -o working_files/wuhan1_clean_1.fastq -O working_files/wuhan1_clean_2.fastq \
  --detect_adapter_for_pe --thread 8 --html output_files/reports/wuhan1_fastp.html --json output_files/reports/wuhan1_fastp.json

## wuhan 2
fastp -i patient_raw_fastq/SRR10903401_1.fastq -I patient_raw_fastq/SRR10903401_2.fastq \
  -o working_files/wuhan2_clean_1.fastq -O working_files/wuhan2_clean_2.fastq \
  --detect_adapter_for_pe --thread 8 --html output_files/reports/wuhan2_fastp.html --json output_files/reports/wuhan2_fastp.json


# -------------------
# 3. Blastn prep
# -------------------

#module load seqtk

# data prep for blastn (fastq --> fasta)

## wuhan 1
cat working_files/wuhan1_clean_1.fastq working_files/wuhan1_clean_2.fastq > working_files/wuhan1_merged.fastq
seqtk seq -a working_files/wuhan1_merged.fastq > working_files/wuhan1_merged.fasta

## wuhan 2
cat working_files/wuhan2_clean_1.fastq working_files/wuhan2_clean_2.fastq > working_files/wuhan2_merged.fastq
seqtk seq -a working_files/wuhan2_merged.fastq > working_files/wuhan2_merged.fasta

#module load ncbi-rmblastn/2.14.0-py310-vqnew3z


# run blastn (nucleotide search) [takes a couple minutes]
## wuhan 1
blastn -query working_files/wuhan1_merged.fasta \
       -db working_files/blast_viral_db/ref_viruses_rep_genomes \
       -out working_files/wuhan1_blastn_hits.txt \
       -evalue 1e-5 \
       -outfmt 6 \
       -num_threads 8

## wuhan 2
blastn -query working_files/wuhan2_merged.fasta \
       -db working_files/blast_viral_db/ref_viruses_rep_genomes \
       -out working_files/wuhan2_blastn_hits.txt \
       -evalue 1e-5 \
       -outfmt 6 \
       -num_threads 8


# -------------------------
# end of script





