% FitVonMises_TuningSharpness.m

clear;
close all;

% Load data
load('tuningCurves_OPM.mat', 'tuningCurves', 'stimList');
tuning_OPM = tuningCurves;
stimRad = deg2rad(stimList(:));  % column

load('tuningCurves_SaltPepper.mat', 'tuningCurves');
tuning_SP = tuningCurves;

% Von Mises function
vmFun = @(params, x) params(1) * exp(params(2) * cos(x - params(3))) + params(4);
vmErr = @(params, x, y) sum((vmFun(params, x) - y).^2);

% Fit function
fitNeuron = @(y) fminsearch(@(p) vmErr(p, stimRad, y), ...
    [range(y), 1, stimRad(y == max(y)), min(y)]);

% Fit OPM
N_OPM = size(tuning_OPM, 1);
kappa_OPM = NaN(N_OPM, 1);
for i = 1:N_OPM
    y = tuning_OPM(i, :);
    if all(y == 0), continue; end
    try
        fit = fitNeuron(y(:));
        kappa_OPM(i) = fit(2);
    end
end

% Fit SaltPepper
N_SP = size(tuning_SP, 1);
kappa_SP = NaN(N_SP, 1);
for i = 1:N_SP
    y = tuning_SP(i, :);
    if all(y == 0), continue; end
    try
        fit = fitNeuron(y(:));
        kappa_SP(i) = fit(2);
    end
end

% Clean NaNs and remove negative kappa values
kappa_OPM = kappa_OPM(~isnan(kappa_OPM));
kappa_SP  = kappa_SP(~isnan(kappa_SP));

neg_OPM = sum(kappa_OPM < 0);
neg_SP  = sum(kappa_SP < 0);

fprintf('Excluded negative κ values: OPM = %d, SP = %d\n', neg_OPM, neg_SP);

kappa_OPM = kappa_OPM(kappa_OPM >= 0);
kappa_SP  = kappa_SP(kappa_SP >= 0);

fprintf('Valid κ values (after NaN & negative removal): OPM = %d / %d, SP = %d / %d\n', ...
    numel(kappa_OPM), N_OPM, numel(kappa_SP), N_SP);

% Statistical test
[p, h] = ranksum(kappa_OPM, kappa_SP);
fprintf('Ranksum test: p = %.4e | Significant: %d\n', p, h);

% Plot
figure('Color', 'w', 'Name', 'Von Mises Tuning Sharpness (κ)');
boxplot([kappa_OPM; kappa_SP], ...
    [repmat({'OPM'}, length(kappa_OPM), 1); repmat({'Salt-Pepper'}, length(kappa_SP), 1)]);
ylabel('Von Mises \kappa');
title('Tuning Sharpness via Von Mises Fit');

% Add significance bracket with stars
hold on;
yMax = ylim();  
y_bracket = yMax(2) * 0.94;
bracket_height = yMax(2) * 0.019;
x1 = 1;
x2 = 2;
plot([x1 x1 x2 x2], ...
     [y_bracket y_bracket + bracket_height y_bracket + bracket_height y_bracket], ...
     '-k', 'LineWidth', 1.5);

% Determine stars
if p < 0.0001
    stars = '****';
elseif p < 0.001
    stars = '***';
elseif p < 0.01
    stars = '**';
elseif p < 0.05
    stars = '*';
else
    stars = 'n.s.';
end

% Add stars centered above the bracket
text((x1 + x2) / 2, y_bracket + bracket_height * 1.4, ...
     stars, 'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold');

% Save figure
saveas(gcf, 'VonMises_TuningSharpness_Boxplot.png');