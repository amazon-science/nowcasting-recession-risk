function CDF_hat = Bayesian_Logit_CDF(posterior, c_set, X)
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

CDF_hat = table();
CDF_hat.c_set = c_set(:);

for c_index = 1 : length(c_set)

    risk_distribution_aux = Recession_Risk_Computation(posterior(:, :, c_index), X);
    CDF_hat.p05(c_index) = risk_distribution_aux.p05;
    CDF_hat.p10(c_index) = risk_distribution_aux.p10;
    CDF_hat.p20(c_index) = risk_distribution_aux.p20;
    CDF_hat.p50(c_index) = risk_distribution_aux.p50;
    CDF_hat.p80(c_index) = risk_distribution_aux.p80;
    CDF_hat.p90(c_index) = risk_distribution_aux.p90;
    CDF_hat.p95(c_index) = risk_distribution_aux.p95;
end    



end
