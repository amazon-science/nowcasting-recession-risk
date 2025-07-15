%% NOWCASTING RECESSION RISK
% Francesco Furno and Domenico Giannone
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Progress Message
disp('Producing Figure 11...');

refresh_estimates = 1;

if (refresh_estimates == 1)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Loading Baseline OOS
    load('./Simulations/Baseline_OOS.mat')
    aggregation_method = 'mean';

    % Parameters
    c = 0;  % point at which CDF is evaluated
    j = 2;  % lags for RGDP growth computation

    %%%%%%%%%%%%%%%%%%%%%%%%%%%% US %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Quarterly Series of NBER-Based Recession Risk 

    data_aux = timetable(Data.US.Date, Risk.US.Baseline_OOS2.distribution);    
    data_aux = retime(data_aux, 'quarterly', aggregation_method); 
    data_aux = data_aux.Variables;
    
    Data.US_Quarterly.Risk = prctile(data_aux, 50, 2);
    Data.US_Quarterly.Risk_lb = prctile(data_aux, 05, 2);
    Data.US_Quarterly.Risk_ub = prctile(data_aux, 95, 2);
    
    % Predictors at Quarterly Frequency
    aux = retime(Data.US(:, "PMI_Manuf"), 'quarterly', aggregation_method);
    Data.US_Quarterly.PMI_Manuf = aux.PMI_Manuf;
    aux = retime(Data.US(:, "CISS"), 'quarterly', aggregation_method);
    Data.US_Quarterly.CISS = aux.CISS;
    
    % Creation of RGDP-based Indicator (Real-Time Vintages)    
    
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
        disp(strcat(" US, Time Period: ", string(time_aux), "/", string(T_end) ));
    
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
   

    %%%%%%%%%%%%%%%%%%%%%%%%%% EURO AREA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Quarterly Series of CEPR-Based Recession Risk 

    data_aux = timetable(Data.EA.Date, Risk.EA.Baseline_OOS2.distribution);
    data_aux = retime(data_aux, 'quarterly', aggregation_method); data_aux = data_aux.Variables;
    Data.EA_Quarterly.Risk = prctile(data_aux, 50, 2);
    Data.EA_Quarterly.Risk_lb = prctile(data_aux, 05, 2);
    Data.EA_Quarterly.Risk_ub = prctile(data_aux, 95, 2);
    
    % Predictors at Quarterly Frequency
    aux = retime(Data.EA(:, "ESI"), 'quarterly', aggregation_method);
    Data.EA_Quarterly.ESI = aux.ESI;
    aux = retime(Data.EA(:, "CISS"), 'quarterly', aggregation_method);
    Data.EA_Quarterly.CISS = aux.CISS;
    
    
    % Creation of RGDP-based Indicator (Recent Vintage)
    
    % Pre-Allocation
    Data.EA_Quarterly.RGDP_Risk = nan(size(Data.EA_Quarterly.Date));
    Data.EA_Quarterly.RGDP_Risk_lb = nan(size(Data.EA_Quarterly.Date));
    Data.EA_Quarterly.RGDP_Risk_ub = nan(size(Data.EA_Quarterly.Date));
    
    
    % Training Sample Dates
    T_start = find(quarter(Data.EA_Quarterly.Date) == 1 & year(Data.EA_Quarterly.Date) == 1995);
    T_end = size(Data.EA_Quarterly.Date, 1);
    EA_start_position = find(~isnan(Data.EA_Quarterly.ESI), 1);

    % PART 1 - First Period and Backcasting

    gdp_vintage_aux = Data.EA_Quarterly.RGDP(1:T_start-1);
    growth_aux = [nan(j, 1); gdp_vintage_aux(j+1:end) ./ gdp_vintage_aux(1:end-j) - 1];
    Y_aux = zeros(T_start-1, 1);
    Y_aux(growth_aux <= c) = 1;
    
    Y_EA_aux = Y_aux(EA_start_position:end);
    X_EA_aux = [Data.EA_Quarterly.CISS(EA_start_position:T_start-1), Data.EA_Quarterly.ESI(EA_start_position:T_start-1)];
    Posterior_aux = Bayesian_Logit(Y_EA_aux, X_EA_aux, Parameters);
   
    X_EA_aux = [Data.EA_Quarterly.CISS(1:T_start), Data.EA_Quarterly.ESI(1:T_start)];
    risk_aux = Recession_Risk_Computation(Posterior_aux, X_EA_aux);
    
    Data.EA_Quarterly.RGDP_Risk(1:T_start) = prctile(risk_aux.distribution, 50, 2);
    Data.EA_Quarterly.RGDP_Risk_lb(1:T_start) = prctile(risk_aux.distribution, 05, 2);
    Data.EA_Quarterly.RGDP_Risk_ub(1:T_start) = prctile(risk_aux.distribution, 95, 2);
    
    
    % PART 2 - Recursive Part for Rest of the Sample
    parfor time_aux = T_start + 1 : T_end
        disp(strcat("EA, Time Period: ", string(time_aux), "/", string(T_end) ))
    
        gdp_vintage_aux = Data.EA_Quarterly.RGDP(1:time_aux-1);
        growth_aux = [nan(j, 1); gdp_vintage_aux(j+1:end) ./ gdp_vintage_aux(1:end-j) - 1];
        Y_aux = zeros(time_aux-1, 1);
        Y_aux(growth_aux <= c) = 1;
        
        Y_EA_aux = Y_aux(EA_start_position:end);
        X_EA_aux = [Data.EA_Quarterly.CISS(EA_start_position:time_aux-1), Data.EA_Quarterly.ESI(EA_start_position:time_aux-1)];
        Posterior_aux = Bayesian_Logit(Y_EA_aux, X_EA_aux, Parameters);
        
        X_EA_aux = [Data.EA_Quarterly.CISS(1:time_aux), Data.EA_Quarterly.ESI(1:time_aux)];
        risk_aux = Recession_Risk_Computation(Posterior_aux, X_EA_aux);
        
        RGDP_Risk_aux(time_aux) = prctile(risk_aux.distribution(end, :, :), 50, 2);
        RGDP_Risk_lb_aux(time_aux) = prctile(risk_aux.distribution(end, :, :), 05, 2);
        RGDP_Risk_ub_aux(time_aux) = prctile(risk_aux.distribution(end, :, :), 95, 2);
    
    end
    
    Data.EA_Quarterly.RGDP_Risk(T_start + 1 : T_end) = RGDP_Risk_aux(T_start + 1 : T_end)';
    Data.EA_Quarterly.RGDP_Risk_lb(T_start + 1 : T_end) = RGDP_Risk_lb_aux(T_start + 1 : T_end)';
    Data.EA_Quarterly.RGDP_Risk_ub(T_start + 1 : T_end) = RGDP_Risk_ub_aux(T_start + 1 : T_end)';

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    save('./Simulations/GAR_Risk_Series.mat');

