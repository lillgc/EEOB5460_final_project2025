#!/bin/bash

# exit on error
set -e

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

#installing python modules
pip install pandas
#pip install os
#pip install subprocess

echo "python mods installed"


echo "[7] starting python script"

python3 <<END_PYTHON
import pandas as pd
import os

print("Current working directory:", os.getcwd())

# Load taxid files
w1_taxids = pd.read_csv("working_files/w1_mg_taxids.txt", header=None, names=["taxid"], dtype=str)
w2_taxids = pd.read_csv("working_files/w2_mg_taxids.txt", header=None, names=["taxid"], dtype=str)

# Load taxonomy databases
def load_names(file_path):
    taxid_to_name = {}
    with open(file_path) as f:
        for line in f:
            parts = [p.strip() for p in line.split("|")]
            if len(parts) >= 4 and parts[3] == "scientific name":
                taxid_to_name[parts[0]] = parts[1]
    return taxid_to_name

def load_nodes(file_path):
    child_to_parent = {}
    with open(file_path) as f:
        for line in f:
            parts = line.strip().split("\t|\t")
            child = parts[0].strip()
            parent = parts[1].strip()
            child_to_parent[child] = parent
    return child_to_parent

names = load_names("working_files/taxonomy_db/names.dmp")
parents = load_nodes("working_files/taxonomy_db/nodes.dmp")

# Lineage processing
def get_lineage(taxid, names_dict, parents_dict):
    lineage = []
    visited = set()
    while taxid not in visited and taxid != "1":
        visited.add(taxid)
        name = names_dict.get(taxid, "N/A")
        lineage.append(name)
        taxid = parents_dict.get(taxid, "1")
    return " > ".join(reversed(lineage))

w1_taxids["lineage"] = w1_taxids["taxid"].apply(lambda tid: get_lineage(tid, names, parents))
w2_taxids["lineage"] = w2_taxids["taxid"].apply(lambda tid: get_lineage(tid, names, parents))

# Save lineage files
w1_taxids.to_csv("working_files/w1_mg_taxid_lineage_output.txt", sep="\t", index=False)
w2_taxids.to_csv("working_files/w2_mg_taxid_lineage_output.txt", sep="\t", index=False)

# Process BLAST results
blast_columns = [
    "qseqid", "sseqid", "pident", "length", "mismatch", "gapopen",
    "qstart", "qend", "sstart", "send", "evalue", "bitscore"
]

w1_blast_df = pd.read_csv("working_files/wuhan1_blastn_mega_hits.txt", sep="\t", header=None, names=blast_columns)
w2_blast_df = pd.read_csv("working_files/wuhan2_blastn_mega_hits.txt", sep="\t", header=None, names=blast_columns)

# Merge taxonomy data
w1_taxid_map = pd.read_csv("working_files/w1_mg_taxid_map.txt", sep="\t", 
                         header=None, names=["accession_base", "accession_full", "taxid", "gi"])[["accession_full", "taxid"]]
w2_taxid_map = pd.read_csv("working_files/w2_mg_taxid_map.txt", sep="\t",
                         header=None, names=["accession_base", "accession_full", "taxid", "gi"])[["accession_full", "taxid"]]

w1_merged_blast = w1_blast_df.merge(w1_taxid_map, left_on="sseqid", right_on="accession_full", how="left")
w2_merged_blast = w2_blast_df.merge(w2_taxid_map, left_on="sseqid", right_on="accession_full", how="left")

w1_lineage_df = pd.read_csv("working_files/w1_mg_taxid_lineage_output.txt", sep="\t")
w2_lineage_df = pd.read_csv("working_files/w2_mg_taxid_lineage_output.txt", sep="\t")

w1_tax_class = w1_merged_blast.merge(w1_lineage_df, on="taxid", how="left")
w2_tax_class = w2_merged_blast.merge(w2_lineage_df, on="taxid", how="left")

# Save final outputs
w1_tax_class.to_csv("working_files/wuhan1_mg_blast_with_lineage.txt", sep="\t", index=False)
w2_tax_class.to_csv("working_files/wuhan2_mg_blast_with_lineage.txt", sep="\t", index=False)

print("Pipeline completed successfully")
END_PYTHON

echo "success."
