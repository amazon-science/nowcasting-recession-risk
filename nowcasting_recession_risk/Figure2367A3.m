%% NOWCASTING RECESSION RISK
% Francesco Furno and Domenico Giannone
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Progress Message
disp('Producing Figures 2,3,6,7,A3...');

refresh_estimates = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (refresh_estimates == 1)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load Data and Plot Parameters
    load('./Data/Data.mat');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Setting Parameters
    Parameters = Get_Parameters();
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Estimation In-Sample for US
    Y = Data.US.NBER_Recession;
    varlist = {'CISS', 'PMI_Manuf'}; 
    
    
    for variable_index = 1 : length(varlist)
        var_name_aux = varlist{variable_index};
        X_US_aux = Data.US.(var_name_aux);
        Posterior_aux = Bayesian_Logit(Y, X_US_aux, Parameters);
        Risk.US.(var_name_aux) = Recession_Risk_Computation(Posterior_aux, X_US_aux);
        [Classification.US.(var_name_aux), Brier_Scores.US.(var_name_aux)] = Accuracy(Y, Risk.US.(var_name_aux).p50);
    end
    
    
    % Baseline: PMI and CISS
    X_US_aux = [Data.US.CISS, Data.US.PMI_Manuf];
    Posterior_aux = Bayesian_Logit(Y, X_US_aux, Parameters);
    Risk.US.Baseline = Recession_Risk_Computation(Posterior_aux, X_US_aux);
    [Classification.US.Baseline, Brier_Scores.US.Baseline] = Accuracy(Y, Risk.US.Baseline.p50);
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Estimation In-Sample for EA
    Y = Data.EA.CEPR_Recession(EA_start_position:end, :);
    varlist = {'CISS', 'ESI'}; 
    
    
    for variable_index = 1 : length(varlist)
        var_name_aux = varlist{variable_index};
        X_EA_aux = Data.EA.(var_name_aux);
        X_EA_aux = X_EA_aux(EA_start_position:end, :);
        Posterior_aux = Bayesian_Logit(Y, X_EA_aux, Parameters);
        Risk.EA.(var_name_aux) = Recession_Risk_Computation(Posterior_aux, X_EA_aux);
        [Classification.EA.(var_name_aux), Brier_Scores.EA.(var_name_aux)] = Accuracy(Y, Risk.EA.(var_name_aux).p50);
    end
    
    
    % Baseline: PMI and CISS
    X_EA_aux = [Data.EA.CISS, Data.EA.ESI];
    X_EA_aux = X_EA_aux(EA_start_position:end, :);
    Posterior_aux = Bayesian_Logit(Y, X_EA_aux, Parameters);
    Risk.EA.Baseline = Recession_Risk_Computation(Posterior_aux, X_EA_aux);
    [Classification.EA.Baseline, Brier_Scores.EA.Baseline] = Accuracy(Y, Risk.EA.Baseline.p50);

    clearvars -except Data Risk Classification Brier_Scores EA_Recession_Shades Parameters EA_start_position
    save('./Simulations/Baseline_INS.mat');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    load('./Simulations/Baseline_INS.mat');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualization
run('./Subfunctions/Plot_Parameters.m');


%%%%%%%%%%%%%%%%%%%%%
% Predictors
Figure_Predictors = figure('Name', 'Figure 2');
set(gcf, 'Color', 'w', 'Position', Plt_size_2by2)
subplot(2, 2, 1)
hold on
plot(Data.US.Date, Data.US.PMI_Manuf, 'Color', Color1, 'LineWidth', 1);
hold off
recessionplot;
title('United States');
xlabel('Date');
ylabel('PMI Manufacturing');
ylim([30, 70]);

subplot(2, 2, 3)
hold on
plot(Data.US.Date, Data.US.CISS, 'Color', Color1, 'LineWidth', 1);
hold off
recessionplot;
xlabel('Date');
ylabel('CISS')
ylim([0, 1])

subplot(2, 2, 2)
hold on
plot(Data.EA.Date, Data.EA.ESI, 'Color', Color1, 'LineWidth', 1);
xlim([datetime([1980, 1, 1]), datetime([2021, 12, 31]) ]);
recessionplot('recessions', EA_Recession_Shades);
hold off
title('Euro Area');
xlabel('Date');
ylabel('Economic Sentiment Indicator');
ylim([60, 120])


