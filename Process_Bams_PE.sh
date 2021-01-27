#!/bin/sh

#SBATCH -J ChIP-TOI-Equine-FAANG
#SBATCH -t 1-00:00:00
#SBATCH --mem-per-cpu=32GB
#SBATCH -N 1

# Load the softwares needed
module load samtools/1.9 picardtools/2.7.1 bedtools/2.27.1

# Quality filtering value
quality=30

# Make a subdirectory in BWA_Output if it doesn't already exist.
mkdir -p Filter

# Loop through all files (no subdirectories) in BWA_Output to filter them for quality using samtools.
for file in `ls -p ./Align | grep -v '/'`
do echo "$file"
    root=`basename -s .aligned.bam $file`
    if [ ! -f Filter/$root.filtered.bam ]; then
         echo "$file"
         samtools view -h -F 1804 -q $quality Align/$file | samtools view -S -b - > Filter/$root.filtered.bam
    fi
done

# Make a subdirectory in BWA_Output if it doesn't already exist.
mkdir -p Sort

# Loop through all files (no subdirectories) in BWA_Output/Filter to sort them using samtools.
for file in `ls -p ./Filter |grep -v '/'`
do echo "$file"
    root=`basename -s .filtered.bam $file`
    if [ ! -f Sort/$root.sorted.bam ]; then
         echo "$file"
         samtools sort -@ 12 -o Sort/$root.sorted.bam Filter/$file
    fi
done

# Make a subdirectory in BWA_Output if it doesn't already exist.
mkdir -p Duplicates

# Loop through all files (no subdirectories) in BWA_Output/Sort to mark PCR and optical duplicates using picardtools.
for file in `ls -p ./Sort |grep -v '/'`
do echo "$file"
    root=`basename -s .sorted.bam $file`
    if [ ! -f Duplicates/$root.duplicate-marked.bam ]; then
         echo "$file"
         picard-tools MarkDuplicates INPUT=Sort/$file OUTPUT=Duplicates/$root.duplicate-marked.bam METRICS_FILE=Duplicates/$root.dup_metrics REMOVE_DUPLICATES=false ASSUME_SORTED=true VALIDATION_STRINGENCY=LENIENT
    fi
done

# Loop through all files (no subdirectories) in BWA_Output/Duplicates and remove the marked duplicates using samtools.
for file in `ls -p ./Duplicates/*duplicate-marked.bam`
do echo "$file"
    root=`basename -s .duplicate-marked.bam $file`
    if [ ! -f Duplicates/$root.duplicate-removed.bam ]; then
         echo "$file"
         samtools view -F 1024 -b $file > Duplicates/$root.duplicate-removed.bam
    fi
done


# create directories to split up the marks by topography
mkdir -p ./Medium ./Narrow ./Broad
cd Duplicates

# move the files for each mark into respective directory
mv H3K4me1*duplicate-removed.bam ../Medium
mv H3K4me3*duplicate-removed.bam ../Narrow
mv H3K27ac*duplicate-removed.bam ../Narrow
mv H3K27me3*duplicate-removed.bam ../Broad

