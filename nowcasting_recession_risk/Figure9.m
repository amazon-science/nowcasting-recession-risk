%% NOWCASTING RECESSION RISK
% Francesco Furno and Domenico Giannone
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Progress Message
disp('Producing Figure 9...');

% Loading Baseline In-Sample
load('./Simulations/Baseline_INS.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run('./Subfunctions/Plot_Parameters.m');


Figure_Sahm = figure('Name', 'Figure 9');
set(gcf, 'Color', 'w', 'Position', Plt_size_2by1)
subplot(2, 1, 1)
hold on
confidence_bands(Data.US.Date, 100 * Risk.US.Baseline.p05, 100 * Risk.US.Baseline.p95, Color1, transparency);
plota = plot(Data.US.Date, 100 * Risk.US.Baseline.p50, 'Color', Color1, 'LineWidth', 1);
hold off
recessionplot;
title('US Recession Risk');
xlabel('Date');
ylabel('Recession Risk');
ytickformat('percentage');


subplot(2, 1, 2)
hold on
plotb = plot(Data.US.Date, Data.US.SahmRule_Unemp, 'Color', Color1, 'LineWidth', 1);
ax = get(gca); line(ax.XLim, [0.5, 0.5], 'Color', 'k', 'LineStyle', '--')
hold off
recessionplot;
title('US Sahm-Rule');
xlabel('Date');
ylabel('Sahm-Rule');
ytickformat('percentage');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
exportgraphics(Figure_Sahm, './Output/Figure_9.png', 'Resolution', 400)





