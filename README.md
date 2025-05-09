# EEOB5460_final_project2025

##Paper Title:
##RNA based mNGS approach identifies a novel human coronavirus from two individual pneumonia cases in 2019 Wuhan outbreak

Project group members:
Lillian Chiang, Swathi Nadendla, Shirin Parvin and Zheyuan Zhang
introduces the original paper, explains the technical details of your replication of analyses and summarizes your replication of the original results.

The paper we chose is title as "RNA based mNGS approach identifies a novel human coronavirus from two individual pneumonia cases in 2019 Wuhan outbreak
" and can be downloaded from https://www.tandfonline.com/doi/full/10.1080/22221751.2020.1725399?scroll=top&needAccess=true#abstract. As mentioned in the top README, have additionally uploaded the PDF copy of the article in our Github repo.

The paper was choosen due to its clinical relevance and impact. It lacked a GitHub repository and any kind of documentation except the published paper and deposited sequences on the NCBI Sequence Read Archive and European Nucleotide Archive.
The study investigates two patients from Wuhan, China, in early 2020, who report having respiratory symptoms similar to SARS-CoV but have negative results from routine clinical testing of respiratory pathogen. Their main objective was to rapidly identify the causative pathogen since its etiology was unknown at that time. For this they utilised RNA-based metagenomic Next Generation Sequencing (mNGS) on bronchoalveolar lavage fluid (BALF) samples from the two patients, to identify the pathogen and after performing phylogenetic analysis, concluded that the pathogen is a novel strain of the coronavirus and termed it as 2019-nCoV.

Our attempts
####----------------
We list out the order in which the scripts in the Scripts folder should be run to replicate our analysis.

Prep step:
We start off by running the script file_download.sh which downloads the raw sequencing data of the patients from the European Nucleotide Database (ENA) using the BioProject number (PRJNA601736) mentioned in the paper and saves it under patients_raw_fastq folder.
We run 'viral_ref_extract.sh` to download the reference viral database files and convert it into a fasta file for ease of use later.
Starting of analysis:
This is where our analysis starts along with the creation of the micromamba environment. All the scripts are commented to illustrate what is happening at each chunk.The outputs generated from each of the code chunk will be saved in the working_files folder unless explicitly mentioned otherwise.

inspect_genomes.sh performs the following steps:
a. sets up the micromamba environment,
b. performs quality control on the raw fastq files
c. performs a blastn (we term it Blast search 1 or Blast 1 or b1) search on the cleaned raw fastq files generated in the step b above.

inspect_genomes_pt2.sh performs the following step:
a. Generates contigs and assembles the viral genome from the cleaned fastq files using Megahit

inspect_genomes_pt3.sh performs the following step:
a. performs a blastn search using the assembled genome
b. extracts the top contig using our helper function extract_top_virus_contig() c. maps and generated a consensus sequence using bowtie2, samtools and bcftools forwuhan1` sample

inspect_genomes_pt4.sh performs the following step:
a. maps and generated a consensus sequence using bowtie2, samtools and bcftools for wuhan2 sample
We separated the mapping and consensus sequence generation of the two samples into two scripts for ease of use and less usage of memory.
b. map and generate the bacterial taxonomic profiling as well. Here we generate two report files wuhan1_kraken.html and wuhan2_kraken.html which will be stored in the output_files directory.

tax_step_prep.sh performs the following step:
a. downloading databases, extracting the accession numbers of successful blast hits from the assembled viral genome, and converting the accession numbers to taxonomic ID.
Since we ran the blastn (we term it Blast search 2 or Blast 2 or b2)search with the cleaned fastq files (before assembling the genome), we performed the preparation step for this blastn results as well.

inspect_genomes_pt5.sh performs the following step:
a. downloading databases, extracting the accession numbers of successful blast hits from the assembled viral genome, and converting the accession numbers to taxonomic ID.

b1_taxonomy_classification_step.ipynbperforms the following step:
a. performs the taxonomic classification using the Taxonomic ID generated for Blast search 1 (cleaned fastq files) using the output from tax_step_prep.sh

b2_taxonomy_classification_step.ipynbperforms the following step:
a. performs the taxonomic classification using the Taxonomic ID generated for Blast search 2 (assembled viral genome) using the output from inspect_genomes_pt5.sh

EEOB5460_blastn.Rmdperforms the following step:
a. extract the top 5 taxonomic matches from the taxonomic classification step of Blast search 1 (cleaned fastq files), using output of b1_taxonomy_classification_step.ipynb
b. plots them into bar charts for easy visualisation.

EEOB5460_mg_blastn.Rmdperforms the following step:
a. extract the top 5 taxonomic matches from the taxonomic classification step of Blast search 2 (assembled viral genome), using output of b2_taxonomy_classification_step.ipynb
b. plots them into bar charts for easy visualisation.

inspect_genomes_pt6.sh performs the following step:
a. download the reference genomes needed to create the phylogenetic tree.
b. align the assembled genome with the reference genome
c. create the phylogenetic tree using phyml.
We used the files generated by this script, copied the Newick output and plotted the phylogenetic tree using https://etetoolkit.org/treeview/

Creating phylogenetic tree using approach 2:
a. run_phylo_pipeline.sh pulls the phylogenetic information generated and creates tree files in IQtree2 since we wanted to try two different methods to generate the phylogenetic tree
b. tree_ploter.ipynb plots the phylogenetic tree using biopython.

Creation of the SNP tables:
a. cyvcf.py is the python script for the variants
b. ref-comp.py is the plot generrated for common shared variants.
c. mnv.py is the script for generating SNP table that we included.
