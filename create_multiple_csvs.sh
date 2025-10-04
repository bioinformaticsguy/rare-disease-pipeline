#!/bin/bash

# Script to generate individual sample CSV files from a list of sample paths
# Usage: ./generate_sample_csvs.sh <sample_list_file> <output_csv_directory>

# Check if correct number of arguments provided
if [ "$#" -ne 2 ]; then
    echo "Error: Incorrect number of arguments"
    echo "Usage: $0 <sample_list_file> <output_csv_directory>"
    echo "Example: $0 sample_lists/nadine_samples.txt samplesheets/individual"
    exit 1
fi

SAMPLE_LIST="$1"
OUTPUT_DIR="$2"

# Check if sample list file exists
if [ ! -f "$SAMPLE_LIST" ]; then
    echo "Error: Sample list file not found: $SAMPLE_LIST"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "Processing samples from: $SAMPLE_LIST"
echo "Output directory: $OUTPUT_DIR"
echo "----------------------------------------"

# Counter for samples processed
count=0

# Read each path from the sample list file
while IFS= read -r sample_path || [ -n "$sample_path" ]; do
    # Skip empty lines and comments
    [[ -z "$sample_path" || "$sample_path" =~ ^#.*$ ]] && continue
    
    # Remove any trailing whitespace and slashes
    sample_path=$(echo "$sample_path" | xargs | sed 's:/*$::')
    
    # Check if sample directory exists
    if [ ! -d "$sample_path" ]; then
        echo "Warning: Sample directory not found: $sample_path, skipping..."
        continue
    fi
    
    # Get sample name from path
    sample_name=$(basename "$sample_path")
    
    echo "Processing: $sample_name from $sample_path"
    
    # Create CSV file for this sample
    CSV_FILE="${OUTPUT_DIR}/${sample_name}.csv"
    
    # Write header
    echo "sample,lane,fastq_1,fastq_2,sex,phenotype,paternal_id,maternal_id,case_id" > "$CSV_FILE"
    
    # Find all R1 files directly in this directory
    declare -a R1_FILES=()
    
    # Look for R1 files with different patterns
    for pattern in "*_R1_*.fastq.gz" "*_R1.*.fq.gz" "*.R1.fq.gz" "*_R1.fastq.gz"; do
        for file in "$sample_path"/$pattern; do
            # Check if file actually exists (glob may not match anything)
            if [ -f "$file" ]; then
                R1_FILES+=("$file")
            fi
        done
    done
    
    # Sort the array
    IFS=$'\n' R1_FILES=($(sort <<<"${R1_FILES[*]}"))
    unset IFS
    
    # If no R1 files found, skip this sample
    if [ ${#R1_FILES[@]} -eq 0 ]; then
        echo "  Warning: No R1 files found in $sample_path, skipping..."
        rm "$CSV_FILE"
        continue
    fi
    
    echo "  Found ${#R1_FILES[@]} R1 file(s)"
    
    # Counter for lanes
    lane=1
    pairs_found=0
    
    # Process each R1 file
    for R1_FILE in "${R1_FILES[@]}"; do
        # Determine the corresponding R2 file by replacing R1 with R2
        R2_FILE=""
        
        # Try different R2 naming patterns
        if [[ "$R1_FILE" =~ _R1_ ]]; then
            R2_FILE="${R1_FILE/_R1_/_R2_}"
        elif [[ "$R1_FILE" =~ _R1\. ]]; then
            R2_FILE="${R1_FILE/_R1./_R2.}"
        elif [[ "$R1_FILE" =~ \.R1\. ]]; then
            R2_FILE="${R1_FILE/.R1./.R2.}"
        fi
        
        # Check if R2 file exists
        if [ ! -f "$R2_FILE" ]; then
            echo "  Warning: R2 file not found for $(basename "$R1_FILE"), skipping this pair..."
            continue
        fi
        
        # Add entry to CSV
        echo "${sample_name},${lane},${R1_FILE},${R2_FILE},0,2,0,0,case_${sample_name}" >> "$CSV_FILE"
        
        echo "  Added pair ${lane}: $(basename "$R1_FILE") & $(basename "$R2_FILE")"
        
        lane=$((lane + 1))
        pairs_found=$((pairs_found + 1))
    done
    
    if [ $pairs_found -eq 0 ]; then
        echo "  Warning: No valid R1/R2 pairs found for $sample_name"
        rm "$CSV_FILE"
    else
        echo "  Created: $CSV_FILE with $pairs_found pair(s)"
        count=$((count + 1))
    fi
    
    echo "----------------------------------------"
    
done < "$SAMPLE_LIST"

echo ""
echo "Summary:"
echo "Total sample CSV files created: $count"
echo "Output location: $OUTPUT_DIR"