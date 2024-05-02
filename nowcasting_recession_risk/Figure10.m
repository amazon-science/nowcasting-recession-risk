%% NOWCASTING RECESSION RISK
% Francesco Furno and Domenico Giannone
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Progress Message
disp('Producing Figure 10...');

refresh_estimate = 1;

if refresh_estimate == 1 

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load Data
    load('./Data/Data.mat');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Setting Priors
    Parameters = Get_Parameters();
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Auxiliary Vars
    h_set = 0 : 24;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % In-Sample Exercise
    
    % United States
    Y = Data.US.NBER_Recession;
    X = [Data.US.CISS, Data.US.PMI_Manuf];
    
    parfor h_index = 1 : length(h_set)
        h = h_set(h_index);
        X_aux = X(1:end-h, :);
        Y_aux = Y(1+h:end);
        T = size(Y_aux, 1);
        Posterior_aux = Bayesian_Logit(Y_aux, X_aux, Parameters);
        recession_risk_aux = Recession_Risk_Computation(Posterior_aux, X_aux);
        [Classification_aux, Brier_aux] = Accuracy(Y_aux, recession_risk_aux.p50);
        Brier_Scores_US_aux(h_index, 1) = Brier_aux.Total;
        AUROC_US_aux(h_index, 1) = Classification_aux.AUC(1);
    end

    Brier_Scores.US = Brier_Scores_US_aux;
    AUROC.US = AUROC_US_aux;


    % Euro Area
    Y = Data.EA.CEPR_Recession(EA_start_position:end, :);
    X = [Data.EA.CISS(EA_start_position:end, :), Data.EA.ESI(EA_start_position:end, :)];
    
    parfor h_index = 1 : length(h_set)
        h = h_set(h_index);
        X_aux = X(1:end-h, :);
        Y_aux = Y(1+h:end);
        T = size(Y_aux, 1);
        Posterior_aux = Bayesian_Logit(Y_aux, X_aux, Parameters);
        recession_risk_aux = Recession_Risk_Computation(Posterior_aux, X_aux);
       [Classification_aux, Brier_aux] = Accuracy(Y_aux, recession_risk_aux.p50);
        Brier_Scores_EA_aux(h_index, 1) = Brier_aux.Total;
        AUROC_EA_aux(h_index, 1) = Classification_aux.AUC(1);
    end

    Brier_Scores.EA = Brier_Scores_EA_aux;
    AUROC.EA = AUROC_EA_aux;
    
    save('./Simulations/Baseline_Nowcasting_Forecasting.mat');
else
    load('./Simulations/Baseline_Nowcasting_Forecasting.mat');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Figure_Forecasting = figure('Name', 'Figure 10');
set(gcf, 'Color', 'w');
hold on
plot(h_set, Brier_Scores.US, '-o', 'LineWidth', 1.25);
plot(h_set, Brier_Scores.EA, '-o', 'LineWidth', 1.25);
hold off
xlabel('Forecasting Horizon (h)');
ylabel('Brier Score');
legend('United States', 'Euro Area', 'Location', 'SE')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
exportgraphics(Figure_Forecasting, './Output/Figure_10.png', 'Resolution', 400)


