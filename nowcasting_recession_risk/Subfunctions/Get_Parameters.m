function Parameters = Get_Parameters()
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

Parameters.Priors = Set_flat_prior(10);

% Increase Draws to Get Stable Bayesian Estimation Results
Parameters.B = 5e4;
Parameters.Burnin_rate = 0.20; 
Parameters.Burnin = Parameters.B * Parameters.Burnin_rate;

end