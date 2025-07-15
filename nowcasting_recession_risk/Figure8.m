%% NOWCASTING RECESSION RISK
% Francesco Furno and Domenico Giannone
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Progress Message
disp('Producing Figure 8...');

refresh_estimates = 1;


if (refresh_estimates == 1)
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load Data
    load('./Data/Data.mat');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Setting Parameters
    Parameters = Get_Parameters();
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % In-Sample Estimation
    Y = Data.US.NBER_Recession;
    
    varlist = {'CISS', 'PMI_Manuf', 'NFCI', 'TermSpread', 'NearForward' 'GZSpread', 'EBP', 'SP500', 'HousePermits', ...
        'HouseStarts', 'Unemp', 'SahmRule_Unemp', 'Claims', 'Wkly_Hours', 'Hours_Manuf'};

    
    for variable_index = 1 : length(varlist)
        var_name_aux = varlist{variable_index};
        X_US_aux = Data.US.(var_name_aux);
        Posterior_aux = Bayesian_Logit(Y, X_US_aux, Parameters);
        Risk.US.(var_name_aux) = Recession_Risk_Computation(Posterior_aux, X_US_aux);
        [Classification.US.(var_name_aux), Brier_Scores.US.(var_name_aux)] = Accuracy(Y, Risk.US.(var_name_aux).p50);
    end
    
    save('./Simulations/Baseline_AlternativePredictors.mat');
else
    load('./Simulations/Baseline_AlternativePredictors.mat');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for variable_index = 1 : length(varlist)
    var_name_aux = varlist{variable_index};
    b_calibration(variable_index, 1) = Brier_Scores.US.(var_name_aux).Calibration;
    b_refinement(variable_index, 1) = Brier_Scores.US.(var_name_aux).Refinement;
    b_total(variable_index, 1) = Brier_Scores.US.(var_name_aux).Total;
end

varlist{2} = 'PMIManuf';
varlist{12} = 'SahmRule';
varlist{14} = 'WklyHours';
varlist{15} = 'HoursManuf';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[a, b] = sort(b_total, 'ascend');
x_varlist = categorical(varlist(b));
x_varlist = reordercats(x_varlist, varlist(b));

Figure_Comparison = figure('Name', 'Figure 8');
set(gcf, 'Color', 'w');
hold on
bar(x_varlist, [b_calibration(b), b_refinement(b)], 'stacked')
plot(x_varlist, [b_calibration(b)+ b_refinement(b)], 'o', 'MarkerEdgeColor', 'k', 'MarkerSize', 5, 'MarkerFaceColor', 'k')

ylabel('Brier Score');
legend('Calibration', 'Refinement', 'Location', 'NW')
title('Alternative Predictors - United States')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
exportgraphics(Figure_Comparison, './Output/Figure_8.png', 'Resolution', 400)


















