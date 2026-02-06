import os
import subprocess
import datetime
import json

ACQPARAMS_SYNB0 = "0 -1 0 0.04324205 \n0 -1 0 0.000"

def extract_b0(path_dwi, output_path_b0):
    import nibabel as nib
    nii_img  = nib.load(path_dwi) # load image (4D) [X,Y,Z_slice,gradient_direction]
    nii_b0 = nii_img.slicer[...,0]  # b=0 volume
    nib.save(nii_b0, output_path_b0) # save b0 image as nifti
    print(f"Extracted b0 image saved at {output_path_b0}")

def add_json_sidecar(dwi_json_path, fmap_json_path):
    # Load DWI JSON sidecar
    with open(dwi_json_path, 'r') as json_file:
        dwi_json = json.load(json_file)

    dwi_json['B0FieldIdentifier'] = 'synb0'
    # Save JSON to dwi_json_path
    with open(dwi_json_path, 'w') as json_file:
        json.dump(dwi_json, json_file, indent=4)

    # Update fields
    dwi_json['PhaseEncodingDirection'] = 'i-'
    dwi_json['TotalReadoutTime'] = 0.01
    dwi_json['EffectiveEchoSpacing'] = 0.0
    dwi_json['IntendedFor'] = os.path.abspath(dwi_json_path).replace('\\', '/').split('bids/')[-1].replace('.json', '.nii.gz')
    

    # Save updated JSON sidecar at new_json_path
    with open(fmap_json_path, 'w') as json_file:
        json.dump(dwi_json, json_file, indent=4)
    
    print(f"------ Updated JSON sidecars ------ ")                           

def synb0_job_array(task_id, session, bids_dir, synb0_dir, synb0_sif_path, fsl_license_path):
    #list subjects
    subjects = sorted([d for d in os.listdir(bids_dir) if d.startswith('sub-')])
    subject_id = subjects[task_id - 1]  # task_id starts from 1 in SLURM

    # sub-dir paths
    sub_ses_dir = os.path.join(bids_dir, subject_id, f"ses-{session}")
    dwi_dir = os.path.join(sub_ses_dir, 'dwi')
    anat_dir = os.path.join(sub_ses_dir, 'anat')
    fmap_dir = os.path.join(sub_ses_dir, 'fmap')

    # create tmp directory for synb0 
    tmp_dir_name = datetime.datetime.now().strftime("%Y%m%d_%H%M%S") + f"_{subject_id}"
    tmp_synb0 = os.path.join(synb0_dir, tmp_dir_name)
    outputs_dir = os.path.join(tmp_synb0, 'outputs')
    os.makedirs(tmp_synb0, exist_ok=True)
    os.makedirs(outputs_dir, exist_ok=True)
    print(f"------ Folders created for syb0 ------ ")

    ## Prepare inputs for Synb0
    # extract b0 image from dwi
    extract_b0(
        os.path.join(dwi_dir, f"{subject_id}_ses-{session}_dwi.nii.gz"),
        os.path.join(tmp_synb0, 'b0.nii.gz')
    )
    os.chmod(os.path.join(tmp_synb0, 'b0.nii.gz'), 0o644)  # Ensure read permissions for Singularity
    print(f"------ b0 image extracted for {subject_id} ------ ")

    # copy t1w image to tmp folder
    os.system(f"cp {os.path.join(anat_dir, f'{subject_id}_ses-{session}_T1w.nii.gz')} {os.path.join(tmp_synb0, 'T1.nii.gz')}")
    os.chmod(os.path.join(tmp_synb0, 'T1.nii.gz'), 0o644)  # Ensure read permissions for Singularity
    print(f"------ T1w image copied for {subject_id} ------ ")

    # create acqparams.txt file required by Synb0-DISCO
    with open(os.path.join(tmp_synb0, 'acqparams.txt'), 'w') as f:
        f.write(ACQPARAMS_SYNB0)
    os.chmod(os.path.join(tmp_synb0, 'acqparams.txt'), 0o644)  # Ensure read permissions for Singularity
    print(f"------ acqparams.txt created for {subject_id} ------ ")

    # Run Synb0-DISCO to generate synthetic b0 images for distortion correction
    os.system(f"apptainer run -e \
              --bind {tmp_synb0}:/INPUTS \
              --bind {outputs_dir}:/OUTPUTS \
              --bind {fsl_license_path}:/extra/freesurfer/license.txt \
              {synb0_sif_path}")
    print(f"------ Synb0-DISCO executed for {subject_id} ------ ")

    # Collect ouput b0-image and put it fmap/ folder of the participant
    os.makedirs(fmap_dir, exist_ok=True)
    os.system(f"cp {os.path.join(outputs_dir, 'b0_u.nii.gz')} {os.path.join(fmap_dir, f'{subject_id}_ses-{session}_dir-PA_epi.nii.gz')}")
    print(f"------ Synthetic b0 image copied for {subject_id} ------ ")

    # Add the .json sidecar for the synthetic b0 image
    add_json_sidecar(
        os.path.join(dwi_dir, f"{subject_id}_ses-{session}_dwi.json"),
        os.path.join(fmap_dir, f"{subject_id}_ses-{session}_dir-PA_epi.json")
    )
    print(f"------ JSON sidecar created for {subject_id} ------ ")
    print(f"------ Synb0-DISCO processing completed for {subject_id} ------ ")


