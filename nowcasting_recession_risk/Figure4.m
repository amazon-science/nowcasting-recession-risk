%% NOWCASTING RECESSION RISK
% Francesco Furno and Domenico Giannone
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Progress Message
disp('Producing Figure 4...');

refresh_estimates = 1;

if (refresh_estimates == 1)
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Loading Baseline In-Sample
    load('./Simulations/Baseline_INS.mat');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % OOS - Expanding-Window Estimation Sample
    d = 24;
    T_OOS2_start = find(Data.US.Date == datetime([1995, 1, 1]));
    T_OOS2_estimation = T_OOS2_start - d;
    T = size(Data.US, 1);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % PART 1 - First Time-Period and Backward Estimation
    
    %%%%%%%%%%%%%%%%%%%%%%%
    % US
    Y_estimation_aux = Data.US.NBER_Recession(1:T_OOS2_start-d);
    X_estimation_aux = [Data.US.CISS(1:T_OOS2_start-d), Data.US.PMI_Manuf(1:T_OOS2_start-d)];
    Posterior_aux = Bayesian_Logit(Y_estimation_aux, X_estimation_aux, Parameters);

    X_prediction_aux = [Data.US.CISS(1:T_OOS2_start), Data.US.PMI_Manuf(1:T_OOS2_start)];
    Risk_aux = Recession_Risk_Computation(Posterior_aux, X_prediction_aux);
    Risk_US_distribution_aux(1:T_OOS2_start, :) = Risk_aux.distribution;
    Risk_US_p50_aux(1:T_OOS2_start) = Risk_aux.p50;
    Risk_US_p05_aux(1:T_OOS2_start) = Risk_aux.p05;
    Risk_US_p95_aux(1:T_OOS2_start) = Risk_aux.p95; 
    
    %%%%%%%%%%%%%%%%%%%%%%%
    % Euro Area
    Y_estimation_aux = Data.EA.CEPR_Recession(EA_start_position:T_OOS2_start-d);
    X_estimation_aux = [Data.EA.CISS(EA_start_position:T_OOS2_start-d), Data.EA.ESI(EA_start_position:T_OOS2_start-d)];
    Posterior_aux = Bayesian_Logit(Y_estimation_aux, X_estimation_aux, Parameters);

    X_prediction_aux = [Data.EA.CISS(1:T_OOS2_start), Data.EA.ESI(1:T_OOS2_start)];
    Risk_aux = Recession_Risk_Computation(Posterior_aux, X_prediction_aux);
    Risk_EA_distribution_aux(1:T_OOS2_start, :) = Risk_aux.distribution;
    Risk_EA_p50_aux(1:T_OOS2_start) = Risk_aux.p50;
    Risk_EA_p05_aux(1:T_OOS2_start) = Risk_aux.p05;
    Risk_EA_p95_aux(1:T_OOS2_start) = Risk_aux.p95; 


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PART 2 - Rolling Out-of-Sample
    parfor t_aux = T_OOS2_start + 1 : T
        
        disp(strcat("Time Period: ", string(t_aux), "/", string(T) ) )    
        
        %%%%%%%%%%%%%%%%%%%%%%%
        % US
        
        Y_estimation_aux = Data.US.NBER_Recession(1:t_aux-d);
        X_estimation_aux = [Data.US.CISS(1:t_aux-d), Data.US.PMI_Manuf(1:t_aux-d)];
        Posterior_aux = Bayesian_Logit(Y_estimation_aux, X_estimation_aux, Parameters);
        
        X_prediction_aux = [Data.US.CISS(t_aux), Data.US.PMI_Manuf(t_aux)];
        Risk_aux = Recession_Risk_Computation(Posterior_aux, X_prediction_aux);
        Risk_US_distribution_aux(t_aux, :) = Risk_aux.distribution;
        Risk_US_p50_aux(t_aux) = Risk_aux.p50;
        Risk_US_p05_aux(t_aux) = Risk_aux.p05;
        Risk_US_p95_aux(t_aux) = Risk_aux.p95; 

            
        %%%%%%%%%%%%%%%%%%%%%%%
        % Euro Area
        
        Y_estimation_aux = Data.EA.CEPR_Recession(EA_start_position:t_aux-d);
        X_estimation_aux = [Data.EA.CISS(EA_start_position:t_aux-d), Data.EA.ESI(EA_start_position:t_aux-d)];
        Posterior_aux = Bayesian_Logit(Y_estimation_aux, X_estimation_aux, Parameters);

        X_prediction_aux = [Data.EA.CISS(t_aux), Data.EA.ESI(t_aux)];
        Risk_aux = Recession_Risk_Computation(Posterior_aux, X_prediction_aux);
        Risk_EA_distribution_aux(t_aux, :) = Risk_aux.distribution;
        Risk_EA_p50_aux(t_aux) = Risk_aux.p50;
        Risk_EA_p05_aux(t_aux) = Risk_aux.p05;
        Risk_EA_p95_aux(t_aux) = Risk_aux.p95; 

    end
    
    % Reconstructing Structures
    Risk.US.Baseline_OOS2.distribution = Risk_US_distribution_aux;
    Risk.US.Baseline_OOS2.p50 = Risk_US_p50_aux';
    Risk.US.Baseline_OOS2.p05 = Risk_US_p05_aux';
    Risk.US.Baseline_OOS2.p95 = Risk_US_p95_aux'; 
    
    Risk.EA.Baseline_OOS2.distribution = Risk_EA_distribution_aux;
    Risk.EA.Baseline_OOS2.p50 = Risk_EA_p50_aux';
    Risk.EA.Baseline_OOS2.p05 = Risk_EA_p05_aux';
    Risk.EA.Baseline_OOS2.p95 = Risk_EA_p95_aux'; 
    
    % Brier Scores for Expanding-Window Estimation
    [Classification.US.Baseline_OOS2, Brier_Scores.US.Baseline_OOS2] = Accuracy(Data.US.NBER_Recession, Risk.US.Baseline_OOS2.p50);
    [Classification.EA.Baseline_OOS2, Brier_Scores.EA.Baseline_OOS2] = Accuracy(Data.EA.CEPR_Recession(1:end), Risk.EA.Baseline_OOS2.p50);
    

    % Saving Results
    clearvars -except Data Risk Classification Brier_Scores EA_Recession_Shades Parameters EA_start_position
    save('./Simulations/Baseline_OOS.mat');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    load('./Simulations/Baseline_OOS.mat');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualization
