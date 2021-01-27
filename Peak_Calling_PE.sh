#!/bin/bash

#SBATCH -J ChIP-peaks
#SBATCH -t 12:00:00
#SBATCH --mem-per-cpu=16GB



# save genome size

# EquCab3
#Using the input I found that for EquCab3:
genome=2409143234
genome_fraction=0.63


# Load software
module load bedtools/2.27.1 macs2

macs2=macs2
# Make a directory for peak-calls if it doesn't already exist.
mkdir -p Peak_Calls

source activate macs2


# narrow peaks

# Loop through all files (no subdirectories) in BWA_Output/Duplicates to do peak-calling
for file in `ls -p BWA_Output/Narrow/`
do echo "$file"
    root=`basename -s .duplicate-removed.bam	 $file`
    tissue=`echo "$file" | awk -F '[_.]' '{print $2,$3}' OFS=_`
#    tissue=`echo "$file" | awk -F '[_.]' '{print $2,$3,$4,$5}' OFS=_`
    if [ ! -f Peak_Calls/"$root"_Peaks.bed ]; then
        echo "$file"
        echo "$tissue"
        echo 'Macs2 peak-calling'
        $macs2 callpeak -t BWA_Output/Narrow/$file -c BWA_Output/Duplicates/Input_"$tissue".duplicate-removed.bam -f BAMPE -n Peak_Calls/$root -g $genome -q 0.01 -B --SPMR --keep-dup all --extsize 550

        mv Peak_Calls/"$root"_peaks.narrowPeak Peak_Calls/"$root"_Peaks.bed

        $macs2 bdgcmp -t Peak_Calls/"$root"_treat_pileup.bdg -c Peak_Calls/"$root"_control_lambda.bdg -o Peak_Calls/"$root"_FoldEnrichment.bdg -m FE -p 0.000001
        sort -k1,1 -k2,2n -o Peak_Calls/"$root"_FoldEnrichment.bdg Peak_Calls/"$root"_FoldEnrichment.bdg
        $macs2 bdgcmp -t Peak_Calls/"$root"_treat_pileup.bdg -c Peak_Calls/"$root"_control_lambda.bdg -o Peak_Calls/"$root"_LogLR.bdg -m logLR -p 0.000001
        sort -k1,1 -k2,2n -o Peak_Calls/"$root"_LogLR.bdg Peak_Calls/"$root"_LogLR.bdg



    fi
done


# medium peaks

# Loop through all files (no subdirectories) in BWA_Output/Duplicates to do peak-calling
for file in `ls -p BWA_Output/Medium/`
do echo "$file"
    root=`basename -s .duplicate-removed.bam	 $file`
    tissue=`echo "$file" | awk -F '[_.]' '{print $2,$3}' OFS=_`
#    tissue=`echo "$file" | awk -F '[_.]' '{print $2,$3,$4,$5}' OFS=_`
    if [ ! -f Peak_Calls/"$root"_Peaks.bed ]; then
        echo "$file"
        echo 'Macs2 peak-calling'
        $macs2 callpeak -t BWA_Output/Medium/$file -c BWA_Output/Duplicates/Input_"$tissue".duplicate-removed.bam -f BAMPE -n Peak_Calls/$root -g $genome -q 0.05 -B --SPMR --keep-dup all --extsize 550

        mv Peak_Calls/"$root"_peaks.narrowPeak Peak_Calls/"$root"_Peaks.bed

        $macs2 bdgcmp -t Peak_Calls/"$root"_treat_pileup.bdg -c Peak_Calls/"$root"_control_lambda.bdg -o Peak_Calls/"$root"_FoldEnrichment.bdg -m FE -p 0.000001
        sort -k1,1 -k2,2n -o Peak_Calls/"$root"_FoldEnrichment.bdg Peak_Calls/"$root"_FoldEnrichment.bdg
        $macs2 bdgcmp -t Peak_Calls/"$root"_treat_pileup.bdg -c Peak_Calls/"$root"_control_lambda.bdg -o Peak_Calls/"$root"_LogLR.bdg -m logLR -p 0.000001
        sort -k1,1 -k2,2n -o Peak_Calls/"$root"_LogLR.bdg Peak_Calls/"$root"_LogLR.bdg


    fi
done


# broad peaks

# Loop through all files (no subdirectories) in BWA_Output/Duplicates to do peak-calling
for file in `ls -p BWA_Output/Broad/`
do echo "$file"
    root=`basename -s .duplicate-removed.bam	 $file`
    tissue=`echo "$file" | awk -F '[_.]' '{print $2,$3}' OFS=_`
#    tissue=`echo "$file" | awk -F '[_.]' '{print $2,$3,$4,$5}' OFS=_`
    filter=`echo "$file" | awk -F '[_.]' '{print $5}' OFS=_`
    if [ ! -f Peak_Calls/"$root"_Peaks.bed ]; then
        if [ $filter = 'loose' ]; then echo $filter
            echo "$file"
            echo "$tissue"
            echo 'Macs2 peak-calling'
            $macs2 callpeak -t BWA_Output/Broad/$file -c BWA_Output/Duplicates/Input_"$tissue".loose.duplicate-removed.bam -f BAMPE -n Peak_Calls/$root -g $genome -q 0.05 --broad --broad-cutoff 0.1 -B --SPMR --keep-dup all --extsize 550

            mv Peak_Calls/"$root"_peaks.broadPeak Peak_Calls/"$root"_Peaks.bed

            $macs2 bdgcmp -t Peak_Calls/"$root"_treat_pileup.bdg -c Peak_Calls/"$root"_control_lambda.bdg -o Peak_Calls/"$root"_FoldEnrichment.bdg -m FE -p 0.000001
            sort -k1,1 -k2,2n -o Peak_Calls/"$root"_FoldEnrichment.bdg Peak_Calls/"$root"_FoldEnrichment.bdg
            $macs2 bdgcmp -t Peak_Calls/"$root"_treat_pileup.bdg -c Peak_Calls/"$root"_control_lambda.bdg -o Peak_Calls/"$root"_LogLR.bdg -m logLR -p 0.000001
            sort -k1,1 -k2,2n -o Peak_Calls/"$root"_LogLR.bdg Peak_Calls/"$root"_LogLR.bdg


        else
            echo "$file"
            echo 'Macs2 peak-calling'
            $macs2 callpeak -t BWA_Output/Broad/$file -c BWA_Output/Duplicates/Input_"$tissue".duplicate-removed.bam -f BAMPE -n Peak_Calls/$root -g $genome -q 0.05 --broad --broad-cutoff 0.1 -B --SPMR --keep-dup all --extsize 550


            mv Peak_Calls/"$root"_peaks.broadPeak Peak_Calls/"$root"_Peaks.bed

            $macs2 bdgcmp -t Peak_Calls/"$root"_treat_pileup.bdg -c Peak_Calls/"$root"_control_lambda.bdg -o Peak_Calls/"$root"_FoldEnrichment.bdg -m FE -p 0.000001
            sort -k1,1 -k2,2n -o Peak_Calls/"$root"_FoldEnrichment.bdg Peak_Calls/"$root"_FoldEnrichment.bdg
            $macs2 bdgcmp -t Peak_Calls/"$root"_treat_pileup.bdg -c Peak_Calls/"$root"_control_lambda.bdg -o Peak_Calls/"$root"_LogLR.bdg -m logLR -p 0.000001
            sort -k1,1 -k2,2n -o Peak_Calls/"$root"_LogLR.bdg Peak_Calls/"$root"_LogLR.bdg

        fi
    fi
done

source deactivate
