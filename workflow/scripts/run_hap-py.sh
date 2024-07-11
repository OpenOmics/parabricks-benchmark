#!/usr/bin/env bash

set -euo pipefail

# Helper functions
function err() { cat <<< "$@" 1>&2; }
function fatal() { cat <<< "$@" 1>&2; usage; exit 1; }
function abspath() { readlink -e "$1"; }

# Check for all required
# command-line arguments
if [ $# -lt 5 ]; then
    err "Error: failed to provide all required arguments!"
    fatal "Usage: $0 <input_vcf> <output_prefix> <ref_fa> <truth_bed> <truth_vcf>"
fi

# Parse command line arguments
input_vcf="$1"
output_prefix="$2"
ref_fa="$3"
truth_bed="$4"
truth_vcf="$5"


# Create output directory
# from the output prefix
# if it does not exist.
output_dir=$(dirname "$output_prefix")
output_dir=$(abspath "$output_dir")
if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir"
fi


# Run hap.py to evaluate the 
# performance of parabricks 
# germline pipeline.
module purge
module load singularity

singularity run --bind $PWD,/data /data/OpenOmics/SIFs/hap.py_latest.sif \
    /opt/hap.py/bin/hap.py \
        --threads 8 \
        -o "$output_prefix" \
        -r "$ref_fa" \
        -f "$truth_bed" \
       "$truth_vcf" \
       "$input_vcf"

echo 'Done.... happy computer noises!'
# Touch flag file to indictate completion
touch "${output_prefix}.DONE"
