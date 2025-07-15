%% NOWCASTING RECESSION RISK
% Francesco Furno and Domenico Giannone
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

% Note #1: Some scripts load results from previous scripts --> Run sequentially
% Note #2: Some scripts use MATLAB's parallelization via parfor loops
% Note #3: To generate the dataset you need a valid Haver API key, or
% manually rebuild the dataset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preliminaries
clear, clc, close all;
addpath(genpath('./Subfunctions/'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build/Rebuild the data (paste your Haver API key as a string)
addpath(genpath('./Data/'));
Haver_API_key = '';
Build_Data(Haver_API_key);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Results
run('./Figure1.m');
run('./Figure2367A3.m');
run('./Table_4.m');
run('./Figure4.m'); % Parallelized
run('./Figure8.m');
run('./Figure9.m');
run('./Figure10.m'); % Parallelized
run('./Figure12.m'); % Parallelized
run('./Figure13_Table5a.m');

run('./FigureA1A2.m');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figures that require additional data

% Figure 11, 14 require download of FED Philadelphia Real-Time GDP Vintages
% See Data/RGDP_Vintages/README.txt

run('./Figure11.m'); % Parallelized
run('./Figure14_Table5b.m'); % Parallelized


% Figure 5 requires vintages of the ESI indicator that we are unable to share
% See Data/EC_ESI_Vintages/README.txt

run('./Figure5.m');



