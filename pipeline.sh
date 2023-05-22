#!/bin/bash


# Checking input directory for the presence of FASTQ files
if ls ./*.fastq 1> /dev/null; then
    echo "FASTQ files present in current directory - continuing with pipeline"
    ls ./*.fastq
    echo ""
else
    echo "ERROR: No FASTQ files - aborting"
    exit 1
fi

# If FASTQ are gzipped, extract them

# Convert and merge all FASTQ files into FASTA
echo "Converting and merging all FASTQ files into a single FASTA file"
for file in *.fastq; do
    awk 'NR%4==1{printf ">%s\n",substr($0,2)}NR%4==2{print}' "$file";
done > "merged.fasta"
echo ""

# Check for reference sequence (as FASTA)
echo "Now checking for reference sequence..."
if ls ../reference/*.fasta 1> /dev/null; then
    echo "...reference FASTA file found!"
else
    echo "ERROR: No reference file found - aborting"
    exit 1
fi

# Index reference sequence
bwa index ../reference/*.fasta

# Align FASTA data to reference
bwa mem -x ont2d ../reference/reference.fasta ./merged.fasta > aln.sam

# Perform conversions: SAM/BAM/etc
samtools view -S -b aln.sam -o aln.bam
samtools sort aln.bam -o aln-sorted.bam
samtools index aln-sorted.bam
samtools view aln-sorted.bam -o aln-sorted.sam

exit 0
