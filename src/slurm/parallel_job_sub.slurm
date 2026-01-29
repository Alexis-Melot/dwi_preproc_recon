#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=32G
#SBATCH --time=10:00:00
#SBATCH --output=/home/alexis.melot/projects/src/slurm_err/%j.txt


qsiprep_path=/home/alexis.melot/qsiprep-1.1.1.sif
bids_dir=/home/alexis.melot/projects/multimodhal_bids/bids/

# set the participant id from the participants.tsv file in the bidsdir
pid=$(awk "NR==$(($SLURM_ARRAY_TASK_ID+2)){print;exit}" $bidsdir/participants.tsv | cut -f 1)
participant=$pid
tmp_dire_name=$(date +%Y%m%d_%H%M%S)_sub-$participant

# Create folder for qsiprep outputs if it doesn't exist with participant subfolder
output_dir=/home/alexis.melot/projects/qsiprep_outputs/qsiprep_single/$tmp_dire_name
mkdir -p $output_dir

# Load Apptainer module
module load apptainer/1.2.5

# Run qsiprep using Apptainer
apptainer run --cleanenv --containall \
    --bind $bids_dir:/mnt/rawdata \
    --bind $output_dir:/mnt/work \
    --bind /home/alexis.melot/license.txt:/mnt/license.txt \
    $qsiprep_path\
    /mnt/rawdata /mnt/work/output/$participant \
    participant \
    --omp-nthreads 24 \
    --mem 32000 \
    --output-resolution 2 \
    --skip-bids-validation \
    --unringing-method mrdegibbs \
    --use-syn-sdc \
    --work-dir /mnt/work/workdir/$participant \
    --fs-license-file /mnt/license.txt \
    -vv \
    --participant-label $participant \
    --session-id ses-pre \
    --stop-on-first-crash

    

