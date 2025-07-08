% permutationNull_Full_BothNetworks.m
clear; close all;

% --- 1) Configuration ---
networks   = {'OPM','Salt-and-Pepper'};
fileTpl    = 'DecodingResults_%s.mat';  % expects e.g. DecodingResults_OPM.mat
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
    title(ax, sprintf('%s permutation null (p = %.3f)', netName, p_perm), ...
        'FontWeight','normal');
    box(ax,'off');
    hold(ax,'off');
end

% --- 4) Save output ---
exportgraphics(gcf, 'PermutationNull_BothNetworks.png', 'Resolution',600);
