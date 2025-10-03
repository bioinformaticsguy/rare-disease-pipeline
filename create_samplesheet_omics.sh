#!/bin/bash
# filepath: /data/humangen_kircherlab/Users/hassan/run_rare/rare-disease-pipeline/create_samplesheet_omics.sh

#===============================================================================
# SAMPLE SHEET GENERATOR FOR RARE DISEASE PIPELINE
#===============================================================================
# 
# DESCRIPTION:
#   This script creates a sample sheet CSV file for the nf-core/raredisease pipeline
#   by searching for FASTQ files across multiple sample directories.
#
# USAGE:
#   ./create_samplesheet_omics.sh <sample_directories> <sample_names> <output_file>
#
# ARGUMENTS:
#   1. sample_directories : Colon-separated list of directories to search for samples
#                          Example: "/data/batch1:/data/batch2:/data/novogene"
#   
#   2. sample_names      : Comma-separated list of sample names to include
#                          Example: "GS608,GS467,KiGS23,KiGS28,KiGS32"
#   
#   3. output_file       : Name of the output CSV sample sheet
#                          Example: "my_samples.csv"
#
# EXAMPLES:
#   # Single directory with multiple samples
#   ./create_samplesheet_omics.sh "/data/novogene/01.RawData" "GS001,GS002,GS003" "cohort1.csv"
#
#   # Multiple directories with samples
#   ./create_samplesheet_omics.sh "/data/batch1:/data/batch2" "GS001,KiGS002" "multi_batch.csv"
#
#   # Real example with your data structure
#   ./create_samplesheet_omics.sh "/data/humangen_kircherlab/hassan/novogene/01.RawData" "GS001,GS002,KiGS003" "family_study.csv"
#
# EXPECTED DIRECTORY STRUCTURE:
#   Each sample directory should contain paired FASTQ files:
#   /path/to/samples/
#   ├── prefix_GS001_suffix/
#   │   ├── sample_L1_1.fq.gz  # Read 1
#   │   └── sample_L1_2.fq.gz  # Read 2
#   └── another_GS002_name/
#       ├── sample_L1_1.fq.gz
#       └── sample_L1_2.fq.gz
#
# OUTPUT:
#   Creates a CSV file with columns required for nf-core/raredisease:
#   sample,lane,fastq_1,fastq_2,sex,phenotype,paternal_id,maternal_id,case_id
#
# NOTES:
#   - Script searches for sample names as SUBSTRINGS in directory names
#   - Script searches for files matching patterns: 
#     * *_1.fq.gz/*_2.fq.gz 
#     * *_R1_*.fastq.gz/*_R2_*.fastq.gz
#     * *.R1.fq.gz/*.R2.fq.gz
#   - If sample exists in multiple directories, all instances will be included
#   - Lane numbers are extracted from filenames (e.g., _L1_) or default to 1
#   - Default values: sex=0, phenotype=2, paternal_id=0, maternal_id=0
#   - case_id is automatically set to "case_<sample_name>"
#
#===============================================================================

# Check if correct number of arguments provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <samples_directories_colon_separated> <sample_names_comma_separated> <output_sample_sheet>"
    echo "Example: $0 '/path/to/samples1:/path/to/samples2:/path/to/samples3' 'GS001,GS002,KiGS003' my_samples.csv"
    exit 1
fi

SAMPLES_DIRS_STRING="$1"
SAMPLE_NAMES="$2"
OUTPUT="$3"

# Split colon-separated directories
IFS=':' read -ra SAMPLES_DIRS <<< "$SAMPLES_DIRS_STRING"

# Split comma-separated sample names
IFS=',' read -ra SAMPLES <<< "$SAMPLE_NAMES"

