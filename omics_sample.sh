#!/bin/bash

# Script to generate sample sheets for genomic data
# Usage: ./create_samplesheet.sh <samples_directory> <output_samplesheet_path> <num_samples|all>

# Check if correct number of arguments provided
if [ "$#" -ne 3 ]; then
    echo "Error: Incorrect number of arguments"
    echo "Usage: $0 <samples_directory> <output_samplesheet_path> <num_samples|'all'>"
    echo "Example: $0 /data/humangen_kircherlab/Users/hassan/data/debug_fastqs ./samplesheets/output.csv all"
    echo "Example: $0 /data/humangen_kircherlab/Users/hassan/data/debug_fastqs ./samplesheets/output.csv 5"
    exit 1
fi

# Convert to absolute paths
SAMPLES_DIR=$(realpath "$1")
OUTPUT_FILE=$(realpath -m "$2")
NUM_SAMPLES="$3"

# Check if samples directory exists
if [ ! -d "$SAMPLES_DIR" ]; then
    echo "Error: Directory $SAMPLES_DIR does not exist"
    exit 1
fi

# Create output directory if it doesn't exist
OUTPUT_DIR=$(dirname "$OUTPUT_FILE")
mkdir -p "$OUTPUT_DIR"

# Write header to output file
echo "sample,lane,fastq_1,fastq_2,sex,phenotype,paternal_id,maternal_id,case_id" > "$OUTPUT_FILE"

# Counter for number of samples processed
count=0

# Loop through all directories in the samples directory
for sample_dir in "$SAMPLES_DIR"/*/ ; do
    # Remove trailing slash and get sample name
    sample_dir="${sample_dir%/}"
    sample_name=$(basename "$sample_dir")
    
    # Check if R1 and R2 files exist
    R1_FILE="${sample_dir}/${sample_name}.R1.fq.gz"
    R2_FILE="${sample_dir}/${sample_name}.R2.fq.gz"
    
    if [ -f "$R1_FILE" ] && [ -f "$R2_FILE" ]; then
        # Append sample information to output file
        echo "${sample_name},1,${R1_FILE},${R2_FILE},0,2,0,0,case_${sample_name}" >> "$OUTPUT_FILE"
        count=$((count + 1))
        
        # Check if we've reached the desired number of samples
        if [ "$NUM_SAMPLES" != "all" ] && [ "$count" -ge "$NUM_SAMPLES" ]; then
            echo "Processed $count samples (limit reached)"
            break
        fi
    else
        echo "Warning: Missing R1 or R2 file for $sample_name, skipping..."
    fi
done

echo "Sample sheet created successfully: $OUTPUT_FILE"
echo "Total samples processed: $count"