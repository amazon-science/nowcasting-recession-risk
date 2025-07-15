%% NOWCASTING RECESSION RISK
% Francesco Furno and Domenico Giannone
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Progress Message
disp('Producing Figure 12...');

refresh_Estimate = 1;

if (refresh_Estimate == 1)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load Data
    load('./Data/Data.mat')

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Parameters
    Parameters = Get_Parameters();

    % Growth Change in Quarters
    j = 2;
    
    % CDF Support
    c_set = -0.06 : 0.005 : 0.06;

    % Predictors at Quarterly Frequency: First Month of Quarter
    Data.US_Quarterly.PMI_Manuf = retime(Data.US(:, "PMI_Manuf"), 'quarterly', 'mean').PMI_Manuf;
    Data.US_Quarterly.CISS = retime(Data.US(:, "CISS"), 'quarterly', 'mean').CISS;

    %%%%%%%%%%%%% CDF Estimation via Conditional Expectation %%%%%%%%%%%%%
    
    % RGDP Growth over j Quarters
    Data.US_Quarterly.RGDP_growth = [nan(j, 1); Data.US_Quarterly.RGDP(j+1:end) ./ Data.US_Quarterly.RGDP(1:end-j) - 1];

    % Pre-Allocation
    Posterior_Logit_CDF = nan(3, Parameters.B * (1 - Parameters.Burnin_rate), length(c_set));
    Nadaraya_Watson_CDF = nan(size(Data.US_Quarterly.RGDP_growth, 1), length(c_set));
        

    % Bayesian Logit Estimation Loop over support 
    parfor c_index = 1 : length(c_set)
        
   
        % C_value
        c_aux = c_set(c_index);
    
        % Variable Creation
        Growth_dummy_aux = zeros(size(Data.US_Quarterly.RGDP_growth));
        Growth_dummy_aux(Data.US_Quarterly.RGDP_growth <= c_aux) = 1;
        Growth_dummy_aux;
        
        % Bayesian Logit Posterior Estimation
        Posterior_aux = Bayesian_Logit(Growth_dummy_aux, [Data.US_Quarterly.CISS, Data.US_Quarterly.PMI_Manuf], Parameters);
        Posterior_Logit_CDF(:, :, c_index) = Posterior_aux;

        % Nadaraya-Watson Estimation
        Nadaraya_Watson_CDF(:, c_index) = Nadaraya_Watson([Data.US_Quarterly.CISS, Data.US_Quarterly.PMI_Manuf], Growth_dummy_aux, [Data.US_Quarterly.CISS, Data.US_Quarterly.PMI_Manuf], [1 1]);
        
    end
        
    % Saving Simulation Results
    save('./Simulations/GAR_Distribution.mat');

else
    load('./Simulations/GAR_Distribution.mat');
end
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constructing Conditional CDFs

% Predictors during one Recession and one Expansion
T_Recession = find(Data.US_Quarterly.Date == datetime([2009, 1, 1]) );
T_Expansion = find(Data.US_Quarterly.Date == datetime([2015, 1, 1]) );
X_Recession = [ Data.US_Quarterly.CISS(T_Recession, :), Data.US_Quarterly.PMI_Manuf(T_Recession, :)];
X_Expansion = [ Data.US_Quarterly.CISS(T_Expansion, :), Data.US_Quarterly.PMI_Manuf(T_Expansion, :)];

% CDF from Bayesian Logit
Logit_CDF_Recession = Bayesian_Logit_CDF(Posterior_Logit_CDF, c_set, X_Recession);
Logit_CDF_Expansion = Bayesian_Logit_CDF(Posterior_Logit_CDF, c_set, X_Expansion);

% CDF from Nadayara-Watson
Nadaraya_Watson_CDF_Recession = Nadaraya_Watson_CDF(T_Recession, :);
Nadaraya_Watson_CDF_Expansion = Nadaraya_Watson_CDF(T_Expansion, :);

