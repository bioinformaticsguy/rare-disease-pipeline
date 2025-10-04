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
PARAMS_FILE="$2"
JOB_NAME="${3:-run_rare_disease}"  # Default to 'run_rare_disease' if not provided



# Validate that both arguments were provided
if [ -z "$CONFIG_FILE" ] || [ -z "$PARAMS_FILE" ]; then
    echo "Error: Both config and params files must be provided"
    echo "Usage: sbatch $0 <config_file> <params_file>"
    exit 1
fi

# Check if files exist
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found: $CONFIG_FILE"
    exit 1
fi

if [ ! -f "$PARAMS_FILE" ]; then
    echo "Error: Params file not found: $PARAMS_FILE"
    exit 1
fi


# Run the rare diseae workflow
echo "Running Next flow rare disease pipeline..."
pwd


# Run with variables
nextflow run nf-core/raredisease \
    -revision 2.6.0 \
    -profile singularity \
    -c "$CONFIG_FILE" \
    --input "/data/humangen_kircherlab/Users/hassan/run_rare/rare-disease-pipeline/samplesheets/debug_samples.csv" \
    --outdir "/data/humangen_kircherlab/Users/hassan/run_rare/rare-disease-pipeline/debug_outputs/001_input_in_terminal"