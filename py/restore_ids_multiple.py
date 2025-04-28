from Bio import Phylo
import sys

def restore_ids_multiple(tree_file, mapping_file, output_file):
    """
    Restore original IDs in a file containing multiple Newick trees.

    Args:
        tree_file (str): Path to the input Newick tree file.
        mapping_file (str): Path to the mapping file (shortened ID -> original ID).
        output_file (str): Path to save the restored trees.

    Returns:
        None
    """
    # Load the mapping from the mapping file
    id_map = {}
    with open(mapping_file, "r") as mapfile:
        for line in mapfile:
            shortened_id, original_id = line.strip().split("\t")
            id_map[shortened_id] = original_id

    # Parse and restore IDs in all trees
    trees = Phylo.parse(tree_file, "newick")
    updated_trees = []

    for tree in trees:
        for clade in tree.find_clades():
            if clade.name in id_map:
                clade.name = id_map[clade.name]
        updated_trees.append(tree)

    # Save all updated trees
    with open(output_file, "w") as outfile:
        Phylo.write(updated_trees, outfile, "newick")
    print(f"Multiple trees with restored IDs saved to {output_file}")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python restore_ids_multiple.py <tree_file> <mapping_file> <output_file>")
        sys.exit(1)

    tree_file = sys.argv[1]
    mapping_file = sys.argv[2]
    output_file = sys.argv[3]

    try:
        restore_ids_multiple(tree_file, mapping_file, output_file)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)