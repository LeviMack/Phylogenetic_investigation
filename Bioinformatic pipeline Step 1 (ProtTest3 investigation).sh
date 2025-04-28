# README
# This is the first script in the phylogenetic tree development series by Levi McKenzie.
# It utilizes MAFFT for sequence alignment and ProtTest3 to identify the optimum substitutional model to use in 
# the subsequent script
#
# This script is designed for High-Performance Computing (HPC) environments using Slurm.
# It creates directories and all necessary intermediary files for processing, and adds a timestamp for simple 
# data accountability
# Before submitting to Slurm, operators must replace the placeholders [brackets] with actual values:
# Example: TREE_VERSION="$[input]" ---> TREE_VERSION="$v9"


#!/bin/bash
#SBATCH --job-name=ProtTest3
#SBATCH -p icelake
#SBATCH -N 1
#SBATCH --ntasks=16
#SBATCH --time=20:00:00
#SBATCH --mem=128GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=[User_ID]

# Operator-defined variables
BASE_DIR="[target_directory]"
INPUT_FILE="$BASE_DIR/[input].fasta"
TREE_VERSION="[input]"

# Generate a timestamp (YYYYMMDD_HHMM format)
TIMESTAMP=$(date +"%Y%m%d_%H%M")

# Define directories
PROTEST_DIR="$BASE_DIR/prottest3_results_"$TREE_VERSION"_"$TIMESTAMP""
PY_DIR="$BASE_DIR/py"  # Python scripts directory

# Redirect all outputs to the single directory
ALIGNMENT_DIR="$PROTEST_DIR/mafft_alignments"
MAPPING_DIR="$PROTEST_DIR/mapping"

# Create output directories
mkdir -p "$ALIGNMENT_DIR/untrimmed" "$PROTEST_DIR/direct" "$MAPPING_DIR"

# Step 1: Shorten IDs using Python script
SHORTENED_FILE="$ALIGNMENT_DIR/untrimmed/aligned_short_ids.fasta"
MAPPING_FILE="$MAPPING_DIR/id_mapping.txt"
python3 "$PY_DIR/shorten_ids.py" "$INPUT_FILE" "$SHORTENED_FILE" "$MAPPING_FILE"
if [ $? -eq 0 ]; then
    echo "Shorten IDs completed successfully at $(date)"
else
    echo "Error during Shorten IDs step. Check input file and Biopython installation."
    exit 1
fi

# Step 2: Run MAFFT alignment and output PHYLIP file
ALIGNED_FILE="$ALIGNMENT_DIR/untrimmed/aligned_sequences.phy"
mafft --maxiterate 100 --auto --phylipout --thread 16 "$SHORTENED_FILE" > "$ALIGNED_FILE"
if [ $? -eq 0 ]; then
    echo "MAFFT alignment completed successfully in PHYLIP format at $(date)"
else
    echo "Error during MAFFT alignment step. Check MAFFT installation or input file."
    exit 1
fi

# Step 3: Run ProTest3 with 4 gamma categories and multi-threading
PROTEST_OUTPUT="$PROTEST_DIR/direct/protest_results.txt"
prottest3 -i "$ALIGNED_FILE" -o "$PROTEST_OUTPUT" -AIC -ncat 4 -threads 16 -all-distributions -F 
best_model=$(grep "Best model according to AIC:" "$PROTEST_OUTPUT" | awk '{print $NF}')
if [ $? -eq 0 ] && [ ! -z "$best_model" ]; then
    echo "ProTest3 completed successfully"
else
    echo "Error during ProTest3 step. Verify ProTest3 installation and input alignment."
    exit 1
fi

# Final message
echo "Pipeline complete. All outputs are stored in $PROTEST_DIR"