function [U, stim_theta] = generateInputTrial(Network, stim_theta)
    N = Network.N;
    T = Network.trial.length / Network.dt;
    U = zeros(N, T, 'single');

    % Convert stimulus to radians
    stim_theta = stim_theta * pi / 180;

    % Cosine tuning based input
    theta_pref = Network.theta_pref;

    if strcmp(Network.mapType, 'OPM')
        kappa = 5;    % Narrow tuning for cat-like OPM
    else
        kappa = 1.5;  % Broad tuning for salt-and-pepper
    end

    % Cosine tuning shape
    input_strength = 1;
    tuning = input_strength * exp(kappa * cos(2 * (theta_pref - stim_theta)));
    tuning = tuning - min(tuning);
    tuning = tuning / max(tuning);

    % Add stimulus only during stimulus window
    stim_on  = (Network.trial.spont) / Network.dt + 1;
    stim_off = (Network.trial.spont + Network.trial.stim) / Network.dt;
    duration = stim_off - stim_on + 1;
    U(:, stim_on:stim_off) = tuning .* ones(1, duration, 'single');

    % — INPUT JITTER: Add Gaussian noise to the drive —
    sigma_in = 1.5; 
    U = U + sigma_in * sqrt(Network.dt) * randn(size(U), 'single');
end
