#!/bin/bash
# filepath: /data/humangen_kircherlab/Users/hassan/run_rare/rare-disease-pipeline/generate_sample_list.sh

# Usage: ./generate_sample_list.sh <input_dir> <output_dir> <batch_size>
# Example: ./generate_sample_list.sh /path/to/samples /path/to/output 10
# Last Used Example: ./generate_sample_list.sh /data/humangen_sfb1665_seqdata/short_read/raw /data/humangen_kircherlab/Users/hassan/run_rare/rare-disease-pipeline/sample_lists 10



if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_dir> <output_dir> <batch_size>"
    echo "Example: $0 /data/samples /data/batches 10"
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
BATCH_SIZE="$3"

# Validate inputs
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Input directory '$INPUT_DIR' does not exist"
    exit 1
fi

if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Creating output directory: $OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"
fi

if ! [[ "$BATCH_SIZE" =~ ^[0-9]+$ ]] || [ "$BATCH_SIZE" -lt 1 ]; then
    echo "Error: Batch size must be a positive integer"
    exit 1
fi

# Get all directories (not files) in input directory, excluding those starting with underscore
mapfile -t dirs < <(find "$INPUT_DIR" -maxdepth 1 -type d ! -path "$INPUT_DIR" ! -name "_*" | sort)

total_dirs=${#dirs[@]}

if [ "$total_dirs" -eq 0 ]; then
    echo "Error: No directories found in '$INPUT_DIR'"
    exit 1
fi

echo "Found $total_dirs directories in '$INPUT_DIR'"
echo "Creating batches of size $BATCH_SIZE..."

# Calculate number of batches needed
num_batches=$(( (total_dirs + BATCH_SIZE - 1) / BATCH_SIZE ))

echo "Will create $num_batches batch file(s)"

# Generate batch files
batch_num=1
for ((i=0; i<total_dirs; i+=BATCH_SIZE)); do
        batch_file="$OUTPUT_DIR/batch_$(printf "%03d" $batch_num)_size${BATCH_SIZE}.txt"
    
    # Write directories to batch file
    > "$batch_file"  # Clear/create file
    for ((j=i; j<i+BATCH_SIZE && j<total_dirs; j++)); do
        echo "${dirs[$j]}" >> "$batch_file"
    done
    
    dir_count=$(wc -l < "$batch_file")
    echo "  Created: $batch_file ($dir_count directories)"
    
    ((batch_num++))
done

echo ""
echo "✅ Successfully created $num_batches batch file(s) in '$OUTPUT_DIR'"
echo ""
echo "Batch files:"
ls -1 "$OUTPUT_DIR"/batch_*.txt