function [data, last_update, frequency] = haver_multiple(mytoken, series_ids, labels)
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

% This function can pull multiple series from Haver
% It can handle different lengths, but stops if detectes mixed frequency
% The function stores metadata on last update and frequency



% If ticker is empty nothing happens
if isempty(series_ids)
    %warning('Empty ticker')
    data = timetable();
    last_update = [];

else
    % Number of Variables to Pull
    N = length(series_ids);
    
    % First series out of the Loop
    data = fromhaver(series_ids{1}, mytoken);
    data.date = datetime(data.date, 'ConvertFrom', 'datenum');
    data = table2timetable(data);
    
    % Storing Meta-Data on Last Update and Frequency
    last_update.(labels{1}) = datetime(data.Properties.CustomProperties.LastModified,'ConvertFrom', 'datenum');
    last_update.(labels{1}) = datetime(last_update.(labels{1}), 'Format', 'dd-MMM-yy');
    frequency.(labels{1}) = data.Properties.CustomProperties.Frequency;
    
    for index = 2 : N
        % Loading Series One by One
        series_aux = fromhaver(series_ids{index}, mytoken);
        series_aux.date = datetime(series_aux.date, 'ConvertFrom', 'datenum');
        series_aux = table2timetable(series_aux);

        % Storing Meta-Data on Last Update and Frequency
        last_update.(labels{index}) = datetime(series_aux.Properties.CustomProperties.LastModified, 'ConvertFrom', 'datenum');
        last_update.(labels{index}) = datetime(last_update.(labels{index}), 'Format', 'dd-MMM-yy');
        frequency.(labels{index}) = data.Properties.CustomProperties.Frequency;

    
        % Warning is printed with series of different frequency
        if ( frequency.(labels{index-1}) ~= frequency.(labels{index}))
            %warning('Series with Mixed Frequency Detected - Synchronization has been used!')
        end
        
        % Merging Different Series together, this can create timing issues with mixed-frequency
        data = synchronize(data, series_aux);
    

    end
    
    % Renaming Variables
    data.Properties.DimensionNames(1) = {'Date'};
    data.Properties.VariableNames = labels;
end

end
