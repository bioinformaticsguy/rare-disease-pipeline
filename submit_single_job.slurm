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



# Run the rare diseae workflow
echo "Running Next flow rare disease pipeline..."
pwd

# nextflow run nf-core/raredisease -revision 2.6.0 -profile singularity -c configs/oomics_minimal.config --input samplesheets/nadine_and_jakob/A4842_DNA_42.csv --outdir /data/humangen_kircherlab/Users/hassan/run_rare/rare-disease-pipeline/outputs/A4842_DNA_42 -resume


nextflow run nf-core/raredisease \
    -revision 2.6.0 \
    -profile singularity \
    -c configs/oomics_minimal.config \
    --input samplesheets/sssheet.csv \
    --outdir /data/humangen_kircherlab/Users/hassan/run_rare/rare-disease-pipeline/debug_outputs/work_dir_test \
    -resume

