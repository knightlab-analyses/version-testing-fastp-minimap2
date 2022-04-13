#!/bin/bash

filename1=$1
filename2=$2
db_path=$3
db_name_one=$4
db_name_two=$5
db_name_three=$6
final_output=$7
NPROCS=12

filename1_short="test_res_R1"
filename2_short="test_res_R2"
filename_short="test_res"

# run trimming and two DB minimap2
fastp --adapter_sequence GATCGGAAGAGCACACGTCTGAACTCCAGTCAC --adapter_sequence_r2 GATCGGAAGAGCGTCGTGTAGGGAAAGGAGTGT -l 25 -i $filename1 -I $filename2 -w $NPROCS --stdout | minimap2 -ax sr -t $NPROCS $db_path/$db_name_one.mmi - -a | samtools fastq -@ $NPROCS -f 12 -F 256 | minimap2 -ax sr -t $NPROCS $db_path/$db_name_two.mmi - -a | samtools fastq -@ $NPROCS -f 12 -F 256 -1 $final_output/${filename1_short}.trimmed.fastq.gz -2 $final_output/${filename2_short}.trimmed.fastq.gz
# run kraken2
kraken2 --threads $NPROCS --db $db_path/$db_name_three --report $final_output/$filename_short-kraken2-report.txt --unclassified-out $final_output/$filename_short.kraken.trimmed.#.fastq --paired $final_output/${filename1_short}.trimmed.fastq.gz $final_output/${filename2_short}.trimmed.fastq.gz
# remove intermediate files
rm $final_output/${filename1_short}.trimmed.fastq.gz
rm $final_output/${filename2_short}.trimmed.fastq.gz
# gzip kraken output into expected files names
gzip -c $final_output/$filename_short.kraken.trimmed._1.fastq > $final_output/${filename1_short}.trimmed.fastq.gz
gzip -c $final_output/$filename_short.kraken.trimmed._2.fastq > $final_output/${filename2_short}.trimmed.fastq.gz
# remove the uncompressed kraken output
rm $final_output/$filename_short.kraken.trimmed._1.fastq
rm $final_output/$filename_short.kraken.trimmed._2.fastq
