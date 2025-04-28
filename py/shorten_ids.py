import sys
from Bio import SeqIO

def shorten_fasta_ids(input_fasta, shortened_fasta, mapping_file):
    """
    Shortens sequence IDs in a FASTA file and writes a mapping file.

    Parameters:
    - input_fasta: Path to the input FASTA file.
    - shortened_fasta: Path to the output FASTA file with shortened IDs.
    - mapping_file: Path to the output mapping file linking original to shortened IDs.
    """
    try:
        print(f"Opening input file: {input_fasta}")
        with open(input_fasta, "r") as infile, \
             open(shortened_fasta, "w") as outfile, \
             open(mapping_file, "w") as mapfile:

            # Iterate through the sequences in the input FASTA
            for i, record in enumerate(SeqIO.parse(infile, "fasta"), start=1):
                short_id = f"Seq{i:07d}"  # Create a short ID (e.g., Seq0000001)
                
                # Debugging: Print ID mapping for each sequence
                print(f"Mapping: {record.id} -> {short_id}")
                
                # Write the mapping to the mapping file
                mapfile.write(f"{short_id}\t{record.id}\n")
                
                # Update the record ID to the short ID
                record.id = short_id
                record.description = ""  # Clear any description
                SeqIO.write(record, outfile, "fasta")  # Write to shortened FASTA file

        print(f"Shortened FASTA written to: {shortened_fasta}")
        print(f"Mapping file written to: {mapping_file}")
    
    except FileNotFoundError as e:
        print(f"Error: Input file not found - {e}")
        sys.exit(1)
    except PermissionError as e:
        print(f"Error: Permission denied - {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    # Check for correct number of arguments
    if len(sys.argv) != 4:
        print("Usage: python shorten_ids.py <input_fasta> <shortened_fasta> <mapping_file>")
        sys.exit(1)

    # Assign arguments to variables
    input_fasta = sys.argv[1]
    shortened_fasta = sys.argv[2]
    mapping_file = sys.argv[3]

    # Run the function to shorten IDs
    shorten_fasta_ids(input_fasta, shortened_fasta, mapping_file)