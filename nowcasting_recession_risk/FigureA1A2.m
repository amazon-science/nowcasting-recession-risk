%% NOWCASTING RECESSION RISK
% Francesco Furno and Domenico Giannone
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Progress Message
disp('Producing Figure A1,A2...');

% Load In-Sample Results
load('./Simulations/Baseline_INS.mat');


% US
Y_US_aux = Data.US.NBER_Recession;
X_US_aux = [Data.US.CISS, Data.US.PMI_Manuf];

% Logit (Maximum Likelihood)
aux = fitglm(X_US_aux, Y_US_aux, 'Distribution', 'binomial', 'link', 'logit');
Risk.US.Baseline_MLE_Logit = aux.Fitted.Probability;

% Probit (Maximum Likelihood)
aux = fitglm(X_US_aux, Y_US_aux, 'Distribution', 'binomial', 'link', 'probit');
Risk.US.Baseline_MLE_Probit = aux.Fitted.Probability;

% Linear Probability Model (OLS)
aux = fitlm(X_US_aux, Y_US_aux);
Risk.US.Baseline_OLS = aux.Fitted;

% Nadaraya-Watson
h = [1, 1];
Risk.US.Baseline_NadarayaWatson = Nadaraya_Watson(X_US_aux, Y_US_aux, X_US_aux, h);

% Dynamic Probit (ML)
aux = fitglm([X_US_aux(2:end, :), Y_US_aux(1:end-1) ], Y_US_aux(2:end), 'Distribution', 'binomial', 'link', 'probit');
Risk.US.Baseline_MLE_Dynamic_Probit = [nan(1, 1); aux.Fitted.Probability];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% EA
Y_EA_aux = Data.EA.CEPR_Recession(EA_start_position:end, :);
X_EA_aux = [Data.EA.CISS, Data.EA.ESI];
X_EA_aux = X_EA_aux(EA_start_position:end, :);

% Logit (Maximum Likelihood)
aux = fitglm(X_EA_aux, Y_EA_aux, 'Distribution', 'binomial', 'link', 'logit');
Risk.EA.Baseline_MLE_Logit = aux.Fitted.Probability;


% Probit (Maximum Likelihood)
aux = fitglm(X_EA_aux, Y_EA_aux, 'Distribution', 'binomial', 'link', 'probit');
Risk.EA.Baseline_MLE_Probit = aux.Fitted.Probability;

% Linear Probability Model (OLS)
aux = fitlm(X_EA_aux, Y_EA_aux);
Risk.EA.Baseline_OLS = aux.Fitted;

% Nadaraya-Watson
h = [1, 1];
Risk.EA.Baseline_NadarayaWatson = Nadaraya_Watson(X_EA_aux, Y_EA_aux, X_EA_aux, h);

% Dynamic Probit (ML)
aux = fitglm([X_EA_aux(2:end, :), Y_EA_aux(1:end-1) ], Y_EA_aux(2:end), 'Distribution', 'binomial', 'link', 'probit');
Risk.EA.Baseline_MLE_Dynamic_Probit = [nan(1, 1); aux.Fitted.Probability];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run('./Subfunctions/Plot_Parameters.m');


Figure_1 = figure('Name', 'Figure A1');
set(gcf, 'Color', 'w', 'Position', Plt_size_2by1);
subplot(2, 1, 1)
hold on
plota = plot(Data.US.Date, 100 * Risk.US.Baseline.p50, 'Color', Color1, 'LineWidth', 1);
plotb = plot(Data.US.Date, 100 * Risk.US.Baseline_MLE_Logit, 'Color', Color2, 'LineWidth', 1);
plotc = plot(Data.US.Date, 100 * Risk.US.Baseline_MLE_Probit, 'Color', Color3, 'LineWidth', 1);
plotd = plot(Data.US.Date, 100 * Risk.US.Baseline_MLE_Dynamic_Probit, 'Color', 'r', 'LineWidth', 1);
plote = plot(Data.US.Date, 100 * Risk.US.Baseline_NadarayaWatson, 'Color', Color4, 'LineWidth', 1);
line([get(gca, "XLim")], [0 0], 'Color', 'k');
hold off
recessionplot;
title('United States');
xlabel('Date');
ylabel('Recession Risk');
ytickformat('percentage');
lgd1 = legend([plota, plotb, plotc, plotd, plote], 'Bayesian Logit', 'Logit (ML)', 'Probit (ML)', 'Dynamic Probit (ML)', 'Nadaraya-Watson', 'Location', 'NW', 'FontSize', 8);
set(lgd1, 'Position',[0.715878106443524 0.844240292778397 0.124038952243811 0.0773152061053627]);


subplot(2, 1, 2)
hold on
plot(Data.EA.Date, 100 * [nan(EA_start_position-1, 1); Risk.EA.Baseline.p50], 'Color', Color1, 'LineWidth', 1);
plot(Data.EA.Date, 100 * [nan(EA_start_position-1, 1); Risk.EA.Baseline_MLE_Logit], 'Color', Color2, 'LineWidth', 1);
plot(Data.EA.Date, 100 * [nan(EA_start_position-1, 1); Risk.EA.Baseline_MLE_Probit], 'Color', Color3, 'LineWidth', 1);
plot(Data.EA.Date, 100 * [nan(EA_start_position-1, 1); Risk.EA.Baseline_MLE_Dynamic_Probit], 'Color', 'r', 'LineWidth', 1);
plot(Data.EA.Date, 100 * [nan(EA_start_position-1, 1); Risk.EA.Baseline_NadarayaWatson], 'Color', Color4, 'LineWidth', 1);
line([get(gca, "XLim")], [0 0], 'Color', 'k');
hold off
recessionplot('recessions', EA_Recession_Shades);
title('Euro Area');
xlabel('Date');
ylabel('Recession Risk');
ytickformat('percentage');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Figure_2 = figure('Name', 'Figure A2');
set(gcf, 'Color', 'w', 'Position', Plt_size_2by1);
subplot(2, 1, 1)
hold on
plota = plot(Data.US.Date, 100 * Risk.US.Baseline.p50, 'Color', Color1, 'LineWidth', 1);
plotd = plot(Data.US.Date, 100 * Risk.US.Baseline_OLS, 'Color', Color2, 'LineWidth', 1);
line([get(gca, "XLim")], [0 0], 'Color', 'k');
hold off
recessionplot;
title('United States');
xlabel('Date');
ylabel('Recession Risk');
ytickformat('percentage');
legend([plota plotd], 'Bayesian Logit', 'Linear Probability Model (OLS)', 'Location', 'NE', 'FontSize', 8)

subplot(2, 1, 2)
hold on
plota = plot(Data.EA.Date, 100 * [nan(EA_start_position-1, 1); Risk.EA.Baseline.p50], 'Color', Color1, 'LineWidth', 1);
plotd = plot(Data.EA.Date, 100 * [nan(EA_start_position-1, 1); Risk.EA.Baseline_OLS], 'Color', Color2, 'LineWidth', 1);
line([get(gca, "XLim")], [0 0], 'Color', 'k');
hold off
recessionplot('recessions', EA_Recession_Shades);
title('Euro Area');
xlabel('Date');
ylabel('Recession Risk');
ytickformat('percentage');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
exportgraphics(Figure_1, './Output/Figure_A1.png', 'Resolution', 400)
exportgraphics(Figure_2, './Output/Figure_A2.png', 'Resolution', 400)





