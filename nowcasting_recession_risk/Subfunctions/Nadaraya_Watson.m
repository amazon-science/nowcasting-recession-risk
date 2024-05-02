function m_hat = Nadaraya_Watson(x_evaluation, Y_sample, X_sample, h)
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

% Nadayara-Watson Estimator for Conditional Expecation
% Kernel: Gaussian Product Kernel
% x_evaluation is evaluation point of conditional expectation of size MxK
% Y_sample is the sample dependent variable of size Tx1
% X_sample are the sample regressors of size TxK

% Number of Evaluation Points
M = size(x_evaluation, 1);

% Sample Size
T = length(Y_sample);

% Number of Predictors
K = size(X_sample, 2);

% Pre-allocation
m_hat = nan(T, 1);



% Estimation
for m = 1 : M

    Num = 0;
    Denom = 0;

    for t = 1 : T
        
        KKK_i = 1;

        for k = 1 : K
            KKK_aux = 1/h(k) * normpdf( (x_evaluation(m, k) - X_sample(t, k))/h(k) );
            KKK_i = KKK_i * KKK_aux;
        end

        Num_aux = KKK_i * Y_sample(t);
        Denom_aux = KKK_i;

        Num = Num + Num_aux;
        Denom = Denom + Denom_aux;              
        
    end

    m_hat(m, 1) = Num/Denom;
    
end

end

















