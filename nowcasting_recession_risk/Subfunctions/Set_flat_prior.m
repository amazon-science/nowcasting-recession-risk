function Prior_Flat = Set_flat_prior(sigma)
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

Prior_Flat.intercept.mean = 0;
Prior_Flat.intercept.sigma = sigma;
Prior_Flat.X1.mean = 0;
Prior_Flat.X1.sigma = sigma;
Prior_Flat.X2.mean = 0;
Prior_Flat.X2.sigma = sigma;
Prior_Flat.X3.mean = 0;
Prior_Flat.X3.sigma = sigma;

end