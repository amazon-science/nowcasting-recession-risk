function Build_Data(Haver_API_key)
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Progress Message
disp('Building Dataset...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Working Directory
Main_Path = pwd;
Data_Path = fileparts(which('Build_Data'));
cd(Data_Path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Building Data
Spec_All            = readtable('Data_Tickers.csv'); 
Spec_US             = Spec_All(strcmp(Spec_All.Dataset, "US"), 1:end-1);
Spec_EA             = Spec_All(strcmp(Spec_All.Dataset, "EA"), 1:end-1);
Spec_US_Quarterly   = Spec_All(strcmp(Spec_All.Dataset, "US Quarterly"), 1:end-1);
Spec_EA_Quarterly   = Spec_All(strcmp(Spec_All.Dataset, "EA Quarterly"), 1:end-1);


Data.US = Build_Dataset_Monthly(Spec_US, Haver_API_key);
Data.EA = Build_Dataset_Monthly(Spec_EA, Haver_API_key);
Data.US_Quarterly = Build_Dataset_Quarterly(Spec_US_Quarterly, Haver_API_key);
Data.EA_Quarterly = Build_Dataset_Quarterly(Spec_EA_Quarterly, Haver_API_key);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variable Transformations for US Monthly
Data.US.SP500 = [nan(12, 1); Data.US.SP500(12+1:end, 1) ./ Data.US.SP500(1:end-12, 1)];
Data.US.Wkly_Hours = [nan(12, 1); Data.US.Wkly_Hours(12+1:end, 1) ./ Data.US.Wkly_Hours(1:end-12, 1)];
Data.US.NBER_Recession(Data.US.NBER_Recession == -1) = 0;

% CEPR Recessions for the Euro Area at Monthly Frequency
Data.EA = synchronize(Data.EA, retime(Data.EA_Quarterly(:, "CEPR_Recession"), "monthly", 'previous'));

% Backdating Euro Area Real GDP using the AWM Dataset
Data.EA_Quarterly.RGDP = Back_dater(Data.EA_Quarterly(:, "RGDP"), haver_multiple(Haver_API_key, {'Q023YER@EUDATA'}, {'RGDP'}));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Selecting Subsamples
T_start = datetime([1980, 1, 1]);
T_end   = datetime([2021, 12, 31]);

Data.US = Subsample_Selector(Data.US, T_start, T_end);
Data.US_Quarterly = Subsample_Selector(Data.US_Quarterly, T_start, T_end);

T_start = datetime([1980, 1, 1]);
Data.EA = Subsample_Selector(Data.EA, T_start, T_end);
Data.EA_Quarterly = Subsample_Selector(Data.EA_Quarterly, T_start, T_end);

% Non-missing Observations for the Euro Area
EA_start_position = find(Data.EA.Date == datetime([1985, 1, 1]));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EA Recession Shades
EA_recession_start_aux = [datetime([2020, 1, 1]); datetime([2011, 10, 1]); datetime([2008, 4, 1]); ...
    datetime([1992, 4, 1]); datetime([1980, 4, 1]); datetime([1974, 10, 1])];

EA_recession_end_aux = [datetime([2020, 7, 1])-1; datetime([2013, 4, 1])-1; datetime([2009, 7, 1])-1; ...
    datetime([1993, 10, 1])-1; datetime([1982, 10, 1])-1; datetime([1975, 4, 1])-1];

EA_Recession_Shades = [EA_recession_start_aux, EA_recession_end_aux];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save("./Data.mat", "Data", "EA_Recession_Shades", "EA_start_position");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Saving Dataset in Excel Format
writetimetable(Data.US, './Data.xlsx', 'Sheet', 'US');
writetimetable(Data.EA, './Data.xlsx', 'Sheet', 'EA');
writetimetable(Data.US_Quarterly, './Data.xlsx', 'Sheet', 'US_Quarterly');
writetimetable(Data.EA_Quarterly, './Data.xlsx', 'Sheet', 'EA_Quarterly');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Restoring Working Directory
cd(Main_Path);

end