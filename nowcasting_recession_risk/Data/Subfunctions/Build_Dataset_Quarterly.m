function Dataset_out = Build_Dataset_Quarterly(Spec, Haver_API_key)
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Index_d = strcmp(Spec.Frequency, 'Daily');
Ticker{1} = Spec.Haver_Code(Index_d);
Label{1} = Spec.Label(Index_d);

Index_w = strcmp(Spec.Frequency, 'Weekly');
Ticker{2} = Spec.Haver_Code(Index_w);
Label{2} = Spec.Label(Index_w);

Index_m = strcmp(Spec.Frequency, 'Monthly');
Ticker{3} = Spec.Haver_Code(Index_m);
Label{3} = Spec.Label(Index_m);

Index_m = strcmp(Spec.Frequency, 'Quarterly');
Ticker{4} = Spec.Haver_Code(Index_m);
Label{4} = Spec.Label(Index_m);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Data_d = haver_multiple(Haver_API_key, Ticker{1}, Label{1});
Data_d = retime(Data_d, 'quarterly', 'mean');

Data_w = haver_multiple(Haver_API_key, Ticker{2}, Label{2});
Data_w = retime(Data_w, 'quarterly', 'mean');

Data_m = haver_multiple(Haver_API_key, Ticker{3}, Label{3});
Data_m = retime(Data_m, 'quarterly', 'mean');

Data_q = haver_multiple(Haver_API_key, Ticker{4}, Label{4});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Merge
Dataset_out = synchronize(Data_d, Data_w);
Dataset_out = synchronize(Dataset_out, Data_m);
Dataset_out = synchronize(Dataset_out, Data_q);



end