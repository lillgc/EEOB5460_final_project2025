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


cd working_files/
bowtie2 -x virus_index -1 wuhan1_clean_1.fastq -2 wuhan1_clean_2.fastq -S w2_virus_mapped.sam
samtools view -bS w2_virus_mapped.sam | samtools sort -o w2_virus_mapped_sorted.bam
samtools index w2_virus_mapped_sorted.bam
bcftools mpileup -f viral_ref_genome_output.fasta w2_virus_mapped_sorted.bam | bcftools call -mv -Oz -o w2_variants.vcf.gz
bcftools index w2_variants.vcf.gz 
cd ..

echo "wuhan2 complete"
