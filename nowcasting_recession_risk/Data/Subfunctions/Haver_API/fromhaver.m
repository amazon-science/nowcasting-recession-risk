function outdata = fromhaver(haver_code, api_key)
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

% FROMHAVER Retrieves time series data from Haver Analytics API
%
% Inputs:
%   api_key    - Your Haver API key as a string
%   haver_code - Haver code in the format 'series@database' (e.g., 'N997CE@EUDATA')
%
% Output:
%   outdata - MATLAB table containing the time series data with the same structure
%             as the fromhaver function output
%
% Example:
%   data = getHaverData('your_api_key', 'N997CE@EUDATA');

    % Input validation
    if ~ischar(api_key) && ~isstring(api_key)
        error('API key must be a string');
    end
    
    if ~ischar(haver_code) && ~isstring(haver_code)
        error('Haver code must be a string');
    end
    
    % Parse the haver_code to extract series and database
    parts = split(haver_code, '@');
    if length(parts) ~= 2
        error('Haver code must be in format "series@database"');
    end
    
    series = parts{1};
    database = parts{2};
    
    % Set up the request
    url = ['https://api.haverview.com/v4/database/', database, '/series/', series];
    options = weboptions('HeaderFields', {'Content-Type', 'application/json'; ...
                                          'X-API-Key', api_key});
    
    % Make the API request
    try
        response = webread(url, options);
    catch e
        error('Failed to retrieve data from Haver API: %s', e.message);
    end
    
    % Extract data points
    if ~isfield(response, 'dataPoints') || isempty(response.dataPoints)
        error('No data points found in the response');
    end
    
    data_points = response.dataPoints;
    
    % Create arrays for time and values
    dates = cell(length(data_points), 1);
    values = zeros(length(data_points), 1);
    
    % Extract dates and values
    for i = 1:length(data_points)
        dates{i} = data_points(i).date;
        if isempty(data_points(i).nSeriesData)
            values(i) = NaN;
        else
            values(i) = data_points(i).nSeriesData;
        end
    end
    
    % Convert date strings to datenum
    date = datenum(dates);
    
    % Create a table with date and value columns
    outdata = table(date, values, 'VariableNames', {'date', 'value'});
    
    % Add description as table property
    outdata.Properties.Description = response.description;
    
    % Add HaverCode custom property
    outdata = addprop(outdata, 'HaverCode', 'variable');
    outdata.Properties.CustomProperties.HaverCode = {'date', haver_code};
    
    % Add Frequency custom property
    outdata = addprop(outdata, 'Frequency', 'table');
    if (response.frequency == 10)
        outdata.Properties.CustomProperties.Frequency = 'Annual';
    elseif (response.frequency == 30)
        outdata.Properties.CustomProperties.Frequency = 'Quarterly';
    elseif (response.frequency == 40)
        outdata.Properties.CustomProperties.Frequency = 'Monthly';
    elseif (response.frequency == 55)
        outdata.Properties.CustomProperties.Frequency = 'Weekly';
    elseif (response.frequency == 60)
        outdata.Properties.CustomProperties.Frequency = 'Daily';
    else
        % Unknown frequency
    end
    
    % Add LastModified custom property
    % Note: We need to convert the LastModified timestamp to the same format
    % The original function expects a timestamp in seconds since epoch and converts it
    outdata = addprop(outdata, 'LastModified', 'table');
    
    % Get the last modified date from the response
    % Assuming datetimeLastModified is in ISO format like in the Python version
    if isfield(response, 'datetimeLastModified')
        lastMod = datenum(response.datetimeLastModified);
    else
        % If field is missing, use current date
        lastMod = now;
    end
    
    outdata.Properties.CustomProperties.LastModified = lastMod;
end