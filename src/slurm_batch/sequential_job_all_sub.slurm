#!/bin/bash
#SBATCH --job-name=sub-1-3
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=10:00:00
#SBATCH --output=/home/alexis.melot/projects/src/slurm_err/%j.txt

qsiprep_path=/home/alexis.melot/qsiprep-1.1.1.sif
bids_dir=/home/alexis.melot/projects/reduced_multimodhal/bids/
tmp_dire_name=$(date +%Y%m%d_%H%M%S)_sub-1-3

# Create folder for qsiprep outputs if it doesn't exist with participant subfolder
output_dir=/home/alexis.melot/projects/qsiprep_outputs/qsiprep_multi/$tmp_dire_name
mkdir -p $output_dir

# Load Apptainer module
module load apptainer/1.2.5

# Run Synb0-DISCO to generate synthetic b0 images for distortion correction

# Run qsiprep using Apptainer
apptainer run --cleanenv --containall \
    --bind $bids_dir:/mnt/rawdata \
    --bind $output_dir:/mnt/work \
    --bind /home/alexis.melot/license.txt:/mnt/license.txt \
    $qsiprep_path\
    /mnt/rawdata /mnt/work/output \
    participant \
    --n-cpus 32 --omp-nthreads 24 --mem 64000 \
    --output-resolution 2 \
    --skip-bids-validation \
    --unringing-method mrdegibbs \
    --use-syn-sdc error \
    --ignore fieldmaps \
    --work-dir /mnt/work/workdir \
    --fs-license-file /mnt/license.txt \
    -vv \
    --session-id ses-pre \
    --stop-on-first-crash

    

