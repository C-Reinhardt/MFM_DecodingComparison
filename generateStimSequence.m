function stim = generateStimSequence(Network)
    % === Orientation Sampling Parameters ===
    nrStimuli = Network.nrStimuli;        
    nrTrialsStim = Network.nrTrialsStim;  

    % Generate orientations in [0, 180) in equal steps
    orientations = linspace(0, 180, nrStimuli + 1);
    orientations(end) = [];  

    % Repeat each orientation nrTrialsStim times
    stim = repmat(orientations, 1, nrTrialsStim);

    % Randomize trial order
    stim = stim(randperm(length(stim)));
end
