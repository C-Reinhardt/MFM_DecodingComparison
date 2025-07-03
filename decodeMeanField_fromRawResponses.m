% decodeMeanField_fromRawResponses_Poisson_NoNaNRemoval.m
clear; close all;

files     = {'RawResponses_OPM.mat','RawResponses_SaltPepper.mat'};
titles    = {'OPM','Salt-and-Pepper'};
groupSize = 100;

for i = 1:2
    fprintf('\n=== %s Mean-Field via Poisson (fixed) ===\n', titles{i});
    S      = load(files{i}, 'responses','labels');
    resp0  = S.responses;   % [360×7200]
    labels = S.labels;      % [360×1]
    
    nTrials = size(resp0,1);
    Nn       = size(resp0,2);
    nGroups  = Nn / groupSize;
    
    % 1) Build group-sum means
    respMeanCounts = zeros(nTrials,nGroups);
    for tr = 1:nTrials
        for g = 1:nGroups
            idx = (g-1)*groupSize + (1:groupSize);
            respMeanCounts(tr,g) = sum(resp0(tr,idx));
        end
    end
    
    % 2) Poisson‐sample
    % ensure non‐negative means
respMeanCounts(respMeanCounts < 0) = 0;

    respPoisson = poissrnd(respMeanCounts);
    
    % 3) Decode with manual z-score (no NaN removal) + ECOC
    rng(1);
    cv        = cvpartition(labels,'KFold',5);
    predicted = []; actual = [];
    for f = 1:cv.NumTestSets
        trIdx = training(cv,f);
        teIdx = test(cv,   f);
        
        Xtr = double(respPoisson(trIdx,:)); ytr = labels(trIdx);
        Xte = double(respPoisson(teIdx,:)); yte = labels(teIdx);

        % manual z-scoring
        mu    = mean(Xtr, 1);                  % 1×nFeat
        sigma = std(Xtr, 0, 1);                % 1×nFeat
        sigma(sigma==0) = 1;                   % avoid 0
        Xtr_z = (Xtr - mu) ./ sigma;           % [nTr×nFeat]
        Xte_z = (Xte - mu) ./ sigma;           % [nTe×nFeat]

        % train & predict
        mdl  = fitcecoc(Xtr_z, ytr, 'Learners','linear');
        ypred= predict(mdl, Xte_z);

        predicted = [predicted; ypred];
        actual    = [actual;    yte];
    end
    
    acc = mean(predicted == actual);
    fprintf('%s MF (Poisson fixed) accuracy: %.2f%%\n', titles{i}, acc*100);

    % Confusion matrix
    stimV = unique(labels);
    cm    = confusionmat(actual, predicted, 'Order', stimV);
    cm    = cm ./ sum(cm, 2);  % normalize rows

    % Plot & save
    fig = figure('Name',['MF Poisson — ' titles{i}], 'Color','w');
    imagesc(cm); axis square; colormap(parula); colorbar;
    title(sprintf('%s MF Poisson — Acc = %.1f%%', titles{i}, acc*100));
    xlabel('Predicted'); ylabel('True');
    xticks(1:numel(stimV)); xticklabels(stimV);
    yticks(1:numel(stimV)); yticklabels(stimV);
    outFig = sprintf('MF_PoissonConfusion_%s.png', titles{i});
    saveas(fig, outFig);
    close(fig);
    
    % Save results
    outMat = sprintf('MF_PoissonResults_%s.mat', titles{i});
    save(outMat, 'predicted', 'actual', 'acc', 'stimV', 'cm');
    fprintf('→ Saved confusion: %s\n→ Saved results:   %s\n', outFig, outMat);
end
