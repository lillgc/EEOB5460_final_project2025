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

eval "$(micromamba shell hook --shell bash)"
micromamba activate mngs_env



# -------------------
# 10. Download Reference Genomes
# ----------------------------
echo "[DOWNLOAD] Downloading reference genomes..."
mkdir -p fasta_files

curl -L -o fasta_files/WHU_1.fasta "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=MN908947.3&rettype=fasta&retmode=text"
curl -L -o fasta_files/SARS-CoV.fasta "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=AY278741.1&rettype=fasta&retmode=text"
curl -L -o fasta_files/Bat-SL-CoVZC45.fasta "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=MG772933.1&rettype=fasta&retmode=text"
curl -L -o fasta_files/MERS-CoV.fasta "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=JX869059.2&rettype=fasta&retmode=text"

echo "ref genomes downloaded"

# ----------------------------
# 11. Phylogenetic Tree Creation
# ----------------------------

pip install seqmagick

echo "seqmagick installed"


## wuhan 1
echo "[10] Phylogenetic analysis"
cat working_files/w1_top_contig.fasta fasta_files/*.fasta > working_files/all_CoV_w1.fasta
mafft --auto working_files/all_CoV_w1.fasta > working_files/w1_aligned.fasta

seqmagick convert --input-format fasta --output-format phylip working_files/w1_aligned.fasta working_files/w1_aligned.phy

phyml -i working_files/w1_aligned.phy -d nt -m GTR --bootstrap 100

echo "phylogenetic tree w1 created"

## wuhan 2
echo "[10] Phylogenetic analysis"
cat working_files/w2_top_contig.fasta fasta_files/*.fasta > working_files/all_CoV_w2.fasta
mafft --auto working_files/all_CoV_w2.fasta > working_files/w2_aligned.fasta

seqmagick convert --input-format fasta --output-format phylip working_files/w2_aligned.fasta working_files/w2_aligned.phy

phyml -i working_files/w2_aligned.phy -d nt -m GTR --bootstrap 100

echo "phylogenetic tree w2 created"

