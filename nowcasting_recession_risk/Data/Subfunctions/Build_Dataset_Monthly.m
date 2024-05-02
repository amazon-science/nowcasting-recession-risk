function Dataset_out = Build_Dataset_Monthly(Spec, mytoken)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Data = haver_multiple(mytoken, Ticker{1}, Label{1});
Data_d = retime(Data, 'monthly', 'mean');

Data_weekly = haver_multiple(mytoken, Ticker{2}, Label{2});
Data_w = retime(Data_weekly, 'monthly', 'mean');

Data_m = haver_multiple(mytoken, Ticker{3}, Label{3});



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Merge
Dataset_out = synchronize(Data_d, Data_m);
Dataset_out = synchronize(Dataset_out, Data_w);



end