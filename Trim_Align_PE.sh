#!/bin/bash

#SBATCH -J ChIP-TOI-Equine-FAANG
#SBATCH -t 3-00:00:00
#SBATCH --mem-per-cpu=64GB


# Load the softwares needed
#module load trim-galore/0.4.0 bwa/0.7.9a samtools/1.9 python/2.7.6 cutadapt/1.8.3
module load bio bwa/0.7.9a samtools/1.9 seqtk/06172015

#save complete file path with name of the reference genome and annotation to file names
genome='/home/nbk/FAANG_Project/Genome/EquCab3.0_Genbank_Build.nowrap.fasta'

#1 Trim reads for quality and automatic adapter trimming
mkdir -p Trimmed_Reads

for file in `ls -p ./Raw_Reads/*_R1.fq.gz`
do
    echo ${file}
    root=`basename -s _R1.fq.gz $file`
    
    trim_galore $file Raw_Reads/${root}_R2.fq.gz  --paired -o Trimmed_Reads
#done


#2 Index reference genome if needed (only have to do this once as long as you don't delete the files)
#bwa index -p $genome -a bwtsw $genome


#3 Align reads to reference genome
mkdir -p BWA_Output/Align

for file in `ls -p Trimmed_Reads/*_R1_trimmed.fq.gz`
do echo ${file}
    root=`basename -s _R1_trimmed.fq.gz $file`
    if [ ! -f BWA_Output/Align/$root.aligned.bam ]; then
         echo ${file}

         bwa mem -M -t 3 -P $genome Trimmed_Reads/${file} Trimmed_Reads/${root}_R2_trimmed.fq.gz | samtools view -bS - > BWA_Output/Align/$root.aligned.bam
#-P for regular PE mode, -p for interleaved PE 

    fi
done


