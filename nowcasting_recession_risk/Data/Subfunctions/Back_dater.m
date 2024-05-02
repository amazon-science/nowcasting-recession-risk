function series_out = Back_dater(TT_Target, TT_Back)
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

% This function backdates the series TT_Target using the series TT_Back. 
% It creates an index number of TT_Back = 1 for the first available obs in 
% TT_Target. Then it backfills TT_Target by applying the index number. The
% result is a data vector with the same size as TT_Target

TT_aux = synchronize(TT_Target, TT_Back);
start_index = find(~isnan(TT_aux{:, 1}) ==1, 1);
TT_aux.index_back = TT_aux{:, 2} ./ TT_aux{start_index, 2};
TT_aux{1:start_index-1, 1} = TT_aux.index_back(1:start_index-1) * TT_aux{start_index, 1};


T = size(TT_aux, 1) - size(TT_Target, 1) + 1;
series_out = TT_aux{T:end, 1};

end
