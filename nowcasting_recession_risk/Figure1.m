%% NOWCASTING RECESSION RISK
% Francesco Furno and Domenico Giannone
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Progress Message
disp('Producing Figure 1...');

% Loading Data
load('./Data/Data.mat');


% UNITED STATES
Y_US_aux = Data.US.NBER_Recession;
X_US_aux = [Data.US.CISS, Data.US.PMI_Manuf];

index_recession_US = logical(Data.US.NBER_Recession);
index_expansion_US = logical(1 - Data.US.NBER_Recession);


% EURO AREA
Y_EA_aux = Data.EA.CEPR_Recession;
X_EA_aux = [Data.EA.CISS, Data.EA.ESI];

index_recession_EA = logical(Data.EA.CEPR_Recession);
index_expansion_EA = logical(1 - Data.EA.CEPR_Recession);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run('./Subfunctions/Plot_Parameters.m');

Figure_Intuition = figure;
set(gcf, 'Color', 'w', 'Position', Plt_size_Brier);
subplot(1, 2, 1)
hold on
plota = scatter(Data.US.CISS(index_recession_US), Data.US.PMI_Manuf(index_recession_US), "filled");
plotb = scatter(Data.US.CISS(index_expansion_US), Data.US.PMI_Manuf(index_expansion_US), "filled");
hold off
xlabel('Financial (CISS)');
ylabel('Macro (PMI)');
title('United States')
legend([plota, plotb], 'Recessions', 'Expansions')

subplot(1, 2, 2)
hold on
plota = scatter(Data.EA.CISS(index_recession_EA), Data.EA.ESI(index_recession_EA), "filled");
plotb = scatter(Data.EA.CISS(index_expansion_EA), Data.EA.ESI(index_expansion_EA), "filled");
hold off
xlabel('Financial (CISS)');
ylabel('Macro (ESI)');
title('Euro Area')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
exportgraphics(Figure_Intuition, './Output/Figure_1.png', 'Resolution', 400)