# tmp_dire_name=$(date +%Y%m%d_%H%M%S)_sub-multi

# # Create folder for qsiprep outputs if it doesn't exist with participant subfolder
# output_dir=$main_dir/results/qsiprep_outputs/qsiprep_multi/$tmp_dire_name
# mkdir -p $output_dir

# # Run qsiprep using Apptainer
# apptainer run --cleanenv --containall \
#     --bind $bids_dir:/mnt/rawdata \
#     --bind $output_dir:/mnt/work \
#     --bind /home/alexis.melot/license.txt:/mnt/license.txt \
#     $qsiprep_path \
#     /mnt/rawdata /mnt/work/output/ \
#     participant \
#     --omp-nthreads 16 --mem 32000 \
#     --output-resolution 2 \
#     --skip-bids-validation \
#     --unringing-method mrdegibbs \
#     --work-dir /mnt/work/workdir/ \
#     --fs-license-file /mnt/license.txt \
#     -vv \
#     --session-id ses-$session \
#     --stop-on-first-crash
    

def qsiprep_job_array(task_id, session, bids_dir, qsiprep_dir, qsiprep_sif_path, fsl_license_path):
    #list subjects
    subjects = sorted([d for d in os.listdir(bids_dir) if d.startswith('sub-')])
    subject_id = subjects[task_id - 1]  # task_id starts from 1 in SLURM

    # sub-dir paths
    tmp_dir_name = datetime.datetime.now().strftime("%Y%m%d_%H%M%S") + f"_{subject_id}"
    output_dir = os.path.join(qsiprep_dir, tmp_dir_name)
    os.makedirs(output_dir, exist_ok=True)
    print(f"------ Output folder created for qsiprep ------ ")

    # Run qsiprep using Singularity
    os.system(f"apptainer run --cleanenv --containall \
                --bind {bids_dir}:/mnt/rawdata \
                --bind {output_dir}:/mnt/work \
                --bind {fsl_license_path}:/mnt/license.txt \
                {qsiprep_sif_path} \
                /mnt/rawdata /mnt/work/output/ \
                participant \
                --omp-nthreads 16 --mem 32000 \
                --output-resolution 2 \
                --skip-bids-validation \
                --unringing-method mrdegibbs \
                --work-dir /mnt/work/workdir/ \
                --fs-license-file /mnt/license.txt \
                -vv \
                --participant-label {subject_id} \
                --session-id ses-{session} \
                --stop-on-first-crash")
    
    print(f"------ qsiprep executed for {subject_id} ------ ")


if __name__ == "__main__":
    pass