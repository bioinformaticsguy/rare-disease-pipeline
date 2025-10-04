#!/bin/bash

# Script to submit multiple sample jobs from a directory of CSV files
# Usage: ./submit_multiple_samples.sh <config_file> <csv_directory>

# Check if correct number of arguments provided
if [ "$#" -ne 2 ]; then
    echo "Error: Incorrect number of arguments"
    echo "Usage: $0 <config_file> <csv_directory>"
    echo "Example: $0 configs/oomics_minimal.config samplesheets/indi"
    exit 1
fi

CONFIG_FILE="$1"
CSV_DIR="$2"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found: $CONFIG_FILE"
    exit 1
fi

# Check if CSV directory exists
if [ ! -d "$CSV_DIR" ]; then
    echo "Error: CSV directory not found: $CSV_DIR"
    exit 1
fi

# Count CSV files
csv_count=$(find "$CSV_DIR" -maxdepth 1 -name "*.csv" -type f | wc -l)

if [ "$csv_count" -eq 0 ]; then
    echo "Error: No CSV files found in $CSV_DIR"
    exit 1
fi

echo "=========================================="
echo "Submitting jobs for $csv_count samples"
echo "Config: $CONFIG_FILE"
echo "CSV Directory: $CSV_DIR"
echo "=========================================="

# Counter for submitted jobs
submitted=0

# Loop through all CSV files in the directory
for csv_file in "$CSV_DIR"/*.csv; do
    # Skip if no CSV files found (glob didn't match)
    [ -f "$csv_file" ] || continue
    
    # Extract sample name from CSV filename
    sample_name=$(basename "$csv_file" .csv)
    
    echo "Submitting: $sample_name"
    
    # Submit job with sample name as job name
    sbatch --job-name="${sample_name}" run_from_csv.slurm \
        "$CONFIG_FILE" \
        "$csv_file"
    
    submitted=$((submitted + 1))
    
    # Small delay to avoid overwhelming the scheduler
    sleep 0.5
done

echo "=========================================="
echo "Total jobs submitted: $submitted"
echo "=========================================="
echo ""
echo "Check job status with: squeue -u \$USER"
echo "Cancel all jobs with: scancel -u \$USER"
