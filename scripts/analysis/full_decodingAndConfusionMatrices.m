% decodeAndConfusionMatrix.m
% -------------------------------------------------------------
% Two‐stage, memory‐safe decoding with robust catch blocks
% -------------------------------------------------------------

clear; close all;

files  = {'simulation_results_OPM.mat', 'simulation_results_SaltPepper.mat'};
titles = {'OPM', 'Salt-and-Pepper'};

%% Stage 1: OPM
fprintf('=== Stage 1: %s ===\n', titles{1});
try
    mf     = matfile(files{1}, 'Writable', false);
    labels = mf.stimLabels(:,1);
    Nnet   = mf.Network;

   % --- time‐window setup (replace full‐window lines) ---
dt    = Nnet.dt;                 
spont = Nnet.trial.spont;        
stim  = Nnet.trial.stim;         

bins_pre  = floor(spont     / dt);    % 200 ms → 400 bins
bins_win  = floor(400       / dt);    % 400 ms → 800 bins
idxEv     = (bins_pre + 1) : (bins_pre + bins_win);
% → bins 401 : 1200, i.e. 200–600 ms



    nTrials  = numel(labels);
    Nneurons = Nnet.N;

    % Preallocate
    resp_mean_raw = zeros(nTrials, Nneurons);
    resp_base_raw = zeros(nTrials, Nneurons);

    % Build responses trial-by-trial
    for tr = 1:nTrials
        sp = mf.spikesAll(:,:,tr);
        resp_base_raw(tr,:) = mean(sp(:,1:bins_pre),2)';
        resp_mean_raw(tr,:) = mean(sp(:,idxEv),   2)';
    end

    % Baseline subtraction
    mean_base_all = mean(resp_base_raw,1);
    responses     = resp_mean_raw - mean_base_all;

    % Sanity check
    assert(size(responses,1)==nTrials, 'Trials (%d) ≠ labels (%d)', nTrials, numel(labels));

    % 5-fold CV + z-score + classify
    rng(1);
    cv = cvpartition(labels,'KFold',5);
    predicted = []; actual = [];
    for fold = 1:cv.NumTestSets
        trIdx = training(cv,fold);
        teIdx = test(cv,   fold);

        Xtr = responses(trIdx,:);
        ytr = labels(trIdx);
        Xte = responses(teIdx,:);
        yte = labels(teIdx);

        [Xtr_z, mu, sigma] = zscore(Xtr);
        sigma(sigma==0)=1;
        Xte_z = (Xte - mu) ./ sigma;

        mdl   = fitcecoc(Xtr_z,ytr,'Learners','linear');
        ypred = predict(mdl, Xte_z);

        predicted = [predicted; ypred];
        actual    = [actual;    yte];
    end

    % Compute accuracy & confusion
    acc    = mean(predicted==actual);
    stim_vals = unique(labels);
    cm     = confusionmat(actual,predicted,'Order',stim_vals);
    cm     = cm ./ sum(cm,2);
    

    % Save figure and results
    fig = figure('Name',titles{1},'Color','w');
    imagesc(cm); axis square; colormap(parula); colorbar;
    title(sprintf('%s — Acc = %.1f%%',titles{1},acc*100));
    xlabel('Predicted'); ylabel('True');
    xticks(1:numel(stim_vals)); xticklabels(stim_vals);
    yticks(1:numel(stim_vals)); yticklabels(stim_vals);
    outFig = sprintf('ConfusionMatrix_%s.png', titles{1});
    saveas(fig, outFig);
    close(fig);

    resultsFile = sprintf('DecodingResults_%s.mat', titles{1});
    save(resultsFile, 'predicted','actual','acc','stim_vals','cm');

    fprintf('→ OPM complete. Outputs:\n   %s\n   %s\n', outFig, resultsFile);

catch
    le = lasterror;
    warning('Error during OPM stage: %s', le.message);
    rethrow(lasterror);
end

%% Stage 2: Salt‐and‐Pepper
fprintf('\n=== Stage 2: %s ===\n', titles{2});
try
    mf     = matfile(files{2}, 'Writable', false);
    labels = mf.stimLabels(:,1);
    Nnet   = mf.Network;

   % --- time‐window setup (replace full‐window lines) ---
dt    = Nnet.dt;                 
spont = Nnet.trial.spont;        
stim  = Nnet.trial.stim;         

bins_pre  = floor(spont     / dt);    % 200 ms → 400 bins
bins_win  = floor(400       / dt);    % 400 ms → 800 bins
idxEv     = (bins_pre + 1) : (bins_pre + bins_win);
% → bins 401 : 1200, i.e. 200–600 ms



    nTrials  = numel(labels);
    Nneurons = Nnet.N;

    resp_mean_raw = zeros(nTrials, Nneurons);
    resp_base_raw = zeros(nTrials, Nneurons);

    for tr = 1:nTrials
        sp = mf.spikesAll(:,:,tr);
        resp_base_raw(tr,:) = mean(sp(:,1:bins_pre),2)';
        resp_mean_raw(tr,:) = mean(sp(:,idxEv),   2)';
    end

    mean_base_all = mean(resp_base_raw,1);
    responses     = resp_mean_raw - mean_base_all;

    assert(size(responses,1)==nTrials, 'Trials (%d) ≠ labels (%d)', nTrials, numel(labels));

    rng(1);
    cv = cvpartition(labels,'KFold',5);
    predicted = []; actual = [];
    for fold = 1:cv.NumTestSets
        trIdx = training(cv,fold);
        teIdx = test(cv,   fold);

        Xtr = responses(trIdx,:);
        ytr = labels(trIdx);
        Xte = responses(teIdx,:);
        yte = labels(teIdx);

        [Xtr_z, mu, sigma] = zscore(Xtr);
        sigma(sigma==0)=1;
        Xte_z = (Xte - mu) ./ sigma;

        mdl   = fitcecoc(Xtr_z,ytr,'Learners','linear');
        ypred = predict(mdl, Xte_z);

        predicted = [predicted; ypred];
        actual    = [actual;    yte];
    end

    acc    = mean(predicted==actual);
    stim_vals = unique(labels);
    cm     = confusionmat(actual,predicted,'Order',stim_vals);
    cm     = cm ./ sum(cm,2);

    fig = figure('Name',titles{2},'Color','w');
    imagesc(cm); axis square; colormap(parula); colorbar;
    title(sprintf('%s — Acc = %.1f%%',titles{2},acc*100));
    xlabel('Predicted'); ylabel('True');
    xticks(1:numel(stim_vals)); xticklabels(stim_vals);
    yticks(1:numel(stim_vals)); yticklabels(stim_vals);
    outFig = sprintf('ConfusionMatrix_%s.png', titles{2});
    saveas(fig, outFig);
    close(fig);

    resultsFile = sprintf('DecodingResults_%s.mat', titles{2});
    save(resultsFile, 'predicted','actual','acc','stim_vals','cm');

    fprintf('→ Salt-and-Pepper complete. Outputs:\n   %s\n   %s\n', outFig, resultsFile);

catch
    le = lasterror;
    warning('Error during Salt-and-Pepper stage: %s', le.message);
    % no rethrow, OPM results remain safe
end