% CDF from Li, Lin, Racine (2013)
LLR_CDF_Recession = nan(length(c_set), 1);
LLR_CDF_Expansion = nan(length(c_set), 1);

for c_index = 1 : length(c_set)
    c_aux = c_set(c_index);
    LLR_CDF_Recession(c_index, 1) = LLR_CCDF(c_aux, X_Recession, [Data.US_Quarterly.CISS(j+1:end), Data.US_Quarterly.PMI_Manuf(j+1:end)], Data.US_Quarterly.RGDP_growth(j+1:end));
    LLR_CDF_Expansion(c_index, 1) = LLR_CCDF(c_aux, X_Expansion, [Data.US_Quarterly.CISS(j+1:end), Data.US_Quarterly.PMI_Manuf(j+1:end)], Data.US_Quarterly.RGDP_growth(j+1:end));    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualizing
run('./Subfunctions/Plot_Parameters.m');
markersize = 0.1;
recession_c_index = find(c_set == 0);

Figure_GAR_Distribution = figure('Name', 'Figure 12');
set(gcf, 'Color', 'w', 'Position', [433.7164 477.4179 1.0782e+03 343.8806]);
subplot(1, 2, 1)
hold on
confidence_bands(100 * Logit_CDF_Recession.c_set, Logit_CDF_Recession.p05, Logit_CDF_Recession.p95, Color1, transparency);
plota = plot(100 * Logit_CDF_Recession.c_set, Logit_CDF_Recession.p50, '-o', 'MarkerSize', markersize, 'Color', Color1, 'MarkerFaceColor',  Color1,  'LineWidth', 1.25);
plotb = plot(100 * c_set, Nadaraya_Watson_CDF_Recession, '-o', 'MarkerSize', markersize, 'Color', Color2, 'MarkerFaceColor',  Color2,  'LineWidth', 1.25);
plotc = plot(100 * c_set, LLR_CDF_Recession, '-o', 'MarkerSize', markersize, 'Color', 'k', 'MarkerFaceColor',  'k',  'LineWidth', 1.25);
plot(0, Logit_CDF_Recession.p50(recession_c_index), '-o', 'MarkerSize', 4, 'Color', 'r', 'MarkerFaceColor', 'r',  'LineWidth', 1.25);
hold off
xlabel('US GDP Growth');
ylabel('CDF');
ylim([0,1]);
xtickformat('percentage')
title('US - 2009Q1')
legend([plota, plotb, plotc], 'Bayesian Logit', 'Nadaraya-Watson', 'Li, Lin, Racine (2013)', 'Location', 'SE', 'FontSize', 8)


subplot(1, 2, 2)
hold on
confidence_bands(100 * Logit_CDF_Expansion.c_set, Logit_CDF_Expansion.p05, Logit_CDF_Expansion.p95, Color1, transparency);
plot(100 * Logit_CDF_Expansion.c_set, Logit_CDF_Expansion.p50, '-o', 'MarkerSize', markersize, 'Color', Color1, 'MarkerFaceColor',  Color1,  'LineWidth', 1.25);
plot(100 * c_set, Nadaraya_Watson_CDF_Expansion, '-o', 'MarkerSize', markersize, 'Color', Color2, 'MarkerFaceColor',  Color2,  'LineWidth', 1.25);
plot(100 * c_set, LLR_CDF_Expansion, '-o', 'MarkerSize', markersize, 'Color', 'k', 'MarkerFaceColor',  'k',  'LineWidth', 1.25);
plot(0, Logit_CDF_Expansion.p50(recession_c_index), '-o', 'MarkerSize', 4, 'Color', 'r', 'MarkerFaceColor', 'r',  'LineWidth', 1.25);
hold off
xlabel('US GDP Growth');
ylabel('CDF');
ylim([0,1]);
xtickformat('percentage')
title('US - 2015Q1')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
exportgraphics(Figure_GAR_Distribution, './Output/Figure_12.png', 'Resolution', 400)



