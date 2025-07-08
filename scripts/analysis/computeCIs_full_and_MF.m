% computeCIs_full_and_MF.m
clear; clc;

% 1) File lists and labels
rawFiles = { ...
  'DecodingResults_OPM.mat', ...
  'DecodingResults_Salt-and-Pepper.mat' ...
};
mfFiles  = { ...
  'MF_results_OPM.mat', ...
  'MF_results_Salt-and-Pepper.mat' ...
};
netNames = {'OPM','Salt-and-Pepper'};

% 2) Loop over networks
for i = 1:2
    name = netNames{i};
    
    % --- Raw‐population decoding ---
    R = load(rawFiles{i}, 'actual','predicted');
    n = numel(R.actual);
    k = sum(R.actual == R.predicted);
    [phat, pci] = binofit(k, n, 0.05);
    fprintf('%s raw decoding: %.1f%% [%.1f, %.1f]%% (n=%d, k=%d)\n', ...
        name, phat*100, pci(1)*100, pci(2)*100, n, k);
    
    % --- Mean‐field decoding (Poisson) ---
    M = load(mfFiles{i}, 'actual','predicted');
    n = numel(M.actual);
    k = sum(M.actual == M.predicted);
    [phat, pci] = binofit(k, n, 0.05);
    fprintf('%s mean-field decoding: %.1f%% [%.1f, %.1f]%% (n=%d, k=%d)\n\n', ...
        name, phat*100, pci(1)*100, pci(2)*100, n, k);
end
