#!/bin/bash


#SBATCH -J Comparing-Replicates
#SBATCH --time=1-00:00:00
#SBATCH --mem-per-cpu=8GB


module load bedtools/2.27.1 samtools

mkdir -p Combined_Peaks
cd Combined_Peaks

for file in `ls -p ../*_A.sicer.1.bed`
do echo "$file"
    root=`basename -s .bed $file`
    echo "$root"
    tissue=`echo "$root" | awk -F '[_.]' '{print $1,$2}' OFS=_`
    if [ ! -f "$tissue".CombinedA.bed ]; then
        echo "$tissue"
#        file2=../${tissue}_B.sicer.bed
file2=../*_B.sicer.bed 
       echo $file2
        bedtools intersect -a $file -b $file2 -u -header > "$tissue".CombinedA.bed

	bedtools intersect -a $file -b $file2 -u -header -wa > "$tissue".CombinedA.wa.bed

	bedtools intersect -a $file -b $file2 -u -header -wb > "$tissue".CombinedA.wb.bed

        awk '($8 < 0.1) {print}' "$tissue".CombinedA.bed > "$tissue"_CombinedA_1.bed
        awk '($8 < 0.1) {print}' "$tissue".CombinedA.wa.bed > "$tissue"_CombinedA_1.wa.bed
        awk '($8 < 0.1) {print}' "$tissue".CombinedA.wb.bed > "$tissue"_CombinedA_1.wb.bed

    fi
done

for file in `ls -p ../*_B.sicer.1.bed`
do echo "$file"
    root=`basename -s .bed $file`
    echo "$root"
    tissue=`echo "$root" | awk -F '[_.]' '{print $1,$2}' OFS=_`
    if [ ! -f "$tissue".CombinedB.bed ]; then
        echo "$tissue"
#        file2=../${tissue}_A.sicer.bed
file2=../*_A.sicer.bed
        echo $file2
        bedtools intersect -a $file -b $file2 -u -header > "$tissue".CombinedB.bed

        bedtools intersect -a $file -b $file2 -u -header -wa > "$tissue".CombinedB.wa.bed

        bedtools intersect -a $file -b $file2 -u -header -wb > "$tissue".CombinedB.wb.bed

        awk '$8 < 0.1' "$tissue".CombinedB.bed > "$tissue"_CombinedB_1.bed
        awk '$8 < 0.1' "$tissue".CombinedB.wa.bed > "$tissue"_CombinedB_1.wa.bed
        awk '$8 < 0.1' "$tissue".CombinedB.wb.bed > "$tissue"_CombinedB_1.wb.bed

    fi
done


for file in `ls -p *CombinedA_1.bed`
do echo ${file}
    tissue=`echo ${file} | awk -F '[_.]' '{print $1,$2}' OFS=_`
    if [ ! -f ${tissue}.Combined_1.bed ]; then
        echo ${tissue}
#        file2=${tissue}_CombinedB_1.bed
file2=*_CombinedB_1.bed
        echo $file
        cat ${file} ${file2} | sort -k1,1 -k2,2n - > temp.bed
        bedtools merge -i temp.bed -header > ${tissue}_Combined_1.bed
    fi
done

