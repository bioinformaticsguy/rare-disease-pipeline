#!/bin/bash

RAW_DATA_DIR="/data/humangen_kircherlab/Users/hassan/data/combined_fq/output"
OUTPUT="sample_sheet_30_demultiplexed.csv"

# Create header
echo "sample,lane,fastq_1,fastq_2,sex,phenotype,paternal_id,maternal_id,case_id" > "$OUTPUT"

# Loop through all sample folders (GS*, KiGS*, and KiGS-*)
for d in "$RAW_DATA_DIR"/GS* "$RAW_DATA_DIR"/KiGS*; do
    # Skip if not a directory
    if [[ ! -d "$d" ]]; then
        continue
    fi
    
    sample=$(basename "$d")
    echo "Processing: $sample"

    # Look for R1 files with pattern: {sample}.R1.fq.gz
    fq1="$d/${sample}.R1.fq.gz"
    fq2="$d/${sample}.R2.fq.gz"

    # Check both files exist
    if [[ -f "$fq1" && -f "$fq2" ]]; then
        # Default lane to 1 (no lane info in filename)
        lane="1"
        
        # Write to CSV
        echo "${sample},${lane},${fq1},${fq2},0,2,0,0,case_${sample}" >> "$OUTPUT"
        echo "  ✓ Added: $(basename "$fq1") and $(basename "$fq2")"
    else
        echo "  ⚠️  FASTQ files not found for $sample" >&2
        [[ ! -f "$fq1" ]] && echo "     Missing: $(basename "$fq1")" >&2
        [[ ! -f "$fq2" ]] && echo "     Missing: $(basename "$fq2")" >&2
    fi
done

echo ""
echo "✅ Sample sheet written to $OUTPUT"
echo "📊 Total entries: $(( $(wc -l < "$OUTPUT") - 1 ))"