#!/bin/bash

#SBATCH --partition=longterm
#SBATCH --nodes=1
#SBATCH -c 1
#SBATCH --mem=16GB
#SBATCH --tmp=100G
#SBATCH --job-name=run_rare_disease
#SBATCH --output=logs/run_rare_disease.out
#SBATCH --error=logs/run_rare_disease.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=alihassan1697@gmail.com


module load singularity/v4.1.3
module load nextflow/v24.04.3

# Print versions
echo "checking versions..."
singularity --version
nextflow -v

# Run the rare diseae workflow
echo "Running Next flow rare disease pipeline..."
pwd
nextflow run nf-core/raredisease -revision 2.6.0 -profile singularity -c /configs/oomics_minimal.config -params-file /yamls/omics.yaml
