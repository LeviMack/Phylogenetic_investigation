from Bio import Phylo
import sys

def restore_ids_single(tree_file, mapping_file, output_file):
    """
    Restore original IDs in a single Newick tree file.

    Args:
        tree_file (str): Path to the input Newick tree file.
        mapping_file (str): Path to the mapping file (shortened ID -> original ID).
        output_file (str): Path to save the restored tree.

    Returns:
        None
    """
    # Load the mapping from the mapping file
    id_map = {}
    with open(mapping_file, "r") as mapfile:
        for line in mapfile:
            shortened_id, original_id = line.strip().split("\t")
            id_map[shortened_id] = original_id

    # Load the tree
    tree = Phylo.read(tree_file, "newick")

    # Replace IDs
    for clade in tree.find_clades():
        if clade.name in id_map:
            clade.name = id_map[clade.name]

    # Save the updated tree
    Phylo.write(tree, output_file, "newick")
    print(f"Single tree with restored IDs saved to {output_file}")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python restore_ids_single.py <tree_file> <mapping_file> <output_file>")
        sys.exit(1)

    tree_file = sys.argv[1]
    mapping_file = sys.argv[2]
    output_file = sys.argv[3]

    try:
        restore_ids_single(tree_file, mapping_file, output_file)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)