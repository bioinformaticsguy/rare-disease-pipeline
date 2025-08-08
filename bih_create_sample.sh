#!/bin/bash

RAW_DATA_DIR="/data/humangen_kircherlab/hassan/sexdiversity"
OUTPUT="sexdiv_sample_sheet.csv"

# Header
echo "sample,lane,fastq_1,fastq_2,sex,phenotype,paternal_id,maternal_id,case_id" > "$OUTPUT"
echo "hugelymodelbat,1,/data/humangen_kircherlab/hassan/run_rare/rare-disease-pipeline/data/test37/1_171015_HHT5NDSXX_hugelymodelbat_XXXXXX_1.fastq.gz,/data/humangen_kircherlab/hassan/run_rare/rare-disease-pipeline/data/test37/1_171015_HHT5NDSXX_hugelymodelbat_XXXXXX_2.fastq.gz,1,2,0,0,justesthusky" >> "$OUTPUT"


# Loop over each batch folder
for folder in "$RAW_DATA_DIR"/*_A4842_FASTQ; do
    for fq1 in "$folder"/*_R1_001.fastq.gz; do
        fq2="${fq1/_R1_/_R2_}"
        
        if [[ -f "$fq1" && -f "$fq2" ]]; then
            # Extract lane (e.g. L004 → 4)
            lane=$(basename "$fq1" | sed -n 's/.*_L0*\([0-9]*\)_R1_001.fastq.gz/\1/p')
            
            # You can adjust sample/case naming if needed
            sample="A4842_DNA_42"
            case_id="case_${sample}"
            
            echo "${sample},${lane},${fq1},${fq2},0,2,0,0,${case_id}" >> "$OUTPUT"
        else
            echo "⚠️  Missing file for: $fq1 or $fq2" >&2
        fi
    done
done