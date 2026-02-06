#!/bin/bash
#SBATCH --job-name=synb0_subidx3-4
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=01:00:00
#SBATCH --array=7-63
#SBATCH --output=/home/alexis.melot/dwi_preproc_recon/src/slurm/err/%j.txt
#SBATCH --err=/home/alexis.melot/dwi_preproc_recon/src/slurm/err/%j.err

# Start timer
START_TIME=$(date +%s)

#----#
# Load modules
module load apptainer/1.2.5
module load conda/25.11-py313 
conda activate mri-env

session=post # Define participant ID
synb0disco_path=~/synb0-disco-3.1.sif # Apptainer image paths
fsl_license_path=~/license.txt # FSL license path
main_dir=~/dwi_preproc_recon # Main directory
bids_dir=$main_dir/data/bids # BIDS directory
synb0_dir=$main_dir/results/synb0 # Synb0 output directory

# Call python function from utils.py to run synb0 on the subject at index SLURM_ARRAY_TASK_ID in the sorted list of sub-IDs
PYTHONPATH=$main_dir/src/code:$PYTHONPATH python -c "from tools.utils import *; 
synb0_job_array(${SLURM_ARRAY_TASK_ID}, '$session', '$bids_dir', '$synb0_dir', '$synb0disco_path', '$fsl_license_path')"

#----#
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
HOURS=$((DURATION / 3600))
MINUTES=$(( (DURATION % 3600) / 60 ))
SECONDS=$((DURATION % 60))

echo "### Job duration: ${HOURS}h ${MINUTES}m ${SECONDS}s ###" >> /home/alexis.melot/dwi_preproc_recon/src/slurm/err/${SLURM_JOB_ID}.txt