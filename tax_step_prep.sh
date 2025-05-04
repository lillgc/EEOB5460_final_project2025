#!/bin/bash

# exit on error
set -e

# pull accession list
cut -f2 working_files/wuhan1_blastn_hits.txt | sort | uniq > working_files/accession_w1_list.txt
cut -f2 working_files/wuhan2_blastn_hits.txt | sort | uniq > working_files/accession_w2_list.txt

# download db to match accession list to taxonomy id
wget working_files ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz
gunzip -f working_files/nucl_gb.accession2taxid.gz

# pull taxids for accessionlist
grep -Ff working_files/accession_w1_list.txt working_files/nucl_gb.accession2taxid > working_files/w1_taxid_map.txt
grep -Ff working_files/accession_w2_list.txt working_files/nucl_gb.accession2taxid > working_files/w2_taxid_map.txt

# filter for only taxids
cut -f3 working_files/w1_taxid_map.txt | sort | uniq > working_files/w1_taxids.txt
cut -f3 working_files/w2_taxid_map.txt | sort | uniq > working_files/w2_taxids.txt
