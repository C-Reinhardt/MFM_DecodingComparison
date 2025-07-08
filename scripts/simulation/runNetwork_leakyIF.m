% === Trialwise Simulation with Auto-Labeled Output Folder ===

clear all;

% === Network Setup ===
Nx = 120;
Ny = 60;
N = Nx * Ny;
Network.N = N;
Network.mapType = 'SaltPepper';  % Change to 'OPM' or 'SaltPepper' when needed

[X, Y] = meshgrid(1:Nx, 1:Ny);
X = X(:); Y = Y(:);
Network.X = X;
Network.Y = Y;

switch Network.mapType
    case 'OPM'
        theta_pref = mod(pi * X / Nx, pi);
    case 'SaltPepper'
        theta_pref = pi * rand(N, 1);
    otherwise
        error('Unknown mapType');
end

Network.theta_pref = theta_pref;

% Neuron type assignment
NE = round(0.8 * N);
NI = N - NE;
indexE = 1:NE;
indexI = (NE+1):N;

% Trial parameters
Network.dt = 0.5;
Network.trial.length = 1000;  % ms
Network.trial.spont = 200;   % ms
Network.trial.stim = 500;    % ms
Network.nrStimuli = 12;      % 12 stimuli: 0, 15, ..., 165°
Network.nrTrialsStim = 30;

% === Auto-Named Output Folder ===
outputFolder = ['Spikes_' Network.mapType];
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% === Stimulus Sequence Generation ===
stimSeq = generateStimSequence(Network);  
nrTrials = length(stimSeq);
Network.nrTrials = nrTrials;

stimLabels = zeros(nrTrials, 1);

fprintf('Simulating %d trials using these orientations (°): %s\n', nrTrials, mat2str(unique(stimSeq)));

for iTrial = 1:nrTrials
    stim_theta = stimSeq(iTrial);
    [U, ~] = generateInputTrial(Network, stim_theta);

    spikes = simulateTrial(Network, U);

    save(fullfile(outputFolder, sprintf('spikes_trial_%03d.mat', iTrial)), 'spikes', '-v7.3');
    stimLabels(iTrial) = stim_theta;

    clear U spikes
    fprintf('Trial %d / %d done.\n', iTrial, nrTrials);
end

% Save stimulus labels and metadata
save(fullfile(outputFolder, 'stimLabels.mat'), 'stimLabels');
save(fullfile(outputFolder, 'meta.mat'), 'Network');


% === Compile into simulation_results_*.mat file in CHUNKS ===
compileResults = true;

if compileResults
    disp('Compiling all trials into a single .mat file in chunks (safe and efficient)...');
    fclose('all');

    trialFiles = dir(fullfile(outputFolder, 'spikes_trial_*.mat'));
    nrTrials = length(trialFiles);
    if nrTrials == 0
        error('No spike files found in output folder.');
    end

    testSpike = load(fullfile(outputFolder, trialFiles(1).name));
    [N, T] = size(testSpike.spikes);

    load(fullfile(outputFolder, 'stimLabels.mat'));
    load(fullfile(outputFolder, 'meta.mat'));

    outputMatFile = ['simulation_results_' Network.mapType '.mat'];
    save(outputMatFile, 'stimLabels', '-v7.3');  % Ensure v7.3

    m = matfile(outputMatFile, 'Writable', true);
    m.Network = Network;
    m.spikesAll = false(N, T, nrTrials);

    chunkSize = 10;  % Number of trials per chunk to reduce memory use
    tic;
    for iStart = 1:chunkSize:nrTrials
        iEnd = min(iStart + chunkSize - 1, nrTrials);
        for i = iStart:iEnd
            trialData = load(fullfile(outputFolder, sprintf('spikes_trial_%03d.mat', i)));
            m.spikesAll(:, :, i) = trialData.spikes;
        end
        elapsed = toc;
        fprintf('  Trials %d to %d written (elapsed: %.1f s)\n', iStart, iEnd, elapsed);
    end

    disp(['Saved combined result to ' outputMatFile]);
end


