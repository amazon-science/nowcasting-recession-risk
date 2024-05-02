%% NOWCASTING RECESSION RISK
% Francesco Furno and Domenico Giannone
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Progress Message
disp('Producing Figure 14 and Table 5b...');

refresh_estimates = 1;

if (refresh_estimates == 1)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Loading Baseline OOS
    load('./Simulations/Baseline_OOS.mat')
    
    % Parameters
    c = 0;  % point at which CDF is evaluated
    j = 1;  % lags for RGDP growth computation

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% US %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Predictors at Quarterly Frequency: First Month of Quarter
    aux = retime(Data.US(:, "PMI_Manuf"), 'quarterly', 'firstvalue');
    Data.US_Quarterly.PMI_Manuf = aux.PMI_Manuf;
    aux = retime(Data.US(:, "CISS"), 'quarterly', 'firstvalue');
    Data.US_Quarterly.CISS = aux.CISS;
        
    % Real-Time RGDP Vintages
    RGDP_Vintages = readtable('./Data/RGDP_Vintages/ROUTPUTQvQd.xlsx');
    i_aux = find(strcmpi(RGDP_Vintages.DATE, {'1980:Q1'}));
    j_aux = find(strcmpi(RGDP_Vintages.Properties.VariableNames, 'ROUTPUT80Q1'));
    RGDP_Vintages = RGDP_Vintages(i_aux:end, [1, j_aux:end]);
    RGDP_Vintages_TT = RGDP_Vintages;
    RGDP_Vintages = RGDP_Vintages(:, 2:end); RGDP_Vintages = RGDP_Vintages.Variables;
    
    % Pre-Allocation
    Data.US_Quarterly.RGDP_Risk = nan(size(Data.US_Quarterly.Date));
    Data.US_Quarterly.RGDP_Risk_lb = nan(size(Data.US_Quarterly.Date));
    Data.US_Quarterly.RGDP_Risk_ub = nan(size(Data.US_Quarterly.Date));
    
    % Training Sample Dates
    T_start = find(quarter(Data.US_Quarterly.Date) == 1 & year(Data.US_Quarterly.Date) == 1995);
    T_end = size(Data.US_Quarterly.Date, 1);
    
    % PART 1 - First Period and Backcasting

    gdp_vintage_aux = RGDP_Vintages(1:T_start-1, T_start);
    growth_aux = [nan(j, 1); gdp_vintage_aux(j+1:end) ./ gdp_vintage_aux(1:end-j) - 1];
    Y_aux = zeros(T_start-1, 1);
    Y_aux(growth_aux <= c) = 1;
    
    Y_US_aux = Y_aux;
    X_US_aux = [Data.US_Quarterly.CISS(1:T_start-1), Data.US_Quarterly.PMI_Manuf(1:T_start-1)];
    Posterior_aux = Bayesian_Logit(Y_US_aux, X_US_aux, Parameters);
   
    X_US_aux = [Data.US_Quarterly.CISS(1:T_start), Data.US_Quarterly.PMI_Manuf(1:T_start)];
    risk_aux = Recession_Risk_Computation(Posterior_aux, X_US_aux);
    
    Data.US_Quarterly.RGDP_Risk(1:T_start) = prctile(risk_aux.distribution, 50, 2);
    Data.US_Quarterly.RGDP_Risk_lb(1:T_start) = prctile(risk_aux.distribution, 05, 2);
    Data.US_Quarterly.RGDP_Risk_ub(1:T_start) = prctile(risk_aux.distribution, 95, 2);
    
    
    % PART 2 - Recursive Part for Rest of the Sample
    parfor time_aux = T_start + 1 : T_end
        disp(strcat("US, Time Period: ", string(time_aux), "/", string(T_end) ));
    
        gdp_vintage_aux = RGDP_Vintages(1:time_aux-1, time_aux);
        growth_aux = [nan(j, 1); gdp_vintage_aux(j+1:end) ./ gdp_vintage_aux(1:end-j) - 1];
        Y_aux = zeros(time_aux-1, 1);
        Y_aux(growth_aux <= c) = 1;
        
        Y_US_aux = Y_aux;
        X_US_aux = [Data.US_Quarterly.CISS(1:time_aux-1), Data.US_Quarterly.PMI_Manuf(1:time_aux-1)];
        Posterior_aux = Bayesian_Logit(Y_US_aux, X_US_aux, Parameters);
        
        X_US_aux = [Data.US_Quarterly.CISS(1:time_aux), Data.US_Quarterly.PMI_Manuf(1:time_aux)];
        risk_aux = Recession_Risk_Computation(Posterior_aux, X_US_aux);
        
        RGDP_Risk_aux(time_aux) = prctile(risk_aux.distribution(end, :, :), 50, 2);
        RGDP_Risk_lb_aux(time_aux) = prctile(risk_aux.distribution(end, :, :), 05, 2);
        RGDP_Risk_ub_aux(time_aux) = prctile(risk_aux.distribution(end, :, :), 95, 2);
    
    end
    
    Data.US_Quarterly.RGDP_Risk(T_start + 1 : T_end) = RGDP_Risk_aux(T_start + 1 : T_end)';
    Data.US_Quarterly.RGDP_Risk_lb(T_start + 1 : T_end) = RGDP_Risk_lb_aux(T_start + 1 : T_end)';
    Data.US_Quarterly.RGDP_Risk_ub(T_start + 1 : T_end) = RGDP_Risk_ub_aux(T_start + 1 : T_end)';
   

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    save('./Simulations/SPF_RGDP.mat');

