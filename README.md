# ngs-variant-calling-pipeline
In-progress learning project: QC to variant calling (FastQC, fastp, BWA, samtools, bcftools) on public Illumina data
# NGS Variant-Calling Pipeline

A learning project that builds a reproducible short-read variant-calling workflow on **public** Illumina sequencing data: quality control, trimming, alignment, variant calling and filtering.

> **Status: in progress. Target completion: 21 October 2026.**
> The checklist below is updated as each step is finished. Results and scripts will be added as they are completed.

## Why this project
I am an M.Sc. Botany graduate (University of Madras) with a wet-lab background in microbiology and bacteriophage research. I am building hands-on bioinformatics skills, and this project is my first end-to-end NGS analysis. It follows the same logical steps used in clinical and research genomics pipelines, on a small bacterial dataset so that every step can be run and understood quickly.

## Workflow

```
FASTQ (raw reads)
   -> FastQC / MultiQC     read quality control
   -> fastp                adapter and quality trimming
   -> BWA-MEM              alignment to reference genome
   -> samtools             sort, index, mark duplicates, alignment statistics
   -> bcftools             variant calling, normalisation and filtering
   -> VCF                  filtered variants
```

## Progress checklist
- [x] Environment set up (conda, tool versions recorded)
- [x] Public dataset downloaded (accession listed below)
- [x] Reference genome downloaded and indexed
- [x] Raw read QC with FastQC and MultiQC, results interpreted
- [x] Trimming with fastp, before/after QC compared
- [x] Alignment with BWA-MEM, sorted and indexed BAM
- [x] Alignment QC (mapping rate, duplicates, depth)
- [x] Variant calling and filtering with bcftools
- [ ] Pipeline combined into one bash script
- [ ] Python script plotting mean base quality per position
- [ ] Short cloud exercise (Google Cloud Shell or AWS CloudShell) documented
- [ ] Results and limitations written up in this README

## Data
- **Reads:** NCBI SRA run `ERR022075` (Illumina, paired-end). Only a subset of reads is used for speed.
- **Reference:** NCBI nucleotide record `NC_000913.3` (E. coli K-12 MG1655), if the chosen run matches that strain.
- “Reference: NC_000913.3 (4,641,652 bp), indexed with BWA 0.7.19 and samtools 1.24.”
- The reference and reads match, since the 99.99% mapping rate shows it.
- Only publicly available data is used. No patient or personal data is involved. Raw data files are not stored in this repository.

## Tools and versions
Installed with conda (conda-forge and bioconda) in an environment named `ngs`.

| Tool | Version |
|---|---|
| FastQC | 0.13.0 |
| MultiQC | 1.35 |
| fastp | 1.4.0 |
| BWA | 0.7.19 |
| samtools | 1.24 |
| bcftools | 1.24 |
| sra-tools (fastq-dump) | 3.4.1 |

Environment: Ubuntu on WSL 2 (Windows).

## Repository structure (planned)
```
ngs-variant-calling-pipeline/
├── README.md
├── environment.yml        # conda environment with tool versions
├── run_pipeline.sh        # full workflow script
├── scripts/
│   └── mean_quality_plot.py
├── results/
│   ├── qc/                # selected QC reports and plots
│   └── variants/          # small filtered VCF
└── docs/
    └── notes.md           # step-by-step notes and decisions
```

## How to run
Instructions will be added when the pipeline is finished. The plan is:
```
conda env create -f environment.yml
conda activate ngs
bash run_pipeline.sh
```

## Results
- Raw read QC findings and what was trimmed
  ### Raw read QC (FastQC 0.13.0, MultiQC 1.35)
- 500,000 read pairs from ERR022075 (R1: 100 bp, R2: 102 bp), Sanger/Illumina 1.9 quality encoding.
- Per-base quality is high (mostly Q36-Q40) and declines slightly toward the 3' end.
- No adapter contamination detected and no duplication problem.
- Read 2 fails per-base quality only because of poor quality at the first base; ~0.24% of R2 reads are entirely N, which also causes the GC-content and overrepresented-sequence flags.
- Plan: trim with fastp (remove low-quality ends and N reads), then re-run FastQC to compare.
  ### Trimming (fastp 1.4.0; -q 20 -l 36, adapter detection on)
- 500,000 read pairs -> 477,891 pairs retained (4.4% removed: 43,908 low quality, 298 too many N, 12 too short).
- No adapter contamination detected; 830 reads had adapter bases trimmed.
- Bases at Q30 or better rose from 90.5% to 92.7%.
- Re-run FastQC: Read 2 per-base quality and overrepresented-sequence flags now pass. Remaining warnings (GC content, length distribution) are expected for single-genome bacterial data after trimming.
- Duplication rate: 0.76%.
QC reports are in results/qc/
- Mapping rate and mean depth
  ### Alignment (BWA-MEM 0.7.19, samtools 1.24)
- 477,891 trimmed read pairs aligned to NC_000913.3 (E. coli K-12 MG1655).
- 99.99% of reads mapped; 99.14% properly paired; 27 singletons.
- Mean depth: 20.8x across the 4,641,652 bp genome.
- This confirms the dataset matches the reference strain.
- Number of raw and filtered variants, filters used and why
  ### Variant calling and filtering (bcftools 1.24, haploid, --ploidy 1)
- bcftools mpileup + call on the sorted BAM: 22 raw variants.
- Filter: QUAL >= 30 and DP >= 10 (chosen for ~21x mean depth) -> 1 variant retained.
- 21 removed calls were low-confidence (QUAL 3-11, mostly supported by a single read), consistent with sequencing errors.
- Retained variant: NC_000913.3:4296380 AC>ACGC (2-bp insertion), QUAL 228, depth 18, 17 of 18 reads support the alternate allele, seen on both strands.
- Not interpreted biologically; no gene annotation was done for this bacterial dataset.

## Limitations (known in advance)
- Small bacterial dataset used for learning; it is haploid, so human diploid genotypes are not shown here.
- No clinical interpretation or variant classification is performed on this dataset.
- Filter thresholds are chosen for this dataset and would need validation for any diagnostic use.

## Next steps
- Repeat the workflow on a small public human exome or region subset.
- Add variant annotation (SnpEff or Ensembl VEP) and review variants in ClinVar and gnomAD.
- Explore a workflow manager (Nextflow or Snakemake).

## About
Prerna T D | M.Sc. Botany, University of Madras | Chennai, India
Related repository: [Linux-notes](https://github.com/Prerna-Helix/Linux-notes)
