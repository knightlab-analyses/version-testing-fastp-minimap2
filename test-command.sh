#!/bin/bash

filename1=$1
filename2=$2
db_path=$3
db_name=$4
final_output=$5

NPROCS=12

filename1_short="test_res_R1"
filename2_short="test_res_R2"

fastp --adapter_sequence GATCGGAAGAGCACACGTCTGAACTCCAGTCAC --adapter_sequence_r2 GATCGGAAGAGCGTCGTGTAGGGAAAGGAGTGT -l 25 -i $filename1 -I $filename2 -w $NPROCS --stdout | minimap2 --split-prefix db-temp -ax sr -t $NPROCS $db_path/$db_name.mmi - -a | samtools fastq -@ $NPROCS -f 12 -F 256 -1 $final_output/${filename1_short}.trimmed.fastq.gz -2 $final_output/${filename2_short}.trimmed.fastq.gz
