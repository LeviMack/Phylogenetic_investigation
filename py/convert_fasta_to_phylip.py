from Bio import SeqIO
import sys

def convert_fasta_to_phylip(input_fasta, output_phylip):
    """
    Convert FASTA file to PHYLIP format for phylogenetic analyses.

    Args:
        input_fasta (str): Path to the input FASTA file.
        output_phylip (str): Path to save the converted PHYLIP file.

    Returns:
        None
    """
    # Parse sequences from FASTA file
    sequences = list(SeqIO.parse(input_fasta, "fasta"))
    
    # Get the number of sequences and sequence length
    num_sequences = len(sequences)
    seq_length = len(sequences[0].seq)

    # Check consistency of sequence lengths
    for seq_record in sequences:
        if len(seq_record.seq) != seq_length:
            raise ValueError("Sequences are not of equal length in FASTA file.")

    # Write PHYLIP format to output file
    with open(output_phylip, "w") as phylip_file:
        phylip_file.write(f"{num_sequences} {seq_length}\n")
        for seq_record in sequences:
            # Format name to a fixed length (10 characters) and write sequence
            name = seq_record.id[:10].ljust(10)
            phylip_file.write(f"{name}{seq_record.seq}\n")

    print(f"FASTA file successfully converted to PHYLIP format: {output_phylip}")


if __name__ == "__main__":
    # Command-line arguments: input FASTA file and output PHYLIP file
    if len(sys.argv) != 3:
        print("Usage: python convert_fasta_to_phylip.py <input_fasta> <output_phylip>")
        sys.exit(1)

    input_fasta = sys.argv[1]
    output_phylip = sys.argv[2]

    try:
        convert_fasta_to_phylip(input_fasta, output_phylip)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)