subplot(2, 2, 4)
hold on
plot(Data.EA.Date, Data.EA.CISS, 'Color', Color1, 'LineWidth', 1);
recessionplot('recessions', EA_Recession_Shades);
hold off
xlabel('Date');
ylabel('CISS')
ylim([0, 1])


%%%%%%%%%%%%%%%%%%%%%
% Baseline - In-Sample
Figure_Baseline_InSample = figure('Name', 'Figure 3');
set(gcf, 'Color', 'w', 'Position', Plt_size_2by1)
subplot(2, 1, 1)
hold on
confidence_bands(Data.US.Date, 100 * Risk.US.Baseline.p05, 100 * Risk.US.Baseline.p95, Color1, transparency);
plot(Data.US.Date, 100 * Risk.US.Baseline.p50, 'Color', Color1, 'LineWidth', 1);
hold off
recessionplot;
title('United States');
xlabel('Date');
ylabel('Recession Risk');
ytickformat('percentage');

subplot(2, 1, 2)
hold on
confidence_bands(Data.EA.Date, 100 * [nan(EA_start_position-1, 1); Risk.EA.Baseline.p05], 100 * [nan(EA_start_position-1, 1); Risk.EA.Baseline.p95], Color1, transparency);
plot(Data.EA.Date, 100 * [nan(EA_start_position-1, 1); Risk.EA.Baseline.p50], 'Color', Color1, 'LineWidth', 1);
hold off
recessionplot('recessions', EA_Recession_Shades);
title('Euro Area');
xlabel('Date');
ylabel('Recession Risk');
ytickformat('percentage');


%%%%%%%%%%%%%%%%%%%%%
% US - Macro vs Financial - In-Sample
Figure_InSample_MacroFinance_US = figure('Name', 'Figure 6');
set(gcf, 'Color', 'w', 'Position', Plt_size_2by1)
subplot(2, 1, 1)
hold on
confidence_bands(Data.US.Date, 100 * Risk.US.Baseline.p05, 100 * Risk.US.Baseline.p95, Color1, transparency);
plot(Data.US.Date, 100 * Risk.US.Baseline.p50, 'Color', Color1, 'LineWidth', 1);
hold off
recessionplot;
title('United States');
xlabel('Date');
ylabel('Recession Risk');
ytickformat('percentage');


subplot(2, 1, 2)
hold on
confidence_bands(Data.US.Date, 100 * Risk.US.PMI_Manuf.p05, 100 * Risk.US.PMI_Manuf.p95, Color2, transparency);
plotb = plot(Data.US.Date, 100 * Risk.US.PMI_Manuf.p50, 'Color', Color2, 'LineWidth', 1);

confidence_bands(Data.US.Date, 100 * Risk.US.CISS.p05, 100 * Risk.US.CISS.p95, Color3, transparency);
plotc = plot(Data.US.Date, 100 * Risk.US.CISS.p50, 'Color', Color3, 'LineWidth', 1);
hold off
recessionplot;
xlabel('Date');
ylabel('Recession Risk');
ytickformat('percentage');
lgd1 = legend([plotb, plotc], 'Macro', 'Financial');
set(lgd1, 'Position',[0.752251498964408 0.391391908648752 0.101998973402959 0.0603228531455022]);


%%%%%%%%%%%%%%%%%%%%%
% EA - Macro vs Financial - In-Sample
Figure_InSample_MacroFinance_EA = figure('Name', 'Figure A3');
set(gcf, 'Color', 'w', 'Position', Plt_size_2by1)
subplot(2, 1, 1)
hold on
confidence_bands(Data.EA.Date, 100 * [nan(EA_start_position-1, 1); Risk.EA.Baseline.p05], 100 * [nan(EA_start_position-1, 1); Risk.EA.Baseline.p95], Color1, transparency);
plot(Data.EA.Date, 100 * [nan(EA_start_position-1, 1); Risk.EA.Baseline.p50], 'Color', Color1, 'LineWidth', 1);
hold off
recessionplot('recessions', EA_Recession_Shades);
title('Euro Area');
xlabel('Date');
ylabel('Recession Risk');
ytickformat('percentage');

