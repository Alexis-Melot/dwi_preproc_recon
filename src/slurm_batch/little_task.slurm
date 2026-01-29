#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=10G
#SBATCH --time=00:10:00
#SBATCH --output=/home/alexis.melot/projects/src/slurm_err/%j.txt
#SBATCH --err=/home/alexis.melot/projects/src/slurm_err/%j.err

# Load modules
module load apptainer/1.2.5
module load conda/25.11-py313 
conda activate mri-env

# apptainer image paths
synb0disco_path=~/synb0-disco-3.1.sif
qsiprep_path=~/qsiprep-1.1.1.sif
qsirecon_path=~/qsirecon-1.1.1.sif

participant=01
bids_dir=~/projects/reduced_multimodhal/bids/
tmp_dire_name=$(date +%Y%m%d_%H%M%S)_sub-$participant

# Prepare for Synb0-DISCO : 1) extract b0 image 2) extract 
#create tmp folder for participant to generate synthetic b0 in projects/synb0disco
tmp_synb0=~/projects/synb0disco/20260127_223031_sub-01


# # Collect ouput b0-image and put it fmap/ folder of the participant
# mkdir -p $bids_dir/sub-$participant/ses-pre/fmap/
# cp $tmp_synb0/outputs/b0_u.nii.gz $bids_dir/sub-$participant/ses-pre/fmap/b0_u.nii.gz

# Modify the .json sidecar for the synthetic b0 image
PYTHONPATH=~/projects/src/code:$PYTHONPATH python -c "from utils import *; add_json_sidecar(
    '$bids_dir/sub-${participant}/ses-pre/dwi/sub-${participant}_ses-pre_dwi.json',
    '$bids_dir/sub-${participant}/ses-pre/fmap/b0_u.json')"

# # Create folder for qsiprep outputs if it doesn't exist with participant subfolder
# output_dir=~/projects/qsiprep_outputs/qsiprep_single/$tmp_dire_name
# mkdir -p $output_dir

# # Run qsiprep using Apptainer
# apptainer run --cleanenv --containall \
#     --bind $bids_dir:/mnt/rawdata \
#     --bind $output_dir:/mnt/work \
#     --bind /home/alexis.melot/license.txt:/mnt/license.txt \
#     $qsiprep_path\
#     /mnt/rawdata /mnt/work/output/$participant \
#     participant \
#     --n-cpus 32 --omp-nthreads 32 --mem 64000 \
#     --output-resolution 2 \
#     --skip-bids-validation \
#     --unringing-method mrdegibbs \
#     --work-dir /mnt/work/workdir/$participant \
#     --fs-license-file /mnt/license.txt \
#     -vv \
#     --participant-label $participant \
#     --session-id ses-pre \
#     --stop-on-first-crash

    

