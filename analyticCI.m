% analyticCI.m
clear;

% YOUR peak accuracies and trial count:
opm_acc = 0.961;   % e.g. from raw decode
sp_acc  = 0.811;
nTrials = 360;

% Compute 95% binomial CIs
[phat1, pci1] = binofit(round(opm_acc*nTrials), nTrials, 0.05);
[phat2, pci2] = binofit(round(sp_acc *nTrials), nTrials, 0.05);

fprintf('OPM: %.1f%% [%.1f, %.1f]%%\n', phat1*100, pci1(1)*100, pci1(2)*100);
fprintf('SP : %.1f%% [%.1f, %.1f]%%\n', phat2*100, pci2(1)*100, pci2(2)*100);

% Two-proportion z-test (one-sided OPM>SP)
p_pool = (phat1*nTrials + phat2*nTrials)/(2*nTrials);
z = (phat1 - phat2)/sqrt(p_pool*(1-p_pool)*(2/nTrials));
pval = 1 - normcdf(z);
fprintf('P(OPM>SP) ≈ %.3f\n', pval);

% % bootstrapDecodeCI.m
% clear; close all;
% 
% files  = {'simulation_results_OPM.mat','simulation_results_SaltPepper.mat'};
% titles = {'OPM','Salt-and-Pepper'};
% window_ms = 100; step_ms = 50;
% dt = [];  % will fill per file
% 
% nBoot = 100;  % number of bootstrap repeats
% bootAcc = nan(nBoot,2);  % [boot, network]
% 
% for i = 1:2
%     % prep data exactly as in sliding window for one window of interest
%     mf     = matfile(files{i}, 'Writable', false);
%     labels = mf.stimLabels(:,1);
%     Nnet   = mf.Network;
%     if isempty(dt), dt = Nnet.dt; end
%     bins_pre = floor(Nnet.trial.spont / dt);
%     bins_stim= floor(Nnet.trial.stim  / dt);
%     % choose the window you care about, e.g. centered at 350 ms
%     center_ms = 350;
%     start_ms  = center_ms - window_ms/2;
%     starts    = bins_pre + floor(start_ms/dt);
%     idxEv     = starts : (starts + floor(window_ms/dt) -1);
% 
%     % build the raw response matrix once
%     nTrials  = numel(labels);
%     Nneurons = Nnet.N;
%     baseResp = zeros(nTrials, Nneurons);
%     for tr = 1:nTrials
%         sp = mf.spikesAll(:,:,tr);
%         baseResp(tr,:) = mean(sp(:,idxEv),2)' - mean(sp(:,1:bins_pre),2)';
%     end
%     % measure empσ and compute noise‐scale for σ≈0.03
%     sigma_emp = mean(std(baseResp,0,1));
%     scale     = 0.03 / sigma_emp;
% 
%     % now bootstrap
%     parfor b = 1:nBoot   %#ok<PFBNS>
%         rng(b);           % new seed per bootstrap
%         responses = baseResp + scale*randn(size(baseResp));
% 
%         % decode
%         cv   = cvpartition(labels,'KFold',5);
%         pred = []; act = [];
%         for f = 1:cv.NumTestSets
%             trIdx = training(cv,f); teIdx = test(cv,f);
%             Xtr = responses(trIdx,:); ytr = labels(trIdx);
%             Xte = responses(teIdx,:); yte = labels(teIdx);
%             mu    = mean(Xtr,1); sigma = std(Xtr,0,1); sigma(sigma==0)=1;
%             Xtr_z = (Xtr-mu)./sigma; Xte_z=(Xte-mu)./sigma;
%             mdl = fitcecoc(Xtr_z,ytr,'Learners','linear');
%             p   = predict(mdl,Xte_z);
%             pred = [pred; p]; act = [act; yte];
%         end
%         bootAcc(b,i) = mean(pred==act);
%     end
% end
% 
% % Summarize
% meanAcc = mean(bootAcc)*100;
% ci      = prctile(bootAcc,[2.5,97.5])*100;
% pval    = mean(bootAcc(:,1) <= bootAcc(:,2));  % fraction of OPM ≤ SP
% 
% fprintf('OPM: %.1f%% [%.1f, %.1f]%%\n', meanAcc(1), ci(1,1), ci(2,1));
% fprintf('SP : %.1f%% [%.1f, %.1f]%%\n', meanAcc(2), ci(1,2), ci(2,2));
% fprintf('P(OPM≤SP) ≈ %.3f\n', pval);
