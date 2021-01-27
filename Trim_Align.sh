#!/bin/bash

#SBATCH -J ChIP-TOI-Equine-FAANG
#SBATCH -t 1-00:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem-per-cpu=8GB


# Load the softwares needed
#module load trim-galore/0.4.0 bwa/0.7.9a samtools/1.9 python/2.7.6 cutadapt/1.8.3
module load bio bwa/0.7.9a samtools/1.9

#save complete file path with name of the reference genome and annotation to file names
genome='/home/nbk/FAANG_Project/Genome/EquCab3.0_Genbank_Build.nowrap.fasta'

#1 Trim reads for quality and automatic adapter trimming
mkdir -p Trimmed_Reads

for file in `ls ./Raw_Reads`
do
    echo "$file"
   trim_galore Raw_Reads/$file -o Trimmed_Reads
done

#2 Index reference genome if needed (only have to do this once as long as you don't delete the files)
#bwa index -p $genome -a bwtsw $genome

#3 Align reads to reference genome
mkdir -p BWA_Output/Align

for file in `ls -p ./Trimmed_Reads |grep -v '/'`
do echo "$file"
    root=`basename -s _trimmed.fq.gz $file`
    if [ ! -f BWA_Output/Align/$root.aligned.bam ]; then
         echo "$file"
         bwa mem -M -t 3 $genome Trimmed_Reads/$file | samtools view -bS - > BWA_Output/Align/$root.aligned.bam
    fi
done