else
    load('./Simulations/SPF_RGDP.mat');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Brier Scores

% Diagonal Target (real-time one year later)
Target_Real_Time = zeros(T_end, 1);

Vintage_lag = 4;

for t_aux = 2 : T_end
    
    g_aux = RGDP_Vintages(t_aux, t_aux + Vintage_lag) ./ RGDP_Vintages(t_aux-1, t_aux + Vintage_lag) - 1;
    
    if (g_aux < c)
        Target_Real_Time(t_aux) = 1;
    end
end


% Computing Brier Scores
[~, Brier_Scores.US_Quarterly.SPF_RGDP] = Accuracy(Target_Real_Time, Data.US_Quarterly.SPF_Anxious / 100);
[~, Brier_Scores.US_Quarterly.Nowcast_RGDP] = Accuracy(Target_Real_Time, Data.US_Quarterly.RGDP_Risk);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run('./Subfunctions/Plot_Parameters.m');

Figure_RGDP_SPF = figure('Name', 'Figure 14');
set(gcf, 'Color', 'w', 'Position', Plt_size_1by1_long);
hold on
confidence_bands(Data.US_Quarterly.Date, 100 * Data.US_Quarterly.RGDP_Risk_lb, 100 * Data.US_Quarterly.RGDP_Risk_ub, Color1, transparency);
plota = plot(Data.US_Quarterly.Date, 100 * Data.US_Quarterly.RGDP_Risk, 'Color', Color1, 'LineWidth', 1);

plotb = plot(Data.US_Quarterly.Date, Data.US_Quarterly.SPF_Anxious, 'Color', Color2, 'LineWidth', 1);
hold off
recessionplot('recessions', Get_shades_quarterly(timetable(Data.US_Quarterly.Date, Target_Real_Time)));
title('United States');
xlabel('Date');
ylabel('Risk');
ytickformat('percentage');
lgd1 = legend([plota, plotb], 'Nowcast - Target: GDP', 'SPF GDP Decline', 'FontSize', 8);
set(lgd1, 'Position',[0.703431149405073 0.786813433368697 0.154384074495196 0.117940196266206]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
exportgraphics(Figure_RGDP_SPF, './Output/Figure_14.png', 'Resolution', 400)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Brier Scores Table
Brier_Score = {'Recession'; 'Expansion'; 'Overall'};

RGDP_Nowcast     = round([Brier_Scores.US_Quarterly.Nowcast_RGDP.Contraction; Brier_Scores.US_Quarterly.Nowcast_RGDP.Expansion; Brier_Scores.US_Quarterly.Nowcast_RGDP.Total], 3);
RGDP_SPF        = round([Brier_Scores.US_Quarterly.SPF_RGDP.Contraction; Brier_Scores.US_Quarterly.SPF_RGDP.Expansion; Brier_Scores.US_Quarterly.SPF_RGDP.Total], 3);

Table5b = table(Brier_Score, RGDP_Nowcast, RGDP_SPF);
writetable(Table5b, './Output/Table_5.xlsx', 'Sheet', 'RGDP');


