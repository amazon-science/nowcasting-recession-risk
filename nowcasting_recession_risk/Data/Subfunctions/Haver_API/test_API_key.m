function test_API_key(api_key)
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

% TEST_API_KEY Checks if the provided Haver API key is valid
%
% Input:
%   api_key - Your Haver API key as a string
%
% Output:
%   Displays a message indicating whether the Haver_API_key is valid or not
%
% Example:
%   test_API_key('your_api_key');

    % Input validation
    if ~ischar(api_key) && ~isstring(api_key)
        error('API key must be a string');
    end
    
    % Set up the request
    haver_code = 'GDPH@USECON'; % Example series for testing
    parts = split(haver_code, '@');
    series = parts{1};
    database = parts{2};
    
    url = ['https://api.haverview.com/v4/database/', database, '/series/', series];
    options = weboptions('HeaderFields', {'Content-Type', 'application/json'; ...
                                          'X-API-Key', api_key});
    
    % Make the API request
    try
        response = webread(url, options);
        
        % Check if the response contains expected fields
        if isfield(response, 'dataPoints') && isfield(response, 'description')
            disp('API key is valid.');
        else
            error('Unexpected response structure. API key may be invalid.');
        end
    catch e
        error('Error occurred while testing the API key. Update API key! Error: %s', e.message);
    end
end
