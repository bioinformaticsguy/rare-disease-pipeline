#!/bin/bash

#SBATCH --partition=longterm
#SBATCH --nodes=1
#SBATCH -c 1
#SBATCH --mem=16GB
#SBATCH --tmp=100G
#SBATCH --job-name=run_rare_disease
#SBATCH --output=logs/%j_%u_%N_run_rare_disease.out
#SBATCH --error=logs/%j_%u_%N_run_rare_disease.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=alihassan1697@gmail.com


# Define variables for file paths
PIPELINE_DIR="/data/humangen_kircherlab/Users/hassan/run_rare/rare-disease-pipeline"
CONFIG_FILE="${PIPELINE_DIR}/configs/oomics_minimal.config"
PARAMS_FILE="${PIPELINE_DIR}/yamls/omics_kiristian_GS369.yaml"

module load singularity/v4.1.3
module load nextflow/v24.04.3

# Print versions
echo "checking versions..."
singularity --version
nextflow -v

# Run the rare diseae workflow
echo "Running Next flow rare disease pipeline..."
cd $SCRATCH
pwd

# Copy necessary files to scratch (if needed)
cp "$CONFIG_FILE" .
cp "$PARAMS_FILE" .

ls 

# Run with variables
nextflow run nf-core/raredisease \
    -revision 2.6.0 \
    -profile singularity \
    -c "$CONFIG_FILE" \
    -params-file "$PARAMS_FILE" \
    -resume