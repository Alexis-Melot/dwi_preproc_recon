#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=10:00:00
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
bids_dir=~/projects/multimodhal_bids/bids/
tmp_dire_name=$(date +%Y%m%d_%H%M%S)_sub-$participant

# # Prepare for Synb0-DISCO : 1) extract b0 image 2) extract 
# #create tmp folder for participant to generate synthetic b0 in projects/synb0disco
# tmp_synb0=~/projects/synb0disco/$tmp_dire_name
# mkdir -p $tmp_synb0/inputs
# mkdir -p $tmp_synb0/outputs

# # extract b0 image from dwi
# PYTHONPATH=~/projects/src/code:$PYTHONPATH python -c "from utils import *; extract_b0(
#     '$bids_dir/sub-$participant/ses-pre/dwi/sub-${participant}_ses-pre_dwi.nii.gz',
#     '$tmp_synb0/b0.nii.gz')"    

# # copy t1w image to tmp folder
# cp $bids_dir/sub-$participant/ses-pre/anat/sub-${participant}_ses-pre_T1w.nii.gz \
#     $tmp_synb0/T1.nii.gz

# # create acqparams.txt file required by Synb0-DISCO
# echo "0 1 0 0.062
# 0 1 0 0.000" > $tmp_synb0/acqparams.txt

# # Run Synb0-DISCO to generate synthetic b0 images for distortion correction
# apptainer run --cleanenv --containall \
#     --bind $tmp_synb0/:/INPUTS \
#     --bind $tmp_synb0/outputs:/OUTPUTS \
#     --bind ~/license.txt:/extra/freesurfer/license.txt \
#     $synb0disco_path \
#     --notopup 

# # Collect ouput b0-image and put it fmap/ folder of the participant
# mkdir -p $bids_dir/sub-$participant/ses-pre/fmap/
# cp $tmp_synb0/outputs/b0.nii.gz $bids_dir/sub-$participant/ses-pre/fmap/b0.nii.gz

# # Create .json sidecar for the synthetic b0 image
# cp $bids_dir/sub-$participant/ses-pre/dwi/sub-${participant}_ses-pre_dwi.json \
#     $bids_dir/sub-$participant/ses-pre/fmap/b0.json

# # Modify the .json sidecar for the synthetic b0 image
# python -c 'import utils; utils.add_json_sidecar(
#     "$bids_dir/sub-$participant/ses-pre/dwi/sub-${participant}_ses-pre_dwi.json",
#     "$bids_dir/sub-$participant/ses-pre/fmap/b0.json")'


# Create folder for qsiprep outputs if it doesn't exist with participant subfolder
output_dir=~/projects/qsiprep_outputs/qsiprep_single/$tmp_dire_name
mkdir -p $output_dir

# Run qsiprep using Apptainer
apptainer run --cleanenv --containall \
    --bind $bids_dir:/mnt/rawdata \
    --bind $output_dir:/mnt/work \
    --bind /home/alexis.melot/license.txt:/mnt/license.txt \
    $qsiprep_path\
    /mnt/rawdata /mnt/work/output/$participant \
    participant \
    --n-cpus 32 --omp-nthreads 32 --mem 64000 \
    --output-resolution 2 \
    --skip-bids-validation \
    --unringing-method mrdegibbs \
    --force-syn \
    --work-dir /mnt/work/workdir/$participant \
    --fs-license-file /mnt/license.txt \
    -vv \
    --participant-label $participant \
    --session-id ses-pre \
    --stop-on-first-crash

    

