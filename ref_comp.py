from cyvcf2 import VCF
from pyfaidx import Fasta
import matplotlib.pyplot as plt
from matplotlib_venn import venn2

# Load reference FASTA
ref = Fasta("viral_ref_genome_output.fasta")

def split_variants(vcf_file, ref_fasta):
    vcf = VCF(vcf_file)
    nonref_variants = set()
    ref_variants = set()

    for record in vcf:
        chrom = record.CHROM
        pos = record.POS  # 1-based
        try:
            ref_base = ref_fasta[chrom][pos - 1].seq.upper()
        except KeyError:
            continue  # Skip unknown chromosomes

        if record.REF != ref_base:
            continue  # Skip misaligned records

        for alt in record.ALT:
            variant = f"{chrom}:{pos}_{record.REF}>{alt}"
            if alt == ref_base:
                ref_variants.add(variant)
            else:
                nonref_variants.add(variant)

    return nonref_variants, ref_variants

# File paths
vcf1 = "w1_variants.vcf"
vcf2 = "w2_variants.vcf"

# Get sets of variants for each VCF
v1_nonref, v1_ref = split_variants(vcf1, ref)
v2_nonref, v2_ref = split_variants(vcf2, ref)

# Plotting both Venn diagrams side-by-side
plt.figure(figsize=(12, 6))

# Patient 1
plt.subplot(1, 2, 1)
venn2([v1_nonref, v1_ref], set_labels=("Non-Ref Variants", "Ref-Matching Variants"))
plt.title("Patient 1: VCF vs Reference")

# Patient 2
plt.subplot(1, 2, 2)
venn2([v2_nonref, v2_ref], set_labels=("Non-Ref Variants", "Ref-Matching Variants"))
plt.title("Patient 2: VCF vs Reference")

plt.tight_layout()
plt.show()

