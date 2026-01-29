# DWI Preprocessing and Connectome Reconstruction

**Project for Lille Neuroscience & Cognition - PSI Team**
*Pre-process and reconstruct connectomes from multimodal diffusion MRI images.*

---

## 📌 Overview
This repository provides tools and pipelines for preprocessing diffusion-weighted MRI (dMRI) data and reconstructing structural connectomes. The workflow is designed for multimodal dMRI datasets and supports advanced techniques for noise reduction, artifact correction, and connectome generation.

---

## 🛠️ Features
- **Preprocessing**: Denoising, motion correction, susceptibility distortion correction, and bias field correction.
- **Reconstruction**: Tractography and connectome generation from multimodal dMRI.
- **Modularity**: Scripts for individual steps or end-to-end pipelines.
- **Compatibility**: Works with standard neuroimaging formats (NIfTI, BIDS).

---

## 📦 Installation

### Prerequisites
- Python 3.8+
- Required libraries: `numpy`, `nibabel`, `dipy`, `matplotlib`, `scipy`
- Optional: `ANTs` or `FSL` for advanced preprocessing

### Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/Alexis-Melot/dwi_preproc_recon
   cd dwi_preproc_recon
   ```
