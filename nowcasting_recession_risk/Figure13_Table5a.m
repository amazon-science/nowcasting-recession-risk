%% NOWCASTING RECESSION RISK
% Francesco Furno and Domenico Giannone
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Progress Message
disp('Producing Figure 13 and Table 5a...');

% Loading Baseline OOS
load('./Simulations/Baseline_OOS.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quarterly Series - Aggregated from Monthly

% Preparing Data
data_aux = timetable(Data.US.Date);
data_aux.Risk = Risk.US.Baseline_OOS2.p50;
data_aux.Risk_lb = Risk.US.Baseline_OOS2.p05;
data_aux.Risk_ub = Risk.US.Baseline_OOS2.p95;

% Strategy: Take first month of quarter
data_aux = retime(data_aux, 'quarterly', 'firstvalue'); 
Data.US_Quarterly.Risk = data_aux.Risk;
Data.US_Quarterly.Risk_lb = data_aux.Risk_lb;
Data.US_Quarterly.Risk_ub = data_aux.Risk_ub;

% Accuracy Assessment
Target = Data.US_Quarterly.NBER_Recession;
X_nowcast = Data.US_Quarterly.Risk;
X_SPF = Data.US_Quarterly.SPF_Anxious / 100;
[Classification.US_Quarterly.Baseline_OOS2, Brier_Scores.US_Quarterly.Baseline_OOS2] = Accuracy(Target, X_nowcast);
[Classification.US_Quarterly.SPF, Brier_Scores.US_Quarterly.SPF] = Accuracy(Target, X_SPF);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run('./Subfunctions/Plot_Parameters.m');

Figure_SPF = figure('Name', 'Figure 13');
set(gcf, 'Color', 'w', 'Position', Plt_size_1by1_long);
hold on
confidence_bands(Data.US_Quarterly.Date, 100 * Data.US_Quarterly.Risk_lb, 100 * Data.US_Quarterly.Risk_ub, Color1, transparency);
plota = plot(Data.US_Quarterly.Date, 100 * Data.US_Quarterly.Risk, 'Color', Color1, 'LineWidth', 1);
plotb = plot(Data.US_Quarterly.Date, Data.US_Quarterly.SPF_Anxious, 'Color', Color2, 'LineWidth', 1);
hold off
recessionplot;
title('United States');
xlabel('Date');
ylabel('Recession Risk');
ytickformat('percentage');
lgd1 = legend([plota, plotb], 'Nowcast - Target: NBER', 'SPF GDP Decline', 'FontSize', 8);
set(lgd1, 'Position',[0.703431438724771 0.795114483916451 0.15277030369875 0.117940196266206]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
exportgraphics(Figure_SPF, './Output/Figure_13.png', 'Resolution', 400)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Brier Scores Table
Brier_Score = {'Recession'; 'Expansion'; 'Overall'};

NBER_Nowcast     = round([Brier_Scores.US_Quarterly.Baseline_OOS2.Contraction; Brier_Scores.US_Quarterly.Baseline_OOS2.Expansion; Brier_Scores.US_Quarterly.Baseline_OOS2.Total], 3);
NBER_SPF        = round([Brier_Scores.US_Quarterly.SPF.Contraction; Brier_Scores.US_Quarterly.SPF.Expansion; Brier_Scores.US_Quarterly.SPF.Total], 3);

Table5a = table(Brier_Score, NBER_Nowcast, NBER_SPF);
writetable(Table5a, './Output/Table_5.xlsx', 'Sheet', 'NBER');