run('./Subfunctions/Plot_Parameters.m');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Figure_OOS_INS = figure('Name', 'Figure 4');
set(gcf, 'Color', 'w', 'Position', [280.2000 309.8000 975.2000 588.8000])
subplot(2, 1, 1)
hold on
confidence_bands(Data.US.Date, 100 * Risk.US.Baseline.p05, 100 * Risk.US.Baseline.p95, Color1, transparency);
confidence_bands(Data.US.Date, 100 * Risk.US.Baseline_OOS2.p05, 100 * Risk.US.Baseline_OOS2.p95, Color2, transparency);
plota = plot(Data.US.Date, 100 * Risk.US.Baseline.p50, 'Color', Color1, 'LineWidth', 1);
plotb = plot(Data.US.Date, 100 * Risk.US.Baseline_OOS2.p50, 'Color', Color2, 'LineWidth', 1);

hold off
recessionplot; 
title('United States');
xlabel('Date');
ylabel('Recession Risk');
ytickformat('percentage');
lgd1 = legend([plota, plotb], 'In-Sample', 'Pseudo OOS');
set(lgd1, 'Position',[0.714835421471632 0.822156294061151 0.141465912257507 0.0875106178660867]);


subplot(2, 1, 2)
hold on
confidence_bands(Data.EA.Date, 100 * [nan(EA_start_position-1, 1); Risk.EA.Baseline.p05], 100 * [nan(EA_start_position-1, 1); Risk.EA.Baseline.p95], Color1, transparency);
confidence_bands(Data.EA.Date, 100 * Risk.EA.Baseline_OOS2.p05, 100 * Risk.EA.Baseline_OOS2.p95, Color2, transparency);
plot(Data.EA.Date, 100 * [nan(EA_start_position-1, 1); Risk.EA.Baseline.p50], 'Color', Color1, 'LineWidth', 1);
plot(Data.EA.Date, 100 * Risk.EA.Baseline_OOS2.p50, 'Color', Color2, 'LineWidth', 1);
hold off
recessionplot('recessions', EA_Recession_Shades);
title('Euro Area');
xlabel('Date');
ylabel('Recession Risk');
ytickformat('percentage');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
exportgraphics(Figure_OOS_INS, './Output/Figure_4.png', 'Resolution', 400)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Correlations
aux = corr([Risk.US.Baseline.p50, Risk.US.Baseline_OOS2.p50], 'rows', 'complete');
disp(strcat("Correlation for US: ", char(string(round(aux(1, 2), 2))) ))

aux = corr([Risk.EA.Baseline.p50, Risk.EA.Baseline_OOS2.p50(EA_start_position:end)], 'rows', 'complete');
disp(strcat("Correlation for EA: ", char(string(round(aux(1, 2), 2))) ))


% Brier Scores
disp(strcat("Brier Score In-Sample for US: ", string(round(Brier_Scores.US.Baseline.Total, 3))))
disp(strcat("Brier Score OOS for US: ", string(round(Brier_Scores.US.Baseline_OOS2.Total, 3))))

disp(strcat("Brier Score In-Sample for EA: ", string(round(Brier_Scores.EA.Baseline.Total, 3))))
disp(strcat("Brier Score OOS for EA: ", string(round(Brier_Scores.EA.Baseline_OOS2.Total, 3))))





