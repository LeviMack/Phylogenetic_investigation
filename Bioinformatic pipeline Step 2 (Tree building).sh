# README
# This is the second document/self-contained script in the phylogenetic tree development series by Levi McKenzie.
# It utilizes MAFFT for sequence alignment and RAxML-NG for phylogenetic tree reconstruction,
# using an evolutionary substitution model determined from a prior script involving ProtTest3. 
# Sequence IDs go through a temporary shortening step due to phylip format not supporting IDs longer than 10
# characters, which is ideal for RAxML-NG operation. The sequences are then reinstated with their original ID
# after tree development.
#
# This script is designed for High-Performance Computing (HPC) environments using Slurm.
# It creates directories and all necessary intermediary files for processing, and adds a timestamp for simple data accountability
# Before submitting to Slurm, operators must replace the placeholders [brackets] with actual values:
# Example: TREE_VERSION="$[input]" ---> TREE_VERSION="$v9"
#
# Incorperating high numbers (hundreds) of sequences and/or increasingly long residues, the dedicated walltime 
# in the script may end before completion. Resubmission of the script will cause the software to continue it's
# operation where it left off.

# Script below to be run

#!/bin/bash
#SBATCH --job-name=Tree_building
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
SUB_MODEL="[ProtTest3 best substitution model]"

# Generate a timestamp (YYYYMMDD_HHMM format)
TIMESTAMP=$(date +"%Y%m%d_%H%M")

# Define directories
OUTPUT_DIR="$BASE_DIR/raxml-ng-$TREE_VERSION_$TIMESTAMP"  # Timestamped output directory
PY_DIR="$BASE_DIR/py"
ALIGNMENT_DIR="$OUTPUT_DIR/mafft_alignments"
RAXML_DIR="$OUTPUT_DIR/raxml_trees"
MAPPING_DIR="$OUTPUT_DIR/mapping"
FINAL_TREE_DIR="$OUTPUT_DIR/final_trees"

# Create necessary directories
mkdir -p "$ALIGNMENT_DIR/untrimmed" "$RAXML_DIR/direct/untouched" "$MAPPING_DIR" "$FINAL_TREE_DIR"

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

# Step 2: Run MAFFT alignment and output a PHYLIP file
ALIGNED_PHYLIP="$ALIGNMENT_DIR/untrimmed/aligned_sequences.phy"

mafft --maxiterate 100 --phylipout --thread 16 "$SHORTENED_FILE" > "$ALIGNED_PHYLIP"
if [ $? -eq 0 ]; then
    echo "MAFFT alignment completed successfully at $(date)"
else
    echo "Error during MAFFT alignment step. Check MAFFT installation or input file."
    exit 1
fi

# Step 3: Build the RAxML-ng tree using the PHYLIP alignment
TREE_DIR="$RAXML_DIR/direct/untouched"
PREFIX="$TREE_DIR/phylogenetic_tree"  # Define output prefix

raxml-ng --all --msa "$ALIGNED_PHYLIP" --model "$SUB_MODEL" --threads 16 --bs-trees 100 --prefix "$PREFIX"
if [ $? -eq 0 ]; then
    echo "RAxML-ng tree built successfully at $(date)"
else
    echo "Error during RAxML-ng tree-building step. Check RAxML-ng installation and input data."
    exit 1
fi

# Step 4: Mapping bootstrap trees to best tree
raxml-ng --support --tree "$TREE_DIR/phylogenetic_tree.raxml.bestTree" --bs-trees "$TREE_DIR/phylogenetic_tree.raxml.bootstraps" --prefix B2
if [ $? -ne 0 ]; then
    echo "Error during bootstrap mapping. Check bootstrap files and RAxML-ng installation."
    exit 1
fi

# Step 5: Restore IDs in tree outputs using Python script
python3 "$PY_DIR/restore_ids_unified.py" "$TREE_DIR" "$MAPPING_FILE" "$FINAL_TREE_DIR"
if [ $? -eq 0 ]; then
    echo "Restored IDs for all trees saved to $FINAL_TREE_DIR at $(date)"
else
    echo "Error during ID restoration step. Check mapping file and tree outputs."
    exit 1
