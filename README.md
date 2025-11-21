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

- `scripts/`
  - `simulation/` – Scripts to construct the OPM and Salt-and-Pepper networks and run the spiking simulations.
  - `analysis/` – Tuning sharpness, full decoding, mean-field decoding, confidence intervals, and permutation tests.
- `data/` – Derived `.mat` files such as tuning curves and trial-wise response matrices (no raw 4.3 GB simulation files; see “Simulation data” below).
- `results/` – Compact result files (e.g. decoding summaries) used for plotting and statistics.
- `figures/` – Key figures used in the poster and analyses.
- `Poster.pdf` – Poster “Do Mean Field Models Fail in Disordered Networks?”.
- `README.md` – Project description and analysis overview.

---

## Network Simulation and Data Generation

The analyses in this repository are based on spiking network simulations of two architectures:

- An orientation preference map (OPM)–like network with spatially organized tuning.
- A Salt-and-Pepper network with disordered tuning.

All scripts required to construct these networks and run the simulations are located in:

- `scripts/simulation/`

The simulations produce two large `.mat` files:

- `simulation_results_OPM.mat`
- `simulation_results_SaltPepper.mat`

Each file contains:
- Network metadata (`Network` struct; neuron positions, connectivity, time step, trial structure, trial durations, etc.).
- Stimulus labels (`stimLabels`).
- Full spike trains for all neurons and trials (`spikesAll`).

These full simulation output files are approximately 4.3 GB each and are therefore not included in this GitHub repository.

All downstream analysis scripts in `scripts/analysis/` (tuning curves, full decoding, mean-field decoding, permutation tests, confidence intervals) assume that, if available, these simulation files are accessible on the MATLAB path (typically in the repository root).

If you require access to the full simulation files for re-analysis, please contact the author directly.

---

## Analysis Overview

---

### Tuning Sharpness Analysis

This analysis estimates the sharpness of neuronal orientation tuning by fitting a von Mises function to the mean evoked firing rates.

#### Step 1: 
`scripts/analysis/computeTuningCurves.m`  
   Computes tuning curves (neurons × stimuli) from spike data and saves them as `.mat` files.

#### Step 2:
`scripts/analysis/FitVonMises_TuningSharpness.m`  
   Loads the tuning curves, fits a von Mises function to each neuron's response, extracts the κ (kappa) parameter as a sharpness metric, and performs statistical comparisons between OPM and Salt-and-Pepper networks.

**Outputs:**
- Tuning curves are saved in `data/`
- Intermediate visualization: `figures/MeanTuning_*.png`
- Final sharpness comparison plot: `figures/VonMises_TuningSharpness_Boxplot.png`

---  

### Decoding Analysis

This analysis evaluates how well orientation information can be decoded from neural population activity in the full (non-averaged) network data.

#### Step 1:
`scripts/analysis/full_decodingAndConfusionMatrices.m`  
  Performs multi-class orientation decoding on the full-resolution spike data from the OPM and Salt-and-Pepper network using an ECOC-SVM classifier. Outputs accuracy scores and confusion matrices.

**Outputs:**
- Decoding accuracy vectors saved to `data/`:
  - `DecodingResults_OPM.mat`
  - `DecodingResults_Salt-and-Pepper.mat`
- Confusion matrices saved to `figures/`
- Optional statistical comparisons (e.g., bootstrap or permutation) may be included

These results serve as the reference decoding performance against which the mean field model (MFM) decoding results will be compared.

---

### Mean Field Decoding Analysis

This part of the analysis evaluates how well stimulus orientation can be decoded under mean field assumptions, in which neuronal responses are spatially pooled to simulate population-level readout.

#### Step 1: Extract Trial-Wise Evoked Responses

- `scripts/analysis/extractMeanFieldResponses.m`  
  Computes trial-wise evoked responses for each neuron based on full spike train data, for both OPM and Salt-and-Pepper network architectures. This serves as the input for mean field decoding.

  **Outputs** (saved to `data/`):
  - `MF_responses_OPM.mat`
  - `MF_responses_SaltPepper.mat`

#### Step 2: Decode from Mean Field Pooled Activity

- `scripts/analysis/decodeMeanFieldPoisson_ECOC.m`  
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

--- 

#### Analytic Confidence Intervals

- `scripts/analysis/computeCIs_full_and_MF.m`  
  Computes binomial (Clopper–Pearson) 95% confidence intervals on the classification accuracy for both full-model and mean-field decoders. Complements the permutation-based significance testing.

This provides an additional layer of statistical validation for the observed decoding performance.

---

### Permutation Testing for Decoder Validation

To verify that above-chance decoding does not result from spurious structure or overfitting, we performed nonparametric permutation tests on both full-model and mean-field decoding results.

#### Full Model Permutation Test

- `scripts/analysis/permutationNull_Full_BothNetworks.m`  
  Constructs an empirical null distribution of decoding accuracies by randomly permuting trial labels 1000 times. The actual decoding accuracy is then compared to this distribution to compute an empirical p-value.

  **Figure Output:**  
  - `figures/final/PermutationNull_BothNetworks.png`

#### Mean Field Permutation Test

- `scripts/analysis/permutationNull_MF_BothNetworks.m`  
  Performs the same procedure on the Poisson-sampled mean field decoding results, providing empirical validation of the observed accuracies under the mean field model.

  **Figure Output:**  
  - `figures/final/MF_PermutationNull_BothNetworks.png`
    
---

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
