#!/bin/bash
#SBATCH --job-name=qsiprep_subidx1-63_post
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=02:30:00
#SBATCH --array=1-63
#SBATCH --output=/home/alexis.melot/dwi_preproc_recon/src/slurm/err/%j.txt
#SBATCH --err=/home/alexis.melot/dwi_preproc_recon/src/slurm/err/%j.err

# Start time
START_TIME=$(date +%s)

#----#
# Load modules
module load apptainer/1.2.5
module load conda/25.11-py313 
conda activate mri-env

session=post # Define participant ID
qsiprep_sif_path=~/qsiprep-1.1.1.sif # Apptainer image paths
fsl_license_path=~/license.txt # FSL license path
main_dir=~/dwi_preproc_recon # Main directory
bids_dir=$main_dir/data/bids # BIDS directory
qsiprep_dir=$main_dir/results/qsiprep_outputs/qsiprep_multi # Output directory for qsiprep results

# Call python function from utils.py to run qsiprep on the subject at index SLURM_ARRAY_TASK_ID in the sorted list of sub-IDs
PYTHONPATH=$main_dir/src/code:$PYTHONPATH python -c "from tools.utils import *; 
qsiprep_job_array(${SLURM_ARRAY_TASK_ID}, '$session', '$bids_dir', '$qsiprep_dir', '$qsiprep_sif_path', '$fsl_license_path')"
    
#----#
# End time
END_TIME=$(date +%s)

# Calculate duration in seconds
DURATION=$((END_TIME - START_TIME))

# Convert to hours, minutes, seconds
HOURS=$((DURATION / 3600))
MINUTES=$(( (DURATION % 3600) / 60 ))
SECONDS=$((DURATION % 60))

# Print duration to the output file
echo "### Job duration: ${HOURS}h ${MINUTES}m ${SECONDS}s ###" >> /home/alexis.melot/dwi_preproc_recon/src/slurm/err/${SLURM_JOB_ID}.txt