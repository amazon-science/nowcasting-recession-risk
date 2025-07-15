function Dataset_out = Subsample_Selector(Dataset_in, T_start, T_end)
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

time_range_aux = (Dataset_in.Properties.RowTimes >= T_start & Dataset_in.Properties.RowTimes <= T_end);
Dataset_out = Dataset_in(time_range_aux, :);



end
