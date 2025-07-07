% permutationNull_BothNetworks.m
clear; close all;

% --- 1) Configuration ---
networks   = {'OPM','Salt-and-Pepper'};
fileTpl    = 'MF_PoissonResults_%s.mat';  % expects e.g. DecodingResults_v8_OPM.mat
nPerm      = 1000;                         % # of shuffles
rng(0);                                   % for reproducibility

% --- 2) Prepare figure ---
figure('Color','w','Position',[100 100 1200 500]);
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');

% --- 3) Loop over networks ---
for iNet = 1:numel(networks)
    netName = networks{iNet};
    
    % load saved decoding outputs
    S = load(sprintf(fileTpl,netName), 'acc','actual','predicted');
    acc       = S.acc;
    actual    = S.actual;
    predicted = S.predicted;
    nTrials   = numel(actual);
    
    % build permutation-null distribution
    nullAcc = zeros(nPerm,1);
    for p = 1:nPerm
        permLabels   = actual(randperm(nTrials));
        nullAcc(p)   = mean(predicted == permLabels);
    end
    
    % empirical p-value
    p_perm = mean(nullAcc >= acc);
    
    % plot into a tile
    ax = nexttile(iNet);
    histogram(ax, nullAcc*100, 30, ...
        'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
    hold(ax,'on');
    yl = ylim(ax);
    % true accuracy line
    xline(ax, acc*100, 'r--', 'LineWidth',2);
    text(ax, acc*100+1, yl(2)*0.8, sprintf('True = %.1f%%', acc*100), ...
         'Color','r','FontWeight','bold');
    
    % labels & title
    xlabel(ax, 'Decoding accuracy (%)');
    ylabel(ax, 'Count');
    title(ax, sprintf('%s (mean-field) permutation null (p = %.3f)', netName, p_perm), ...
        'FontWeight','normal');
    box(ax,'off');
    hold(ax,'off');
end

% --- 4) Save output ---
exportgraphics(gcf, 'MF_PermutationNull_BothNetworks.png', 'Resolution',600);

% % plotMF_PermutationNulls.m
% clear; close all;
% 
% % --- 1) Configuration ---
% files = { 'MF_PoissonResults_OPM.mat', ...
%           'MF_PoissonResults_Salt-and-Pepper.mat' };
% titles = {'OPM (mean-field)','Salt-and-Pepper (mean-field)'};
% nPerms  = 1000;
% 
% % Preallocate
% trueAcc = nan(1,2);
% permAcc = nan(nPerms,2);
% pPerm   = nan(1,2);
% 
% % --- 2) Build null distributions ---
% for i = 1:2
%     % load the MF decoding results
%     S = load(files{i}, 'actual','predicted','acc');
%     actual    = S.actual(:);
%     predicted = S.predicted(:);
%     trueAcc(i)= S.acc * 100;    % convert to percent
% 
%     nTrials = numel(actual);
%     for p = 1:nPerms
%         % permute the true labels
%         permLabels   = actual(randperm(nTrials));
%         % compute accuracy against the fixed predictions
%         permAcc(p,i) = mean(predicted == permLabels) * 100;
%     end
% 
%     % empirical p-value
%     pPerm(i) = (sum(permAcc(:,i) >= trueAcc(i)) + 1) / (nPerms + 1);
% end
% 
% % --- 3) Plot side-by-side ---
% figure('Color','w','Units','pixels','Position',[100 100 800 350]);
% 
% for i = 1:2
%     ax = subplot(1,2,i);
%     histogram(ax, permAcc(:,i), 30, ...
%         'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
%     hold(ax,'on');
%       yl = ylim(ax);
%       % true accuracy line
%       plot(ax, [trueAcc(i) trueAcc(i)], yl, 'r--','LineWidth',2);
%       text(ax, trueAcc(i)+1, yl(2)*0.8, ...
%            sprintf('True = %.1f%%\np_{perm}=%.3f', ...
%                    trueAcc(i), pPerm(i)), ...
%            'Color','r','FontWeight','bold');
%     hold(ax,'off');
% 
%     title(ax, titles{i}, 'FontWeight','normal');
%     xlabel(ax, 'Decoding Accuracy (%)');
%     if i==1, ylabel(ax,'Count'); end
%     box(ax,'on');
% end
% 
% % --- 4) Increase spacing between panels ---
% ha = get(gcf,'Children');
% % ha(1) is right, ha(2) is left (reverse order)
% set(ha(1),'Position',[0.57 0.15 0.38 0.75]);  % right panel
% set(ha(2),'Position',[0.07 0.15 0.38 0.75]);  % left panel
% 
% % --- 5) Save high-res PNG ---
% print(gcf,'MF_PermutationNulls.png','-dpng','-r600');
