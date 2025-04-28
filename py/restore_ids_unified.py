#!/usr/bin/env python3
import os
from Bio import Phylo

def load_mapping(mapping_file):
    """
    Load the mapping of shortened IDs to original IDs from the mapping file.
    """
    id_map = {}
    with open(mapping_file, "r") as mapfile:
        for line in mapfile:
            shortened_id, original_id = line.strip().split("\t")
            id_map[shortened_id] = original_id
    return id_map

def restore_ids_in_tree(tree, id_map):
    """
    Restore IDs in a single Newick tree using the provided ID map.
    """
    for clade in tree.find_clades():
        if clade.name in id_map:
            clade.name = id_map[clade.name]

def process_single_file(tree_file, mapping_file, output_file):
    """
    Process a single file containing one or more trees.
    """
    id_map = load_mapping(mapping_file)
    trees = Phylo.parse(tree_file, "newick")  # Supports files with multiple trees
    updated_trees = []

    print(f"Restoring IDs for trees in file: {tree_file}")

    for tree in trees:
        restore_ids_in_tree(tree, id_map)
        updated_trees.append(tree)

    with open(output_file, "w") as outfile:
        Phylo.write(updated_trees, outfile, "newick")  # Saves all updated trees in one file
    print(f"Restored IDs saved to {output_file}")

def process_directory(tree_folder, mapping_file, output_folder):
    """
    Process all tree files in a directory, including multi-tree files.
    """
    id_map = load_mapping(mapping_file)
    os.makedirs(output_folder, exist_ok=True)

    # Filter for valid tree file extensions
    valid_extensions = (".newick", ".tree", ".bootstraps", ".bestTree", ".support", ".mlTrees")
    tree_files = [f for f in os.listdir(tree_folder) if f.endswith(valid_extensions)]

    for tree_file in tree_files:
        try:
            print(f"Processing tree file: {tree_file}")
            tree_path = os.path.join(tree_folder, tree_file)
            
            # Multi-tree files are handled here
            output_path = os.path.join(output_folder, tree_file)
            process_single_file(tree_path, mapping_file, output_path)  # Uses updated logic
        except Exception as e:
            print(f"Error processing {tree_file}: {e}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 4:
        print("Usage: python restore_ids_unified.py <input_file_or_folder> <mapping_file> <output_file_or_folder>")
        sys.exit(1)

    input_path = sys.argv[1]
    mapping_file = sys.argv[2]
    output_path = sys.argv[3]

    if os.path.isfile(input_path):
        print("Input is a file. Processing single file...")
        process_single_file(input_path, mapping_file, output_path)
    elif os.path.isdir(input_path):
        print("Input is a directory. Processing all tree files in directory...")
        process_directory(input_path, mapping_file, output_path)
    else:
        print(f"Error: {input_path} is neither a file nor a directory.")
        sys.exit(1)