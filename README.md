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
- [ ] Public dataset downloaded (accession listed below)
- [ ] Reference genome downloaded and indexed
- [ ] Raw read QC with FastQC and MultiQC, results interpreted
- [ ] Trimming with fastp, before/after QC compared
- [ ] Alignment with BWA-MEM, sorted and indexed BAM
- [ ] Alignment QC (mapping rate, duplicates, depth)
- [ ] Variant calling and filtering with bcftools
- [ ] Pipeline combined into one bash script
- [ ] Python script plotting mean base quality per position
- [ ] Short cloud exercise (Google Cloud Shell or AWS CloudShell) documented
- [ ] Results and limitations written up in this README

## Data
- **Reads:** NCBI SRA run `<ACCESSION TO BE ADDED>` (Illumina, paired-end). Only a subset of reads is used for speed.
- **Reference:** NCBI nucleotide record `NC_000913.3` (E. coli K-12 MG1655), if the chosen run matches that strain.
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
_To be added after the analysis is complete:_
- Raw read QC findings and what was trimmed
- Mapping rate and mean depth
- Number of raw and filtered variants, filters used and why

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
