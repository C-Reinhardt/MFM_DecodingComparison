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
