#!/bin/bash

#SBATCH -J ChIP-peaks
#SBATCH -t 2-0
#SBATCH -N 1
#SBATCH -n 32


#Created 11192018



# save genome size

# EquCab3
#Using the input I found that for EquCab3:
genome=2409143234
genome_fraction=0.63

# Load software
module load bedtools/2.27.1 SICERpy pysam/0.9.0 numpy/1.11.1 scipy/0.18.0 
#python/2.7.14
# Make a directory for peak-calls if it doesn't already exist.
mkdir -p Sicer_Peak_Calls


# broad peaks

# Loop through all files (no subdirectories) in BWA_Output/Duplicates to do peak-calling
for file in `ls -p BWA_Output/Broad/`
do echo "$file"
    root=`basename -s .duplicate-removed.bam $file`
    tissue=`echo "$file" | awk -F '[_.]' '{print $2,$3}' OFS=_`
    if [ ! -f Sicer_Peak_Calls/"$root".sicer.bed ]; then
        echo "$file"
        echo "$tissue"
        echo 'Sicer peak-calling'
        #use awk to filter for FDR
        SICER.py -t BWA_Output/Broad/$file -c BWA_Output/Duplicates/Input_"$tissue".duplicate-removed.bam -g 4 -w 200 -fs 200 -gs $genome_fraction > Sicer_Peak_Calls/$root.sicer.bed

        awk '($8 < 0.1) {print}' Sicer_Peak_Calls/$root.sicer.bed > Sicer_Peak_Calls/$root.sicer.1.bed


    fi
done
