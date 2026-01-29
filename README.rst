DWI Preprocessing and Connectome Reconstruction
=================================================

**Authors**: Alexis Mélot, Benoit Noemie
**PI**: Renaud Jardri, Paul Allen
**Affiliations**: Université de Lille, INSERM, Lille Neuroscience & Cognition lab, PSI team

---

Overview
--------

This repository provides tools and pipelines for preprocessing diffusion-weighted MRI (dMRI) data and reconstructing structural connectomes. The workflow is designed for multimodal dMRI datasets and supports advanced techniques for noise reduction, artifact correction, and connectome generation.

---

Features
--------

- **Preprocessing**: Denoising, motion correction, susceptibility distortion correction, and bias field correction.
- **Reconstruction**: Tractography and connectome generation on pre-processed dMRI data.
- **Modularity**: Scripts for local run or HPC run.
- **Compatibility**: NIfTI, BIDS data format.

---

Installation
------------

Prerequisites
^^^^^^^^^^^^^

- Load dMRI multimodal data to ``data`` folder.
- Create and initialize conda or venv python environment from the ``requirements.txt`` file.

Setup
^^^^^

1. Clone the repository::

   .. code-block:: bash

      git clone https://github.com/Alexis-Melot/dwi_preproc_recon
      cd dwi_preproc_recon
