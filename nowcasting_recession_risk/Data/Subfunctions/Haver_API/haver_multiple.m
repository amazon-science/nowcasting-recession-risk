function [data, last_update, frequency] = haver_multiple(Haver_API_key, series_ids, labels)
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

% HAVER_MULTIPLE Retrieves multiple time series from Haver Analytics API
%
% This function pulls multiple series from Haver Analytics, converts them to a 
% timetable format, and synchronizes the data. It can handle series of different 
% lengths but will warn if series have mixed frequencies.
%
% Inputs:
%   Haver_API_key  - Haver Analytics API key (string)
%   series_ids  - Cell array of Haver codes in format 'series@database' 
%                 (e.g., {'GDPH@USECON', 'N997CE@EUDATA'})
%   labels      - Cell array of strings for naming the output variables
%                 (must match length of series_ids)
%
% Outputs:
%   data        - Timetable containing all requested series, synchronized by date
%                 Column names will match the provided labels
%   last_update - Structure containing the last update date for each series
%                 Field names match the provided labels
%   frequency   - Structure containing the frequency of each series
%                 (Annual, Quarterly, Monthly, Weekly, or Daily)
%                 Field names match the provided labels
%
% Example:
%   Haver_API_key = 'your_api_key';
%   series = {'GDPH@USECON', 'PGDP@USECON'};
%   labels = {'GDP', 'PGDP'};
%   [data, last_update, freq] = haver_multiple(Haver_API_key, series, labels);
%
% Notes:
%   - If series_ids is empty, returns an empty timetable
%   - Series with different frequencies will be synchronized, but this may
%     create timing misalignments
%   - Date format in last_update is 'dd-MMM-yy'

% If ticker is empty nothing happens
if isempty(series_ids)
    %warning('Empty ticker')
    data = timetable();
    last_update = [];

else
    % Number of Variables to Pull
    N = length(series_ids);
    
    % First series out of the Loop
    data = fromhaver(series_ids{1}, Haver_API_key);
    data.date = datetime(data.date, 'ConvertFrom', 'datenum');
    data = table2timetable(data);
    
    % Storing Meta-Data on Last Update and Frequency
    last_update.(labels{1}) = datetime(data.Properties.CustomProperties.LastModified,'ConvertFrom', 'datenum');
    last_update.(labels{1}) = datetime(last_update.(labels{1}), 'Format', 'dd-MMM-yy');
    frequency.(labels{1}) = data.Properties.CustomProperties.Frequency;
    
    for index = 2 : N
        % Loading Series One by One
        series_aux = fromhaver(series_ids{index}, Haver_API_key);
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
