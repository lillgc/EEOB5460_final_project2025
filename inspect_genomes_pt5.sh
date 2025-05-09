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

# -------------------------
# 6. Taxonomic Profiling Prep
# -------------------------

# pull accession list
cut -f2 working_files/wuhan1_blastn_mega_hits.txt | sort | uniq > working_files/mg_accession_w1_list.txt
cut -f2 working_files/wuhan2_blastn_mega_hits.txt | sort | uniq > working_files/mg_accession_w2_list.txt

# download db to match accession list to taxonomy id
wget -P  working_files/ ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz
gunzip -f working_files/nucl_gb.accession2taxid.gz

echo "accession2taxid downloaded"

# pull taxids for accessionlist
grep -Ff working_files/mg_accession_w1_list.txt working_files/nucl_gb.accession2taxid > working_files/w1_mg_taxid_map.txt
grep -Ff working_files/mg_accession_w2_list.txt working_files/nucl_gb.accession2taxid > working_files/w2_mg_taxid_map.txt

# filter for only taxids
cut -f3 working_files/w1_mg_taxid_map.txt | sort | uniq > working_files/w1_mg_taxids.txt
cut -f3 working_files/w2_mg_taxid_map.txt | sort | uniq > working_files/w2_mg_taxids.txt



# -------------------
# 8. Taxonomic Classification
# -------------------

echo "creating taxon db"
#micromamba install taxonkit

mkdir -p working_files/taxonomy_db
wget -P working_files/taxonomy_db https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz
tar -xzf working_files/taxonomy_db/taxdump.tar.gz -C working_files/taxonomy_db

echo "taxon db created"