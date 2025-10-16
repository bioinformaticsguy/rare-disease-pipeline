#!/bin/bash

#SBATCH --partition=longterm
#SBATCH --nodes=1
#SBATCH -c 1
#SBATCH --mem=16GB
#SBATCH --tmp=100G
#SBATCH --output=logs/%j_%u_%N_run_rare_disease.out
#SBATCH --error=logs/%j_%u_%N_run_rare_disease.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=alihassan1697@gmail.com


### Usage:  sbatch sbatch_run_nextflow.slurm --job-name=debug-no-param configs/oomics_minimal.config yamls/debug_params.yaml 


module load singularity/v4.1.3
module load nextflow/v24.04.3

# Print versions
echo "checking versions..."
singularity --version
nextflow -v


# Define variables for file paths
# Get config and params files from command line arguments
CONFIG_FILE="$1"
CSV_FILE="$2"
BASE_OUTPUT_DIR="/data/humangen_sfb1665_seqdata/short_read/processed_data/batch_outputs"


# Extract sample name from CSV filename
CSV_BASENAME=$(basename "$CSV_FILE")
SAMPLE_NAME="${CSV_BASENAME%.csv}"

# Clean up any stale parameter files
rm -f .params_*.json

if [ -z "$CONFIG_FILE" ] || [ -z "$CSV_FILE" ]; then
    echo "Error: Config and CSV files must be provided"
    echo "Usage: sbatch $0 <config_file> <csv_file>"
    exit 1
fi


# Check if files exist
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found: $CONFIG_FILE"
    exit 1
fi

if [ ! -f "$CSV_FILE" ]; then
    echo "Error: Params file not found: $CSV_FILE"
    exit 1
fi

input_dir=$(dirname "$CSV_FILE")
output_dir="${BASE_OUTPUT_DIR}/${SAMPLE_NAME}"

# Run the rare disease workflow
echo "========================================"
echo "Running Nextflow Rare Disease Pipeline"
echo "========================================"
echo "Config file: $CONFIG_FILE"
echo "CSV file: $CSV_FILE"
echo "Sample name: $SAMPLE_NAME"
echo "Output directory: $output_dir"
echo "Working directory: $(pwd)"
echo "========================================"




# Run with variables
nextflow run nf-core/raredisease \
    -revision 2.6.0 \
    -profile singularity \
    -c "$CONFIG_FILE" \
    --input "$CSV_FILE" \
    --outdir "$output_dir"