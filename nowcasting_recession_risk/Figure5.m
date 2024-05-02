%% NOWCASTING RECESSION RISK
% Francesco Furno and Domenico Giannone
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear, clc, close all;
addpath(genpath('./Subfunctions/'));

refresh_estimates = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (refresh_estimates == 1)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load Data 
    load('./Data/Data.mat');
    ESI_Vintages = readtimetable('./Data/EC_ESI_Vintages/ESI_Vintages.xlsx', 'Sheet', 'ESI_Vintages');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Setting Parameters
    Parameters = Get_Parameters();
       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Estimation In-Sample for EA
    
    N = size(ESI_Vintages, 2) - 2; 
    T = size(ESI_Vintages, 1);

    ESI_matrix = ESI_Vintages.Variables;
    Risk_ESI_Vintages = nan(T, N);

    for vv = 2+1 : N
        n_max  = find(isnan(ESI_matrix(:, vv)));
        
        display(strcat("Status: ", string(vv), "/", string(N)))

        if ( isempty(n_max) )
            Y = ESI_matrix(:, 1);
            X = [ ESI_matrix(:, 2), ESI_matrix(:, vv) ];
            Posterior_aux = Bayesian_Logit(Y, X, Parameters);
            risk_aux = Recession_Risk_Computation(Posterior_aux, X);
            Risk_ESI_Vintages(:, vv-2) = risk_aux.p50;

        else
            n_max  = n_max(1);
            Y = ESI_matrix(1:n_max-1, 1);
            X = [ ESI_matrix(1:n_max-1, 2), ESI_matrix(1:n_max-1, vv) ]; 
            Posterior_aux = Bayesian_Logit(Y, X, Parameters);
            risk_aux = Recession_Risk_Computation(Posterior_aux, X);
            Risk_ESI_Vintages(1:n_max-1, vv-2) = risk_aux.p50;
        end

    end
    
    save('./Simulations/Robustness_ESI_Vintages.mat');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    load('./Simulations/Robustness_ESI_Vintages.mat');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualization
run('./Subfunctions/Plot_Parameters.m');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Baseline - In-Sample
Figure_Robustness_ESI = figure;
set(gcf, 'Color', 'w', 'Position', Plt_size_2by1)
subplot(2, 1, 1)
hold on
plot(ESI_Vintages.Period, [ESI_matrix(:, 3:end)], 'LineWidth', 1);
hold off
recessionplot('recessions', EA_Recession_Shades);
title('ESI Vintages - Euro Area');
xlabel('Date');
ylabel('Economic Sentiment Indicator (ESI)');
lgd1 = legend('01-2023', '01-2020', '01-2019', '01-2018', '01-2017', '01-2014', '01-2011', '01-2009', 'FontSize', 7); 
set(lgd1,'Position',[0.153908281263966 0.598775678240158 0.0876473592740336 0.175870853252298]);

subplot(2, 1, 2)
hold on
plot(ESI_Vintages.Period, [Risk_ESI_Vintages], 'LineWidth', 1);
hold off
recessionplot('recessions', EA_Recession_Shades);
title('Recession Risk - Euro Area');
xlabel('Date');
ylabel('Recession Risk');
ytickformat('percentage');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
