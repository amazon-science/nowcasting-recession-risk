%% NOWCASTING RECESSION RISK
% Francesco Furno and Domenico Giannone
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Progress Message
disp('Producing Table 4...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loading Baseline In-Sample
load('./Simulations/Baseline_INS.mat');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Brier Scores Tables

Brier_Score = {'Recession'; 'Expansion'; 'Overall'};

US_Both     = round([Brier_Scores.US.Baseline.Contraction; Brier_Scores.US.Baseline.Expansion; Brier_Scores.US.Baseline.Total], 3);
US_Macro    = round([Brier_Scores.US.PMI_Manuf.Contraction; Brier_Scores.US.PMI_Manuf.Expansion; Brier_Scores.US.PMI_Manuf.Total], 3);
US_Finance  = round([Brier_Scores.US.CISS.Contraction; Brier_Scores.US.CISS.Expansion; Brier_Scores.US.CISS.Total], 3);

EA_Both     = round([Brier_Scores.EA.Baseline.Contraction; Brier_Scores.EA.Baseline.Expansion; Brier_Scores.EA.Baseline.Total], 3);
EA_Macro    = round([Brier_Scores.EA.ESI.Contraction; Brier_Scores.EA.ESI.Expansion; Brier_Scores.EA.ESI.Total], 3);
EA_Finance  = round([Brier_Scores.EA.CISS.Contraction; Brier_Scores.EA.CISS.Expansion; Brier_Scores.EA.CISS.Total], 3);


Table4 = table(Brier_Score, US_Both, US_Macro, US_Finance, EA_Both, EA_Macro, EA_Finance);
writetable(Table4, './Output/Table_4.xlsx');

