function spikes = simulateTrial(Network, U)
    % simulateTrial.m
    % ------------------------------
    % Simulate a single trial of LIF neurons with both OU background noise
    % and direct voltage jitter to ensure biologically realistic variability.
    %
    % USAGE:
    %   spikes = simulateTrial(Network, U)
    %
    % INPUTS:
    %   Network – struct with fields:
    %     .dt           (time step in ms)
    %     .trial.length (trial duration in ms)
    %     .trial.spont  (pre-stimulus duration in ms)
    %     .trial.stim   (stimulus duration in ms)
    %     .N            (number of neurons)
    %   U       – [N × T] matrix of feed-forward input currents
    %
    % OUTPUT:
    %   spikes  – [N × T] logical matrix of spike events

    % Unpack
    [N, T] = size(U);
    dt     = Network.dt;

    % Neuron parameters
    C       = 0.5;      % nF
    R       = 40;       % MΩ
    E_leak  = -60;      % mV
    V_th    = -40;      % mV
    V_reset = -70;      % mV

    % OU-noise parameters
    tau_noise   = 5;     % ms
    sigma_noise = 8.0;   % mV·√ms
    alpha       = dt / tau_noise;
    beta        = sigma_noise * sqrt(dt);

    % Direct voltage jitter (white noise) parameter
    sigma_V     = 5.0;    % mV per time‐step

    % Initialize state variables
    V       = E_leak + rand(N,1)*abs(E_leak);  % random start in [E_leak, 0]
    I_noise = zeros(N,1);                      % OU current
    spikes  = false(N, T);                     % allocate output

    % Time loop
    for t = 1:T
        % Total input current = feed-forward + OU background
        Itot = U(:,t) + I_noise;

        % Euler update of membrane potential (leak + input)
        V = V + dt * (-(V - E_leak) / (R * C) + Itot / C);

        % Inject direct voltage noise
        V = V + sigma_V * randn(N,1);

        % OU noise Euler–Maruyama update
        I_noise = I_noise + (-I_noise * alpha) + (beta * randn(N,1));

        % Spike detection and reset
        fired       = V > V_th;
        spikes(fired, t) = true;
        V(fired)   = V_reset;
    end
end