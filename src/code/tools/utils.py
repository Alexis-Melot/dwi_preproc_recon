import sys
import nibabel as nib


def extract_b0(path_dwi, output_path_b0):
    nii_img  = nib.load(path_dwi) # load image (4D) [X,Y,Z_slice,gradient_direction]
    nii_b0 = nii_img.slicer[...,0]  # b=0 volume
    nib.save(nii_b0, output_path_b0) # save b0 image as nifti
    print(f"------ Extracted b0 image saved at {output_path_b0} ------")

def add_json_sidecar(dwi_json_path, fmap_json_path):
    import json
    import os

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

if __name__ == "__main__":
    pass