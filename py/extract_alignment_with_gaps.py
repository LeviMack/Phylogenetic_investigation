from bs4 import BeautifulSoup
import sys

def extract_alignment_with_gaps(input_html, output_fasta):
    # Open and parse the HTML file
    with open(input_html, "r") as file:
        soup = BeautifulSoup(file, "lxml")

    # Locate the <pre> tag that contains the alignment
    pre_block = soup.find("pre")
    if not pre_block:
        print("Error: <pre> block not found in the HTML file.")
        sys.exit(1)

    # Extract the text from the <pre> block
    raw_alignment = pre_block.get_text().strip()

    # Process the extracted alignment text to make it FASTA-compatible
    fasta_data = []
    for line in raw_alignment.splitlines():
        # Remove any alignment column headers (e.g., numbers or separators like "=")
        if line.startswith(" ") or "=" in line:
            continue
        # Format sequence headers and sequences
        parts = line.split()
        if len(parts) == 2:  # Ensure the line has both a sequence ID and the sequence
            fasta_data.append(f">{parts[0]}")  # Add sequence ID as FASTA header
            fasta_data.append(parts[1])        # Add sequence, including gaps

    # Write the processed FASTA data to the output file
    with open(output_fasta, "w") as fasta_file:
        fasta_file.write("\n".join(fasta_data))

    print(f"Alignment with gaps preserved successfully extracted and saved to: {output_fasta}")

# Command-line arguments for flexibility
if len(sys.argv) != 3:
    print("Usage: python extract_alignment_with_gaps.py input_file.html output_file.fasta")
    sys.exit(1)

input_html = sys.argv[1]
output_fasta = sys.argv[2]

extract_alignment_with_gaps(input_html, output_fasta)