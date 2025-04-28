# CESA-CSL_investigation
# This is the set-up script for the phylogenetic investigation pipeline developed by Levi J. McKenzie, 2025. 
# The whole pipeline is designed to be run and easily operable by Users unfamiliar with the University of Adelaide's (UoA) HPC PHOENIX system.
# Anaconda3 is required to be installed on the system before operation, and it is recommended for all stages here-on-out be run through a Linux system emulator (PuTTY on Windows is recommended), which allows Windows systems to connect to the HPC Linux-based operation system.
# PuTTY enables secure access to the HPC via Secure SHell (SHH), safe file-transfer, and session management from a remote computer system. 
# Once inside the UoA system, Anaconda3 can be installed through the commandline prompt "module load Anaconda3". 
# A few prompts are required from the User to allow personalisation before installation, which can be identified below under " # User Inputs = [Target_directory]"
#

#!/bin/bash
#SBATCH --job-name=Set-up
#SBATCH -p icelake
#SBATCH -N 1
#SBATCH --ntasks=16
#SBATCH --time=1:00:00
#SBATCH --mem=32GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=[User Email]

# User input
ENV_NAME="$[input]"

conda create -n "$ENV_NAME" -f LJM_Phylogenetic_investigation.yml
