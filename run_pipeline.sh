#!/usr/bin/env bash
# NGS variant-calling pipeline: QC -> trim -> align -> call -> filter
# Run from the project folder:  bash run_pipeline.sh
set -euo pipefail

SAMPLE=s1
REF=ref/ecoli_MG1655.fa
R1=data/ERR022075_1.fastq.gz
R2=data/ERR022075_2.fastq.gz
THREADS=4

mkdir -p qc_raw qc_trimmed align variants

echo "[1/6] QC of raw reads"
fastqc --outdir qc_raw "$R1" "$R2"
multiqc -f qc_raw -o qc_raw

echo "[2/6] Trimming with fastp"
fastp -i "$R1" -I "$R2" -o data/trim_1.fastq.gz -O data/trim_2.fastq.gz \
      --detect_adapter_for_pe -q 20 -l 36 -w "$THREADS" \
      -h qc_trimmed/fastp.html -j qc_trimmed/fastp.json

echo "[3/6] QC of trimmed reads"
fastqc --outdir qc_trimmed data/trim_1.fastq.gz data/trim_2.fastq.gz
multiqc -f qc_trimmed -o qc_trimmed

echo "[4/6] Index reference and align"
bwa index "$REF"
samtools faidx "$REF"
bwa mem -t "$THREADS" -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tPL:ILLUMINA\tLB:lib1" \
        "$REF" data/trim_1.fastq.gz data/trim_2.fastq.gz \
  | samtools sort -@ "$THREADS" -o align/${SAMPLE}.sorted.bam -
samtools index align/${SAMPLE}.sorted.bam
samtools flagstat align/${SAMPLE}.sorted.bam > align/${SAMPLE}.flagstat.txt

echo "[5/6] Variant calling (haploid bacterium)"
bcftools mpileup -Ou -a FORMAT/AD,FORMAT/DP -f "$REF" align/${SAMPLE}.sorted.bam \
  | bcftools call -mv --ploidy 1 -Oz -o variants/${SAMPLE}.raw.vcf.gz
bcftools index -f variants/${SAMPLE}.raw.vcf.gz

echo "[6/6] Filtering variants (QUAL>=30, DP>=10)"
bcftools view -i 'QUAL>=30 && INFO/DP>=10' variants/${SAMPLE}.raw.vcf.gz \
  -Oz -o variants/${SAMPLE}.filtered.vcf.gz
bcftools index -f variants/${SAMPLE}.filtered.vcf.gz

echo "Done. Raw variants: $(zcat variants/${SAMPLE}.raw.vcf.gz | grep -vc '^#' || true)"
echo "Filtered variants: $(zcat variants/${SAMPLE}.filtered.vcf.gz | grep -vc '^#' || true)"
