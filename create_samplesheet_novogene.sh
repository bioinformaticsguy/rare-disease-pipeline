#!/bin/bash

RAW_DATA_DIR="/data/humangen_kircherlab/hassan/novogene/01.RawData"
OUTPUT="sample_sheet_30.csv"

# Add test sample
echo "sample,lane,fastq_1,fastq_2,sex,phenotype,paternal_id,maternal_id,case_id" > "$OUTPUT"
echo "hugelymodelbat,1,/data/humangen_kircherlab/hassan/run_rare/rare-disease-pipeline/data/test37/1_171015_HHT5NDSXX_hugelymodelbat_XXXXXX_1.fastq.gz,/data/humangen_kircherlab/hassan/run_rare/rare-disease-pipeline/data/test37/1_171015_HHT5NDSXX_hugelymodelbat_XXXXXX_2.fastq.gz,1,2,0,0,justesthusky" >> "$OUTPUT"

# Loop through GS* and KiGS* sample folders
for d in "$RAW_DATA_DIR"/GS* "$RAW_DATA_DIR"/KiGS*; do
    sample=$(basename "$d")

    # Find all *_1.fq.gz files (R1 reads)
    for fq1 in "$d"/*_1.fq.gz; do
        # Derive matching R2 file
        fq2="${fq1/_1.fq.gz/_2.fq.gz}"

        # Check both files exist
        if [[ -f "$fq1" && -f "$fq2" ]]; then
            # Extract lane (e.g., L5) from filename
            lane=$(basename "$fq1" | sed -n 's/.*_L\([0-9]*\)_1.fq.gz/\1/p')
            
            # Write to CSV: sample,lane,fastq_1,fastq_2,sex,phenotype,paternal_id,maternal_id,case_id
            echo "${sample},${lane},${fq1},${fq2},0,2,0,0,case_${sample}" >> "$OUTPUT"
        else
            echo "⚠️  Missing file for sample: $sample, skipping $fq1 or $fq2" >&2
        fi
    done
done

echo "✅ Sample sheet written to $OUTPUT"