# Add counter for requested samples
total_requested_samples=${#SAMPLES[@]}
samples_found=0
declare -A found_samples_list

# Create CSV Header
echo "sample,lane,fastq_1,fastq_2,sex,phenotype,paternal_id,maternal_id,case_id" > "$OUTPUT"

# Add Control or test samples if needed (Manually)
# echo "hugelymodelbat,1,/data/humangen_kircherlab/hassan/run_rare/rare-disease-pipeline/data/test37/1_171015_HHT5NDSXX_hugelymodelbat_XXXXXX_1.fastq.gz,/data/humangen_kircherlab/hassan/run_rare/rare-disease-pipeline/data/test37/1_171015_HHT5NDSXX_hugelymodelbat_XXXXXX_2.fastq.gz,1,2,0,0,justesthusky" >> "$OUTPUT"

# Process each sample directory
for SAMPLES_DIR in "${SAMPLES_DIRS[@]}"; do
    # Check if samples directory exists
    if [[ ! -d "$SAMPLES_DIR" ]]; then
        echo "⚠️  Warning: Samples directory '$SAMPLES_DIR' does not exist, skipping..." >&2
        continue
    fi
    
    echo "🔍 Searching in directory: $SAMPLES_DIR"
    
    # Process each sample name
    for sample in "${SAMPLES[@]}"; do
        # Remove any whitespace
        sample=$(echo "$sample" | xargs)
        
        echo "  🔍 Looking for sample: $sample"
        
        # Find directories that CONTAIN the sample name (not exact match)
        found_sample=false
        for sample_dir in "$SAMPLES_DIR"/*"$sample"*; do
            # Check if glob matched any directories
            if [[ ! -d "$sample_dir" ]]; then
                continue
            fi
            
            found_sample=true
            dir_name=$(basename "$sample_dir")
            
            echo "    📁 Found matching directory: $dir_name"
            
            # Find all FASTQ files with multiple patterns in one loop
            found_files=false
            for fq1 in "$sample_dir"/*_1.fq.gz "$sample_dir"/*_R1_*.fastq.gz "$sample_dir"/*"$sample"*.R1.fq.gz; do
                # Check if glob matched any files
                if [[ ! -f "$fq1" ]]; then
                    continue
                fi
                
                found_files=true
                
                # Derive matching R2 file based on pattern
                if [[ "$fq1" == *"_1.fq.gz" ]]; then
                    # Pattern: *_1.fq.gz -> *_2.fq.gz
                    fq2="${fq1/_1.fq.gz/_2.fq.gz}"
                    # Extract lane from filename
                    lane=$(basename "$fq1" | sed -n 's/.*_L\([0-9]*\)_1.fq.gz/\1/p')
                elif [[ "$fq1" == *"_R1_"*".fastq.gz" ]]; then
                    # Pattern: *_R1_*.fastq.gz -> *_R2_*.fastq.gz
                    fq2="${fq1/_R1_/_R2_}"
                    # Extract lane from *_L###_R1_* pattern
                    lane=$(basename "$fq1" | sed -n 's/.*_L\([0-9]*\)_R1_.*/\1/p')
                else
                    # Pattern: *.R1.fq.gz -> *.R2.fq.gz
                    fq2="${fq1/.R1.fq.gz/.R2.fq.gz}"
                    # No lane info in this pattern, use default
                    lane=""
                fi
                
                # If no lane found, use 1 as default
                if [[ -z "$lane" ]]; then
                    lane="1"
                fi
                
                # Check both files exist
                if [[ -f "$fq1" && -f "$fq2" ]]; then
                    echo "      ✅ Adding files: $(basename "$fq1"), $(basename "$fq2")"
                    
                    # Write to CSV: sample,lane,fastq_1,fastq_2,sex,phenotype,paternal_id,maternal_id,case_id
                    echo "${sample},${lane},${fq1},${fq2},0,2,0,0,case_${sample}" >> "$OUTPUT"
                    if [[ "${found_samples_list[$sample]}" != "1" ]]; then
                        found_samples_list[$sample]=1
                        ((samples_found++))
                    fi
                else
                    echo "      ⚠️  Missing paired file for: $(basename "$fq1")" >&2
                fi
            done
            
            if [[ "$found_files" == false ]]; then
                echo "      ⚠️  No FASTQ files found in $sample_dir" >&2
            fi
        done
        
        if [[ "$found_sample" == false ]]; then
            echo "    ❌ No directories found containing: $sample" >&2
        fi
    done
done

echo ""
echo "✅ Sample sheet written to $OUTPUT"
echo "📊 Summary:"
echo "   - Samples requested: $total_requested_samples"
echo "   - Samples found: $samples_found"
echo "   - Total FASTQ pairs added: $(( $(wc -l < "$OUTPUT") - 1 ))" # Subtract 1 for header

# Show which samples were found/missing
echo "📋 Sample status:"
for sample in "${SAMPLES[@]}"; do
    if [[ "${found_samples_list[$sample]}" == "1" ]]; then
        echo "   ✅ $sample - FOUND"
    else
        echo "   ❌ $sample - NOT FOUND"
    fi
done
