#!/bin/bash

# exit on error
set -e

# -------------------
# 1. Micromamba Activation
# -------------------

eval "$(micromamba shell hook --shell bash)"
micromamba activate mngs_env

micromamba install -c bioconda biom-format

echo "biom-format installed"

# -------------------------
# 5. Virus Detection (2nd blast)
# -------------------------

echo "[5] BLASTn"

# wuhan 1
blastn -query working_files/w1_megahit_out.fa/final.contigs.fa \
       -db working_files/blast_viral_db/ref_viruses_rep_genomes \
       -out working_files/wuhan1_blastn_mega_hits.txt \
       -evalue 1e-5 \
       -outfmt 6 \
       -num_threads 8

## wuhan 2
blastn -query working_files/w2_megahit_out.fa/final.contigs.fa \
       -db working_files/blast_viral_db/ref_viruses_rep_genomes \
       -out working_files/wuhan2_blastn_mega_hits.txt \
       -evalue 1e-5 \
       -outfmt 6 \
       -num_threads 8


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




