function [Classification, Brier_Score] = Accuracy(Y, pi)
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

% ------------------- Input Check -------------------
if (length(Y) ~= length(pi))
    error('Data Mismatch')
end

% Removing NaNs
T_start_aux = sum(isnan(pi));
Y = Y(T_start_aux+1:end);
pi = pi(T_start_aux+1:end);

% ----------------- Probability Rounding ----------------
pi = round(pi, 2);


% ------------------- Classification ------------------- 

% Parameters
k_set = (0.0:0.01:1)';
N = length(k_set);
T = length(pi);

% Note: True Negatives (a), False Positives (b), False Negatives (c), True Positives (d)
a = zeros(N, 1);
b = zeros(N, 1);
c = zeros(N, 1);
d = zeros(N, 1);
accuracy = zeros(N, 1);
sensitivity = zeros(N, 1);
specificity = zeros(N, 1);

for k_index  = 1 : N
    k_aux = k_set(k_index);
    Y_hat_aux = zeros(T, 1);
    Y_hat_aux(pi >= k_aux) = 1;
    a(k_index, 1) = sum( Y == 0 & Y_hat_aux == 0);
    b(k_index, 1) = sum( Y == 0 & Y_hat_aux == 1);
    c(k_index, 1) = sum( Y == 1 & Y_hat_aux == 0);
    d(k_index, 1) = sum( Y == 1 & Y_hat_aux == 1);
    accuracy(k_index, 1) = (a(k_index, 1) + d(k_index, 1)) ./ (a(k_index, 1) + b(k_index, 1) + c(k_index, 1) + d(k_index, 1));
    sensitivity(k_index, 1) = (d(k_index, 1)) ./ ( c(k_index, 1) + d(k_index, 1));
    specificity(k_index, 1) = (a(k_index, 1)) ./ (a(k_index, 1) + b(k_index, 1));
end

false_positive_rate = (1 - specificity);
false_negative_rate = (1 - sensitivity);
AUC = trapz(flipud(false_positive_rate), flipud(sensitivity));
AUC = repmat(AUC, size(k_set));
Classification = table(k_set, a, b, c, d, accuracy, sensitivity, specificity, false_positive_rate, false_negative_rate, AUC);


% ------------------- Brier Scores ------------------- 
Brier_Score.Total = mean( (pi - Y).^2 ) ;

% DECOMPOSITION: EXPANSION VS CONTRACTION
Brier_Score.T_R = sum((Y==1));
Brier_Score.T_E = sum((Y==0));
Brier_Score.T = T;
Brier_Score.T_R_share = Brier_Score.T_R ./ T;
Brier_Score.T_E_share = Brier_Score.T_E ./ T;
Brier_Score.Contraction = Brier_Score.T_R^(-1) * sum( (Y==1) .* (1 - pi).^2 );
Brier_Score.Expansion = Brier_Score.T_E^(-1) *  sum( (Y==0) .* (pi).^2 );


% DECOMPOSITION: CALIBRATION vs REFINEMENT
% Variable notation matches up with Wikipedia
% (https://en.wikipedia.org/wiki/Brier_score)
f_k = unique(pi);
K = length(f_k);
o_k = zeros(K, 1);
n_k = zeros(K, 1);

for k = 1 : K
    position_aux = find(pi == f_k(k, 1));
    n_k(k, 1) = length(position_aux);
    o_k(k, 1) = mean(Y(position_aux));
end

Brier_Score.Calibration = sum( n_k .* (f_k - o_k).^(2) ) / T;
Brier_Score.Refinement = sum( n_k .* ( o_k .* (1 - o_k) ) ) / T;
Brier_Score.Sumcheck = Brier_Score.Calibration + Brier_Score.Refinement;



end
