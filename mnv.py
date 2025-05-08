from cyvcf2 import VCF
from pyfaidx import Fasta
import pandas as pd

# Load reference FASTA
ref = Fasta("viral_ref_genome_output.fasta")

def classify_polymorphism(ref, alt):
    if len(ref) == len(alt):
        if ref != alt:
            return "SNP (transition)" if (ref, alt) in [("A", "G"), ("G", "A"), ("C", "T"), ("T", "C")] else "SNP (transversion)"
        else:
            return "No change"
    elif len(ref) < len(alt):
        return "Insertion"
    elif len(ref) > len(alt):
        return "Deletion"
    return "Substitution"

def process_vcf(vcf_path, fasta, strain_label):
    vcf = VCF(vcf_path)
    rows = []

    for record in vcf:
        chrom = record.CHROM
        pos = record.POS
        try:
            ref_base = fasta[chrom][pos - 1].seq.upper()
        except KeyError:
            continue

        if record.REF != ref_base:
            continue

        for alt in record.ALT:
            poly_type = classify_polymorphism(record.REF, alt)
            change = f"{record.REF} → {alt}"
            freq = record.INFO.get('AF', None)
            if freq:
                freq = round(freq * 100, 2)
            cov = record.INFO.get('DP', None)
            pval = record.INFO.get('PV', None)  # Use actual key if different

            row = {
                "Strain": strain_label,
                "Region": "unknown",
                "Variant": record.REF,
                "Start Position": pos,
                "End Position": pos + len(record.REF) - 1,
                "Length": len(record.REF),
                "Change": change,
                "Coverage": cov,
                "Polymorphism Type": poly_type,
                "Variant Frequency (%)": freq,
                "P-value": pval
            }
            rows.append(row)

    return rows

# Process both VCF files
whu01_variants = process_vcf("w1_variants.vcf", ref, "Viral_ref_genome_output")
whu02_variants = process_vcf("w2_variants.vcf", ref, "viral_ref_genome_output")

# Combine and export
df = pd.DataFrame(whu01_variants + whu02_variants)
df.to_csv("variants_summary_table.csv", index=False)

# Print a preview
print(df.head())

