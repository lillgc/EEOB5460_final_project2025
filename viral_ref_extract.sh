#!/bin/bash
#SBATCH --job-name=viral_ref_extract
#SBATCH --output=viral_extract.%j.out
#SBATCH --error=viral_extract.%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --time=01:00:00


module purge
module load blast-plus/2.13.0 perl/5.36.0 bzip2/1.0.8

# Save the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Step 1: Create and move into the database directory
DB_DIR="$SCRIPT_DIR/blast_db"
mkdir -p "$DB_DIR"
cd "$DB_DIR"

# Step 2: Download and decompress the database here
update_blastdb.pl --decompress ref_viruses_rep_genomes

# Step 3: Go back to the script's directory
cd "$SCRIPT_DIR"

# Step 4: Set BLASTDB to the database directory
export BLASTDB="$DB_DIR"

# Step 5: Extract all sequences to FASTA in the script's directory
blastdbcmd -db ref_viruses_rep_genomes -entry all -out viral_ref_genome_output.fasta