else
    load('./Simulations/GAR_Risk_Series.mat');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run('./Subfunctions/Plot_Parameters.m');

Figure_Official_RGDP = figure('Name', 'Figure 11');
set(gcf, 'Color', 'w', 'Position', Plt_size_2by2);
subplot(2, 1, 1)
hold on
confidence_bands(Data.US_Quarterly.Date, 100 * Data.US_Quarterly.Risk_lb, 100 * Data.US_Quarterly.Risk_ub, Color1, transparency);
confidence_bands(Data.US_Quarterly.Date, 100 * Data.US_Quarterly.RGDP_Risk_lb, 100 * Data.US_Quarterly.RGDP_Risk_ub, Color2, transparency);
plota = plot(Data.US_Quarterly.Date, 100 * Data.US_Quarterly.Risk, 'Color', Color1, 'LineWidth', 1);
plotb = plot(Data.US_Quarterly.Date, 100 * Data.US_Quarterly.RGDP_Risk, 'Color', Color2, 'LineWidth', 1);
hold off
recessionplot;
title('United States');
xlabel('Date');
ylabel('Recession Risk');
ytickformat('percentage');
lgd1 = legend([plota, plotb], 'NBER/CEPR Recession', 'Negative GDP Growth', 'FontSize', 8);
set(lgd1, 'Position',[0.704578906585903 0.853810070279101 0.151497058160789 0.0587363124140495]);

subplot(2, 1, 2)
hold on
confidence_bands(Data.EA_Quarterly.Date, 100 * Data.EA_Quarterly.Risk_lb, 100 * Data.EA_Quarterly.Risk_ub, Color1, transparency);
confidence_bands(Data.EA_Quarterly.Date, 100 * Data.EA_Quarterly.RGDP_Risk_lb, 100 * Data.EA_Quarterly.RGDP_Risk_ub, Color2, transparency);
plota = plot(Data.EA_Quarterly.Date, 100 * Data.EA_Quarterly.Risk, 'Color', Color1, 'LineWidth', 1);
plotb = plot(Data.EA_Quarterly.Date, 100 * Data.EA_Quarterly.RGDP_Risk, 'Color', Color2, 'LineWidth', 1);
hold off
recessionplot('recessions', EA_Recession_Shades);
title('Euro Area');
ylabel('Recession Risk');
ytickformat('percentage');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
exportgraphics(Figure_Official_RGDP, './Output/Figure_11.png', 'Resolution', 400)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Correlations
aux = corr([ Data.US_Quarterly.Risk,  Data.US_Quarterly.RGDP_Risk]);
disp(strcat("Correlation for US: ", char(string(round(aux(1, 2), 2))) ))

aux = corr([ Data.EA_Quarterly.Risk,  Data.EA_Quarterly.RGDP_Risk], 'rows', 'complete');
disp(strcat("Correlation for EA: ", char(string(round(aux(1, 2), 2))) ))



