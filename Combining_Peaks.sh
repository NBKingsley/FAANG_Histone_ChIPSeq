#!/bin/bash

#SBATCH -J ChIP-TOI-Equine-FAANG
#SBATCH --time=1-00:00:00
#SBATCH --mem-per-cpu=8GB

module load bedtools/2.27.1

#Created 11192018

# Loop through bed files to combine peaks between biological replicates
for file in `ls -p Peak_Calls/*_Peaks.bed`
do echo "$file"
    root=`basename -s _Peaks.bed $file`
    filter=`echo "$file" | awk -F '[_.]' '{print $5}' OFS=_`
    tissue=`echo "$file" | awk -F '[_.]' '{print $1,$2,$3}' OFS=_`
    replicate=`echo "$file" | awk -F '[_.]' '{print $4}'`
    mark=`echo "$file" | awk -F '[_.]' '{print $2}'`
    if [ ! -f Peak_Calls/"$root"_Peaks_Validated_by_Replicate.bed ]; then
        echo "$file"
        echo "$root"
        echo "$filter"
        echo "$tissue"
        echo "$replicate"
        echo "$mark"
        echo 'combining Macs peaks part 1'
        if [ $replicate = 'Combined' ]; then echo "$file is already created"
        else
            if [ $filter = 'loose' ]; then echo $filter
                if [ $replicate = 'A' ]; then bedtools intersect -a $file -b "$tissue"_B.loose_FoldEnrichment.bdg -wo -sorted > Peak_Calls/"$root"_Peak_Regions_With_Replicate_FE.txt; else bedtools intersect -a $file -b "$tissue"_A.loose_FoldEnrichment.bdg -wo -sorted > Peak_Calls/"$root"_Peak_Regions_With_Replicate_FE.txt; fi
            else
                if [ $replicate = 'A' ]; then bedtools intersect -a $file -b "$tissue"_B_FoldEnrichment.bdg -wo -sorted > Peak_Calls/"$root"_Peak_Regions_With_Replicate_FE.txt; else bedtools intersect -a $file -b "$tissue"_A_FoldEnrichment.bdg -wo -sorted > Peak_Calls/"$root"_Peak_Regions_With_Replicate_FE.txt; fi
            fi
##There is a validate peaks script that is in betweeen these steps.
    #    python ../Scripts/Validate_Peaks.py Peak_Calls/"$root"_Peak_Regions_With_Replicate_FE.txt > Peak_Calls/"$root"_Peaks_Validated_by_Replicate.bed

            if [ $mark = 'Calls/H3K27me3' ]; then
                 echo "broad method"
                 python ../Scripts/Validate_Peaks_Broad.py Peak_Calls/"$root"_Peak_Regions_With_Replicate_FE.txt > Peak_Calls/"$root"_Peaks_Validated_by_Replicate.bed
            else
                 echo "narrow method"
                 python ../Scripts/Validate_Peaks.py Peak_Calls/"$root"_Peak_Regions_With_Replicate_FE.txt > Peak_Calls/"$root"_Peaks_Validated_by_Replicate.bed
            fi
        fi
    fi
done

for file in `ls -p Peak_Calls/*A_Peaks_Validated_by_Replicate.bed`
do echo "$file"
    root=`basename -s _Peaks_Validated_by_Replicate.bed $file`
    tissue=`echo "$file" | awk -F '[_.]' '{print $1,$2,$3}' OFS=_`
    if [ ! -f "$tissue"_Combined_Peaks.bed ]; then
        echo "$file"
        echo 'combining Macs peaks part 2'

        cat Peak_Calls/"$root"_Peaks_Validated_by_Replicate.bed "$tissue"_B_Peaks_Validated_by_Replicate.bed | sort -k1,1 -k2,2n > "$tissue"_temp && if [ -s "$tissue"_temp ]; then bedtools merge -i "$tissue"_temp -c 4,5 -o max > "$tissue"_Combined_Peaks.bed; else touch "$tissue"_Combined_Peaks.bed; fi && rm "$tissue"_temp

    fi
done


for file in `ls -p Peak_Calls/*A.loose_Peaks_Validated_by_Replicate.bed`
do echo "$file"
    root=`basename -s _Peaks_Validated_by_Replicate.bed $file`
    tissue=`echo "$file" | awk -F '[_.]' '{print $1,$2,$3}' OFS=_`
    if [ ! -f "$tissue".loose_Combined_Peaks.bed ]; then
        echo "$file"
        echo 'combining Macs peaks part 2'

        cat Peak_Calls/"$root"_Peaks_Validated_by_Replicate.bed "$tissue"_B.loose_Peaks_Validated_by_Replicate.bed | sort -k1,1 -k2,2n > "$tissue"_temp && if [ -s "$tissue"_temp ]; then bedtools merge -i "$tissue"_temp -c 4,5 -o max > "$tissue".loose_Combined_Peaks.bed; else touch "$tissue".loose_Combined_Peaks.bed; fi && rm "$tissue"_temp

    fi
done

