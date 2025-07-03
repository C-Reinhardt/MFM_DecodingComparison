% extractResponsesMemorySafe.m
clear; close all;

files  = {'simulation_results_OPM.mat','simulation_results_SaltPepper.mat'};
titles = {'OPM','SaltPepper'};

for i = 1:2
    mf      = matfile(files{i}, 'Writable', false);
    labels  = mf.stimLabels(:,1);        % [360×1]
    Nnet    = mf.Network;
    
    
    dt      = Nnet.dt;                   % 0.5 ms
    bins_pre= floor(Nnet.trial.spont/dt);% 200 ms→400 bins
    bins_win= floor(400/dt);             % 400 ms→800 bins
    idxEv   = (bins_pre+1):(bins_pre+bins_win);

    nTrials = numel(labels);
    Nn      = Nnet.N;
    
    resp_mean = zeros(nTrials, Nn);
    resp_base = zeros(nTrials, Nn);

    for tr = 1:nTrials
        sp     = mf.spikesAll(:,:,tr);   % [Nn×T]
        resp_base(tr,:) = mean(sp(:,1:bins_pre),2)';
        resp_mean(tr,:) = mean(sp(:,idxEv),   2)';
    end

    responses = resp_mean - mean(resp_base,1);   % [360×7200]
    save(sprintf('RawResponses_%s.mat',titles{i}), ...
         'responses','labels','idxEv','bins_pre');
    fprintf('Saved RawResponses_%s.mat\n',titles{i});
end