subplot(2, 1, 2)
hold on
confidence_bands(Data.EA.Date, 100 * [nan(EA_start_position-1, 1); Risk.EA.ESI.p05], 100 * [nan(EA_start_position-1, 1); Risk.EA.ESI.p95], Color2, transparency);
plotb = plot(Data.EA.Date, 100 * [nan(EA_start_position-1, 1); Risk.EA.ESI.p50], 'Color', Color2, 'LineWidth', 1);

confidence_bands(Data.EA.Date, 100 * [nan(EA_start_position-1, 1); Risk.EA.CISS.p05], 100 * [nan(EA_start_position-1, 1); Risk.EA.CISS.p95], Color3, transparency);
plotc = plot(Data.EA.Date, 100 * [nan(EA_start_position-1, 1); Risk.EA.CISS.p50], 'Color', Color3, 'LineWidth', 1);
hold off
recessionplot('recessions', EA_Recession_Shades);
xlabel('Date');
ylabel('Recession Risk');
ytickformat('percentage');
lgd1 = legend([plotb, plotc], 'Macro', 'Financial');
set(lgd1, 'Position',[0.184675617094022 0.374408212996578 0.101998973402959 0.0603228531455022]);


%%%%%%%%%%%%%%%%%%%%%
% Brier Scores Accuracy
X_US_aux = [Brier_Scores.US.Baseline.Calibration Brier_Scores.US.Baseline.Refinement; Brier_Scores.US.PMI_Manuf.Calibration Brier_Scores.US.PMI_Manuf.Refinement; ...
    Brier_Scores.US.CISS.Calibration Brier_Scores.US.CISS.Refinement];
X_US_aux2 = [Brier_Scores.US.Baseline.Total; Brier_Scores.US.PMI_Manuf.Total; Brier_Scores.US.CISS.Total];

X_EA_aux = [Brier_Scores.EA.Baseline.Calibration Brier_Scores.EA.Baseline.Refinement; Brier_Scores.EA.ESI.Calibration Brier_Scores.EA.ESI.Refinement; ...
    Brier_Scores.EA.CISS.Calibration Brier_Scores.EA.CISS.Refinement];
X_EA_aux2 = [Brier_Scores.EA.Baseline.Total; Brier_Scores.EA.ESI.Total; Brier_Scores.EA.CISS.Total];

X_labels_aux = categorical({'Macro&Financial', 'Macro', 'Financial'});
X_labels_aux = reordercats(X_labels_aux, {'Macro&Financial', 'Macro', 'Financial'});


Figure_Baseline_Brier = figure('Name', 'Figure 7');
set(gcf, 'Color', 'w', 'Position', Plt_size_Brier)
subplot(1, 2, 1)
hold on
bar(X_labels_aux, X_US_aux, 'stacked');
plot(X_labels_aux, X_US_aux2, 'o', 'MarkerEdgeColor', 'k', 'MarkerSize', 5, 'MarkerFaceColor', 'k')
hold off
ylabel('Brier Score');
title('US');
legend('Calibration', 'Refinement', 'Location', 'NW')


subplot(1, 2, 2)
hold on
bar(X_labels_aux, X_EA_aux, 'stacked');
plot(X_labels_aux, X_EA_aux2, 'o', 'MarkerEdgeColor', 'k', 'MarkerSize', 5, 'MarkerFaceColor', 'k')
hold off
ylabel('Brier Score')
title('EA')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
exportgraphics(Figure_Predictors, './Output/Figure_2.png', 'Resolution', 400)
exportgraphics(Figure_Baseline_InSample, './Output/Figure_3.png', 'Resolution', 400)
exportgraphics(Figure_InSample_MacroFinance_US, './Output/Figure_6.png', 'Resolution', 400)
exportgraphics(Figure_InSample_MacroFinance_EA, './Output/Figure_A3.png', 'Resolution', 400)
exportgraphics(Figure_Baseline_Brier, './Output/Figure_7.png', 'Resolution', 400)


