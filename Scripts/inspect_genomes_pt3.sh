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


# -------------------
# Extract Top Contig
# -------------------

# helper function
extract_top_virus_contig() {
  local SAMPLE_DIR="$1"
  local PATIENT_NUM="$2"
  local BLAST_RESULT="${SAMPLE_DIR}/wuhan${PATIENT_NUM}_blastn_mega_hits.txt"
  local CONTIGS="${SAMPLE_DIR}/w${PATIENT_NUM}_megahit_out.fa/final.contigs.fa"

  echo "[EXTRACT] Extracting top viral contig for ${SAMPLE_DIR} (Patient ${PATIENT_NUM})"

  if [ ! -f "$BLAST_RESULT" ]; then
    echo "[ERROR] $BLAST_RESULT not found!"
    exit 1
  fi

  local TOP_HIT=$(head -n 1 "$BLAST_RESULT" | awk '{print $1}')
  if [ -z "$TOP_HIT" ]; then
    echo "[ERROR] No top hit found in $BLAST_RESULT"
    exit 1
  fi

  samtools faidx "$CONTIGS" "$TOP_HIT" > "${SAMPLE_DIR}/w${PATIENT_NUM}_top_contig.fasta" || {
    echo "[ERROR] Failed to extract contig $TOP_HIT"
    exit 1
  }

  echo "Extracted to ${SAMPLE_DIR}/w${PATIENT_NUM}_top_contig.fasta"
}

extract_top_virus_contig "working_files" "1"
extract_top_virus_contig "working_files" "2"


# -------------------
# Mapping & Consensus
# -------------------
echo "[9] Mapping & Consensus"

cd working_files/
bowtie2-build viral_ref_genome_output.fasta virus_index
bowtie2 -x virus_index -1 wuhan1_clean_1.fastq -2 wuhan1_clean_2.fastq -S w1_virus_mapped.sam
samtools view -bS w1_virus_mapped.sam | samtools sort -o w1_virus_mapped_sorted.bam
samtools index w1_virus_mapped_sorted.bam
bcftools mpileup -f viral_ref_genome_output.fasta w1_virus_mapped_sorted.bam | bcftools call -mv -Oz -o w1_variants.vcf.gz
bcftools index w1_variants.vcf.gz 
cd ..


echo "wuhan1 complete"









