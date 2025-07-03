% fastSlidingWindowDecode.m
clear; close all;

files  = {'simulation_results_OPM.mat','simulation_results_SaltPepper.mat'};
titles = {'OPM','Salt-and-Pepper'};
window_ms = 100;   % window length
step_ms   = 50;    % step size

figure('Color','w'); hold on;

for i = 1:2
    mf        = matfile(files{i}, 'Writable', false);
    labels    = mf.stimLabels(:,1);
    Nnet      = mf.Network;
    dt        = Nnet.dt;
    bins_pre  = floor(Nnet.trial.spont / dt);
    bins_stim = floor(Nnet.trial.stim  / dt);
    
    win_bins  = floor(window_ms / dt);
    step_bins = floor(step_ms   / dt);
    starts = (bins_pre+1):win_bins:(bins_pre+bins_stim-win_bins+1);
    times_ms  = (starts - bins_pre)*dt;  % x axis

    nTrials   = numel(labels);
    Nneurons  = Nnet.N;
    nWins     = numel(starts);
    resp_base = zeros(nTrials, Nneurons);
    resp_ev   = zeros(nTrials, Nneurons, nWins);

    % one‐pass over trials
    for tr = 1:nTrials
        sp       = mf.spikesAll(:,:,tr);                 % [N×T]
        csp      = cumsum(sp,2);                         % cumulative sum
        baseSum  = csp(:,bins_pre);                      % sum up to pre
        resp_base(tr,:) = baseSum';                      % baseline per neuron

        for w = 1:nWins
            e1 = starts(w);
            e2 = e1 + win_bins - 1;
            evSum = csp(:,e2) - csp(:,e1-1);              % sum in window
            resp_ev(tr,:,w) = evSum';
        end
    end

    % decode each window
    accs = nan(1,nWins);
    for w = 1:nWins
        responses = squeeze(resp_ev(:,:,w)) - resp_base;  % baseline‐subtracted
        % add the same Gaussian noise σ≈0.03
        sigma_emp = mean(std(responses,0,1));
        scale     = 0.03 / sigma_emp;
        responses = responses + scale*randn(size(responses));
        
        % 5‐fold CV ECOC‐SVM
        cv   = cvpartition(labels,'KFold',5);
        pred = []; act = [];
        for f = 1:cv.NumTestSets
            trIdx = training(cv,f); teIdx = test(cv,f);
            Xtr = responses(trIdx,:);   ytr = labels(trIdx);
            Xte = responses(teIdx,:);   yte = labels(teIdx);
            mu    = mean(Xtr,1); sigma = std(Xtr,0,1); sigma(sigma==0)=1;
            Xtr_z = (Xtr-mu)./sigma; Xte_z = (Xte-mu)./sigma;
            mdl   = fitcecoc(Xtr_z,ytr,'Learners','linear');
            p     = predict(mdl,Xte_z);
            pred  = [pred; p]; act=[act;yte];
        end
        accs(w) = mean(pred==act);
    end

    plot(times_ms, accs*100,'-o','DisplayName',titles{i});
end

xlabel('Time since onset (ms)');
ylabel('Decoding accuracy (%)');
legend('Location','best');
title('Sliding-window decoding (100 ms window, 50 ms step)');
grid on;
saveas(gcf,'SlidingWindowDecoding.png');

% % slidingWindowDecode.m
% clear; close all;
% 
% files  = {'simulation_results_OPM.mat','simulation_results_SaltPepper.mat'};
% titles = {'OPM','Salt-and-Pepper'};
% window_ms = 100;   % window length
% step_ms   = 50;    % step size
% 
% figure('Color','w'); hold on;
% 
% for i = 1:2
%     mf     = matfile(files{i}, 'Writable', false);
%     labels = mf.stimLabels(:,1);
%     Nnet   = mf.Network;
%     dt     = Nnet.dt;
%     bins_pre  = floor(Nnet.trial.spont / dt);   % 200 ms → start
%     bins_stim = floor(Nnet.trial.stim  / dt);   % 500 ms → total stim
%     win_bins  = floor(window_ms / dt);
%     step_bins = floor(step_ms   / dt);
%     starts    = (bins_pre+1):step_bins:(bins_pre+bins_stim-win_bins+1);
%     times_ms  = (starts - bins_pre) * dt;       % x-axis in ms
% 
%     accs = nan(size(starts));
%     for w = 1:numel(starts)
%         idxEv = starts(w) : (starts(w)+win_bins-1);
% 
%         % build resp matrix [nTrials×nNeurons]
%         nTrials  = numel(labels);
%         Nneurons = Nnet.N;
%         responses = zeros(nTrials, Nneurons);
%         for tr = 1:nTrials
%             sp = mf.spikesAll(:,:,tr);
%             % mean evoked minus baseline
%             responses(tr,:) = mean(sp(:,idxEv),2)' - mean(sp(:,1:bins_pre),2)';
%         end
% 
%         % add the same Gaussian noise you used previously
%         sigma_emp = mean(std(responses,0,1));
%         scale     = 0.03 / sigma_emp;  % target σ=0.03
%         responses = responses + scale * randn(size(responses));
% 
%         % decode with 5-fold CV + z-score + ECOC-SVM
%         cv = cvpartition(labels,'KFold',5);
%         preds = []; actual = [];
%         for f = 1:cv.NumTestSets
%             trIdx = training(cv,f); teIdx = test(cv,f);
%             Xtr = responses(trIdx,:);  ytr = labels(trIdx);
%             Xte = responses(teIdx,:);  yte = labels(teIdx);
%             mu    = mean(Xtr,1); sigma = std(Xtr,0,1); sigma(sigma==0)=1;
%             Xtr_z = (Xtr-mu)./sigma; Xte_z = (Xte-mu)./sigma;
%             mdl   = fitcecoc(Xtr_z, ytr, 'Learners','linear');
%             p     = predict(mdl, Xte_z);
%             preds = [preds; p]; actual = [actual; yte];
%         end
%         accs(w) = mean(preds==actual);
%     end
% 
%     plot(times_ms, accs*100, '-o','DisplayName',titles{i});
% end
% 
% xlabel('Time since onset (ms)');
% ylabel('Decoding accuracy (%)');
% legend('Location','best');
% title('Sliding-window decoding (100 ms window, 50 ms step)');
% grid on;
% saveas(gcf,'SlidingWindowDecoding.png');
