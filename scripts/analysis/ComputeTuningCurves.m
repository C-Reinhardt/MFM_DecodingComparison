% ComputeTuningCurves.m

clear; clc;

% Choose architecture
architecture = 'SaltPepper';  % OPM or 'SaltPepper'
matObj = matfile(['simulation_results_' architecture '.mat']);

% Load metadata
Network = matObj.Network;
stimLabels = matObj.stimLabels;
[N, T, nrTrials] = size(matObj, 'spikesAll');

stimList = unique(stimLabels);
nStim = numel(stimList);

% Time window (evoked)
idxEv = Network.trial.spont / Network.dt + (1:Network.trial.stim / Network.dt);

% Preallocate
tuningCurves = zeros(N, nStim);

% Compute tuning curves
for s = 1:nStim
    stim = stimList(s);
    trials = find(stimLabels == stim);

    fprintf('Processing stimulus %d° (%d trials)...\n', stim, numel(trials));

    sumResponse = zeros(N, 1);
    for i = 1:numel(trials)
        trialIdx = trials(i);
        dataChunk = matObj.spikesAll(:, idxEv, trialIdx);
        sumResponse = sumResponse + mean(dataChunk, 2);
    end

    tuningCurves(:, s) = sumResponse / numel(trials);
end

% Save
save(['tuningCurves_' architecture '.mat'], 'tuningCurves', 'stimList');

% Plot mean tuning curve
figure('Color', 'w');
plot(stimList, mean(tuningCurves, 1), '-o', 'LineWidth', 2);
xlabel('Stimulus Orientation (°)');
ylabel('Mean Firing Rate (a.u.)');
title(['Mean Tuning Curve – ' architecture]);
grid on;
saveas(gcf, ['MeanTuning_' architecture '.png']);
