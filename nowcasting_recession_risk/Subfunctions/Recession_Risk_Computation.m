function Recession_Risk =   Recession_Risk_Computation(posterior, X)
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

T = size(X, 1);
K = size(X, 2);
K_posterior = size(posterior, 1);
B_posterior = size(posterior, 2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sanity Checks

if (K > K_posterior-1)
    error('More predictors than coefficients');
elseif (K < K_posterior-1)
    error('More coefficients than predictors');
end


if ( sum(isnan(X)) > 0 )
    warning('Predictors contain NaNs')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pre-Allocation
Recession_Risk.distribution = zeros(T, B_posterior);


if (K == 1)
     
    X1 = X(:, 1);
        
    for time_index = 1 : T
        linear_combo_aux = posterior(1, :) + posterior(2, :) .* X1(time_index, 1);  
        Recession_Risk.distribution(time_index, :) = exp(linear_combo_aux) ./ (1 + exp(linear_combo_aux));
    end


elseif (K == 2)

    X1 = X(:, 1);
    X2 = X(:, 2);  

    for time_index = 1 : T
        linear_combo_aux = posterior(1, :) + posterior(2, :) .* X1(time_index, 1) + posterior(3, :) .* X2(time_index, 1);  
        Recession_Risk.distribution(time_index, :) = exp(linear_combo_aux) ./ (1 + exp(linear_combo_aux));
    end

elseif (K == 3)

    X1 = X(:, 1);
    X2 = X(:, 2);  
    X3 = X(:, 3);  

    for time_index = 1 : T
        linear_combo_aux = posterior(1, :) + posterior(2, :) .* X1(time_index, 1) + posterior(3, :) .* X2(time_index, 1) + posterior(4, :) .* X3(time_index, 1);  
        Recession_Risk.distribution(time_index, :) = exp(linear_combo_aux) ./ (1 + exp(linear_combo_aux));
    end



else
   error('Function currently does not support more than 3 predictors');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computing Moments of Risk Distribution
Recession_Risk.p50 = prctile(Recession_Risk.distribution, 50, 2);
Recession_Risk.p20 = prctile(Recession_Risk.distribution, 20, 2);
Recession_Risk.p80 = prctile(Recession_Risk.distribution, 80, 2);
Recession_Risk.p05 = prctile(Recession_Risk.distribution, 5, 2);
Recession_Risk.p95 = prctile(Recession_Risk.distribution, 95, 2);
Recession_Risk.p10 = prctile(Recession_Risk.distribution, 10, 2);
Recession_Risk.p90 = prctile(Recession_Risk.distribution, 90, 2);
Recession_Risk.mean = mean(Recession_Risk.distribution, 2);




end




