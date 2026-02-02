#!/bin/bash
#SBATCH --job-name=synb0qsi_sub01_fmap_nosyn
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=32G
#SBATCH --time=03:00:00
#SBATCH --output=/home/alexis.melot/dwi_preproc_recon/src/slurm/err/%j.txt
#SBATCH --err=/home/alexis.melot/dwi_preproc_recon/src/slurm/err/%j.err

# Start time
START_TIME=$(date +%s)

# Load modules
module load apptainer/1.2.5
module load conda/25.11-py313 
conda activate mri-env

# Apptainer image paths
synb0disco_path=~/synb0-disco-3.1.sif
qsiprep_path=~/qsiprep-1.1.1.sif
qsirecon_path=~/qsirecon-1.1.1.sif

# Define participant ID
participant=01
session=pre

# Define directories
main_dir=~/dwi_preproc_recon
bids_dir=$main_dir/data/bids
tmp_dire_name=$(date +%Y%m%d_%H%M%S)_sub-$participant
tmp_synb0=$main_dir/synb0/$tmp_dire_name
fmap_dir=$bids_dir/sub-$participant/ses-$session/fmap
sub_ses_dir=$bids_dir/sub-$participant/ses-$session

mkdir -p $tmp_synb0
mkdir -p $tmp_synb0/outputs

# extract b0 image from dwi
PYTHONPATH=$main_dir/src/code:$PYTHONPATH python -c "from tools.utils import *; extract_b0(
    '$sub_ses_dir/dwi/sub-${participant}_ses-${session}_dwi.nii.gz',
    '$tmp_synb0/b0.nii.gz')"    

# copy t1w image to tmp folder
cp $sub_ses_dir/anat/sub-${participant}_ses-${session}_T1w.nii.gz \
    $tmp_synb0/T1.nii.gz

# create acqparams.txt file required by Synb0-DISCO
echo "0 -1 0 0.04324205
0 -1 0 0.000" > $tmp_synb0/acqparams.txt

# Run Synb0-DISCO to generate synthetic b0 images for distortion correction
apptainer run -e \
    --bind $tmp_synb0/:/INPUTS \
    --bind $tmp_synb0/outputs:/OUTPUTS \
    --bind ~/license.txt:/extra/freesurfer/license.txt \
    $synb0disco_path \
    --no-topup

# Collect ouput b0-image and put it fmap/ folder of the participant
mkdir -p $fmap_dir
cp $tmp_synb0/outputs/b0_u.nii.gz $fmap_dir/sub-${participant}_ses-${session}_dir-PA_epi.nii.gz

# Modify the .json sidecar for the synthetic b0 image
PYTHONPATH=$main_dir/src/code:$PYTHONPATH python -c "from tools.utils import *; add_json_sidecar(
    '$sub_ses_dir/dwi/sub-${participant}_ses-${session}_dwi.json',
    '$fmap_dir/sub-${participant}_ses-${session}_dir-PA_epi.json')"

# Create folder for qsiprep outputs if it doesn't exist with participant subfolder
output_dir=$main_dir/qsiprep_outputs/qsiprep_single/$tmp_dire_name
mkdir -p $output_dir

# Run qsiprep using Apptainer
apptainer run --cleanenv --containall \
    --bind $bids_dir:/mnt/rawdata \
    --bind $output_dir:/mnt/work \
    --bind /home/alexis.melot/license.txt:/mnt/license.txt \
    $qsiprep_path\
    /mnt/rawdata /mnt/work/output/$participant \
    participant \
    --n-cpus 20 --omp-nthreads 20 --mem 32000 \
    --output-resolution 2 \
    --skip-bids-validation \
    --unringing-method mrdegibbs \
    --work-dir /mnt/work/workdir/$participant \
    --fs-license-file /mnt/license.txt \
    -vv \
    --participant-label $participant \
    --session-id ses-$session \
    --stop-on-first-crash



    

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
echo " \n Job duration: ${HOURS}h ${MINUTES}m ${SECONDS}s" >> /home/alexis.melot/dwi_preproc_recon/src/slurm/err/${SLURM_JOB_ID}.txt