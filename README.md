# Mean Field Models and the Role of Neural Architecture

This repository accompanies the poster **"Do Mean Field Models Fail in Disordered Networks?"**, presented as part of my Bachelor's thesis project in computational neuroscience.

---

## Overview

Mean Field Models (MFMs) are widely used in neuroscience to simulate large neural populations by averaging individual neuron activity. While effective in spatially organized circuits (like orientation maps in cat V1), their performance in disordered networks — like the Salt-and-Pepper layout of rodent V1 — remains unclear.

This project compares decoding performance and structural fidelity between:
- A spatially structured OPM network
- A disorganized Salt-and-Pepper network  
Both are tested at the raw spiking level and after applying MFM approximations.

---

## Key Findings

- Raw activity from both networks retains high stimulus information
- MFMs preserve decoding accuracy in structured (OPM) networks
- MFMs **fail** in Salt-and-Pepper networks — suggesting spatial averaging erases critical information
- Decoding accuracy alone can overestimate a model’s validity

---

## Contents

- `decoding_analysis.m` – Code to run raw and MFM decoding
- `plot_bargraph.m` – MATLAB script for the decoding accuracy figure
- `simulation_summary.png` – Main figure comparing activity structures
- `confusion_matrices.png` – Decoding pattern comparison
- `README.md` – You’re here

---
## Analysis Overview
### Tuning Sharpness Analysis

This analysis estimates the sharpness of neuronal orientation tuning by fitting a von Mises function to the mean evoked firing rates.

1. `scripts/analysis/computeTuningCurves.m`  
   Computes tuning curves (neurons × stimuli) from spike data and saves them as `.mat` files.

2. `scripts/analysis/FitVonMises_TuningSharpness.m`  
   Loads the tuning curves, fits a von Mises function to each neuron's response, extracts the κ (kappa) parameter as a sharpness metric, and performs statistical comparisons between OPM and Salt-and-Pepper networks.

3. Outputs:
   - Tuning curves are saved in `data/`
   - Intermediate visualization: `figures/MeanTuning_*.png`
   - Final sharpness comparison plot: `figures/VonMises_TuningSharpness_Boxplot.png`
  
### Decoding Analysis

This analysis evaluates how well orientation information can be decoded from neural population activity in the full (non-averaged) network data.

1. `scripts/analysis/full_decodingAndConfusionMatrices.m`  
  Performs multi-class orientation decoding on the full-resolution spike data from the OPM and Salt-and-Pepper network using an ECOC-SVM classifier. Outputs accuracy scores and confusion matrices.

2. Outputs:
- Decoding accuracy vectors saved to `data/`:
  - `DecodingResults_OPM.mat`
  - `DecodingResults_Salt-and-Pepper.mat`
- Confusion matrices saved to `figures/`
- Optional statistical comparisons (e.g., bootstrap or permutation) may be included

These results serve as the reference decoding performance against which the mean field model (MFM) decoding results will be compared.

### Mean Field Decoding Analysis

This part of the analysis evaluates how well stimulus orientation can be decoded under mean field assumptions, in which neuronal responses are spatially pooled to simulate population-level readout.

---

#### Step 1: Extract Trial-Wise Evoked Responses

- `scripts/analysis/extract_meanfield_responses.m`  
  Computes trial-wise evoked responses for each neuron based on full spike train data, for both OPM and Salt-and-Pepper network architectures. This serves as the input for mean field decoding.

  **Outputs** (saved to `data/`):
  - `MF_responses_OPM.mat`
  - `MF_responses_SaltPepper.mat`

---

#### Step 2: Decode from Mean Field Pooled Activity

- `scripts/analysis/decode_meanfield_poisson_ECOC.m`  
  Applies spatial pooling by grouping neurons (default: 100 neurons per group), summing their responses, and sampling Poisson-distributed spike counts. These pooled signals are used to train a linear ECOC-SVM classifier for orientation decoding, using 5-fold cross-validation.

  **Key methods:**
  - Manual z-scoring (per fold)
  - Poisson variability sampling from group means
  - ECOC-SVM decoding (linear classifiers)

  **Outputs:**
  - Decoding results saved to `results/`:
    - `MF_resultsOPM.mat`
    - `MF_results_Salt-and-Pepper.mat`
  - Confusion matrices saved to `figures/final/`:
    - `MF_results_OPM.png`
    - `MF_results_Salt-and-Pepper.png`

These results allow direct comparison between decoding performance under mean field approximations and full-model spike-based decoding.



## Figures & Poster

This repo contains key figures from the poster.  
For a PDF version of the poster or full thesis, feel free mail to: carolina.elisabeth.reinhardt@gmail.com.

---

## License

This code is available under the MIT License.  
You are free to use, adapt, and build upon this work with attribution.

---

## Author

Carolina Elisabeth Reinhardt  
Bachelor of Psychology and Neuroscience (with thesis in Computational Neuroscience)  
Maastricht University, 2025  
