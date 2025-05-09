#!/bin/bash

# Exit on any error
set -e

echo "=== Step 1: Check and create 'fasta_files' directory ==="
if [ -d "fasta_files" ]; then
    echo "Directory 'fasta_files' already exists. Skipping creation."
else
    mkdir fasta_files
    echo "Directory 'fasta_files' created."
fi

echo "=== Step 2: Download reference genomes from NCBI ==="
curl -L -o fasta_files/WHU01.fasta "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=MN988668.1&rettype=fasta&retmode=text"
curl -L -o fasta_files/WHU02.fasta "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=MN988669.1&rettype=fasta&retmode=text"
curl -L -o fasta_files/CoV-2c-EM2012.fasta "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=JX869059.2&rettype=fasta&retmode=text"
curl -L -o fasta_files/Bat-SL-CoVZC45.fasta "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=MG772933.1&rettype=fasta&retmode=text"
curl -L -o fasta_files/SARS-CoV.fasta "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=AY278741.1&rettype=fasta&retmode=text"

echo "=== Step 3: Concatenate all FASTA files ==="
cat fasta_files/*.fasta > all_sequences.fasta

echo "=== Step 4: Load MAFFT and align sequences ==="
module load mafft
mafft --auto all_sequences.fasta > all_sequences_aligned.fasta

echo "=== Step 5: Load IQ-TREE and build phylogenetic tree ==="
module load iqtree2
iqtree2 -s all_sequences_aligned.fasta -m TEST -bb 1000 -alrt 1000

echo "=== Step 6: Check and create 'tree_files' directory ==="
if [ -d "tree_files" ]; then
    echo "Directory 'tree_files' already exists. Skipping creation."
else
    mkdir tree_files
    echo "Directory 'tree_files' created."
fi

echo "=== Step 7: Organize tree output files ==="
mv all_sequences_aligned.fasta.* tree_files/

echo "=== Workflow completed successfully! Output files are in ./tree_files ==="
