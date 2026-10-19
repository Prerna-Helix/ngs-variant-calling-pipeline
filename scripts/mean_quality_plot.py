"""Plot mean Phred base quality per position for the first 100,000 reads of a FASTQ file.
Usage: python scripts/mean_quality_plot.py reads.fastq.gz output.png "Plot title"
"""
import sys, gzip
from Bio import SeqIO
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

fastq, out_png, title = sys.argv[1], sys.argv[2], sys.argv[3]
MAX_READS = 100000

sums, counts = [], []
with gzip.open(fastq, "rt") as fh:
    for i, rec in enumerate(SeqIO.parse(fh, "fastq")):
        q = rec.letter_annotations["phred_quality"]
        if len(sums) < len(q):
            extra = len(q) - len(sums)
            sums += [0] * extra
            counts += [0] * extra
        for pos, val in enumerate(q):
            sums[pos] += val
            counts[pos] += 1
        if i + 1 >= MAX_READS:
            break

mean_q = [s / c for s, c in zip(sums, counts)]
plt.figure(figsize=(8, 4.5))
plt.plot(range(1, len(mean_q) + 1), mean_q)
plt.axhline(30, linestyle="--", color="grey")
plt.ylim(0, 42)
plt.xlabel("Position in read (bp)")
plt.ylabel("Mean Phred quality")
plt.title(title)
plt.tight_layout()
plt.savefig(out_png, dpi=150)
print("Saved", out_png)
