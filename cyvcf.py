from cyvcf2 import VCF
import matplotlib.pyplot as plt
from matplotlib_venn import venn2
import numpy as np

def extract_maf(vcf_file):
    maf_dict = {}
    for record in VCF(vcf_file):
        if not record.ALT:
            continue
        chrom = record.CHROM
        pos = record.POS
        ref = record.REF
        alt = record.ALT[0]
        key = f"{chrom}:{pos}_{ref}>{alt}"

        # MAF estimation using GTs
        genotypes = record.genotypes  # list of [GT1, GT2, phased, ...]
        alleles = [gt[0:2] for gt in genotypes if None not in gt[0:2]]
        flat = [a for pair in alleles for a in pair]
        if len(flat) == 0:
            continue
        alt_count = flat.count(1)
        total_alleles = len(flat)
        maf = alt_count / total_alleles
        maf_dict[key] = maf
    return maf_dict

# Extract MAF data
maf1 = extract_maf("working_files/w1_variants.vcf")
maf2 = extract_maf("working_files/w2_variants.vcf")

# Shared and unique variants
keys1, keys2 = set(maf1), set(maf2)
shared = keys1 & keys2
unique1 = keys1 - keys2
unique2 = keys2 - keys1

# Plot Venn Diagram
plt.figure(figsize=(6,6))
venn2([keys1, keys2], set_labels=("w1", "w2"))
plt.title("Shared and Unique Variants")
plt.show()

# Plot MAF Scatter Plot
maf1_vals = [maf1[k] for k in shared]
maf2_vals = [maf2[k] for k in shared]

plt.figure(figsize=(8,6))
plt.scatter(maf1_vals, maf2_vals, alpha=0.6, edgecolor='k')
plt.plot([0,1], [0,1], 'r--', label='y = x')
plt.xlabel("w1 MAF")
plt.ylabel("w2 MAF")
plt.title("Minor Allele Frequency Comparison")
plt.legend()
plt.grid(True)
plt.show()