fi

# Step 6: Append ".newick" extension to all files in the final_trees folder (avoiding duplicates)
for file in "$FINAL_TREE_DIR"/*; do
    if [ -f "$file" ] && [[ ! "$file" =~ \.newick$ ]]; then
        mv "$file" "${file}.newick"
    fi
done

# Final message
echo "Pipeline complete. Restored trees saved to $FINAL_TREE_DIR"



#!/bin/bash
#SBATCH --job-name=Tree_building
#SBATCH -p icelake
#SBATCH -N 1
#SBATCH --ntasks=16
#SBATCH --time=20:00:00
#SBATCH --mem=128GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=[User_ID]

# Operator variables
BASE_DIR="$[target_directory]"
INPUT_FILE="$BASE_DIR/[input].fasta"
TREE_VERSION="$[input]"
SUB_MODEL="$[ProtTest3 best substitution model]"

# Generate a timestamp (YYYYMMDD_HHMM format)
TIMESTAMP=$(date +"%Y%m%d_%H%M")

# Define directories
OUTPUT_DIR="$BASE_DIR/raxml-ng-$TREE_VERSION_$TIMESTAMP"  # Unified output directory
PY_DIR="$BASE_DIR/py"
ALIGNMENT_DIR="$OUTPUT_DIR/mafft_alignments"
RAXML_DIR="$OUTPUT_DIR/raxml_trees"
MAPPING_DIR="$OUTPUT_DIR/mapping"
FINAL_TREE_DIR="$OUTPUT_DIR/final_trees"

# Create necessary directories
mkdir -p "$ALIGNMENT_DIR/untrimmed"
mkdir -p "$RAXML_DIR/direct/untouched" "$MAPPING_DIR" "$FINAL_TREE_DIR"

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

# Step 2: Run MAFFT alignment and output a PHYLIP file
ALIGNED_PHYLIP="$ALIGNMENT_DIR/untrimmed/aligned_sequences.phy"

mafft --maxiterate 100 --phylipout --thread 16 "$SHORTENED_FILE" > "$ALIGNED_PHYLIP"
if [ $? -eq 0 ]; then
    echo "MAFFT alignment completed successfully at $(date)"
else
    echo "Error during MAFFT alignment step. Check MAFFT installation or input file."
    exit 1
fi

# Step 3: Build the RAxML-ng tree using the PHYLIP alignment
TREE_DIR="$RAXML_DIR/direct/untouched"
# Define a prefix (without any trailing extension) for RAxML-ng output.
# RAxML-ng will append ".raxml.bestTree" and ".raxml.bootstraps" to the output.
PREFIX="$TREE_DIR/phylogenetic_tree"

raxml-ng --all --msa "$ALIGNED_PHYLIP" --model "SUB_MODEL" -threads 16 --bs-trees 100 --prefix "$PREFIX"
if [ $? -eq 0 ]; then
    echo "RAxML-ng tree built successfully at $(date)"
else
    echo "Error during RAxML-ng tree-building step. Check RAxML-ng installation and input data."
    exit 1
fi

# Mapping the bootstraps to the best tree output
raxml-ng --support --tree "$TREE_DIR/phylogenetic_tree.raxml.bestTree" --bs-trees "$TREE_DIR/phylogenetic_tree.raxml.bootstraps" --prefix B2

# Step 4: Restore IDs in the tree outputs using the unified Python script
# Use the unified Python script to restore IDs for all RAxML tree outputs
python3 "$PY_DIR/restore_ids_unified.py" "$TREE_DIR" "$MAPPING_FILE" "$FINAL_TREE_DIR"
if [ $? -eq 0 ]; then
    echo "Restored IDs for all trees saved to $FINAL_TREE_DIR at $(date)"
else
    echo "Error during ID restoration step. Check mapping file and tree outputs."
    exit 1
fi

# Step 5: Append the ".newick" extension to all files in the final_trees folder
for file in "$FINAL_TREE_DIR"/*; do
    if [ -f "$file" ]; then
        mv "$file" "${file}.newick"
    fi
done

# Final message
echo "Pipeline complete. Restored trees saved to $FINAL_TREE_DIR"