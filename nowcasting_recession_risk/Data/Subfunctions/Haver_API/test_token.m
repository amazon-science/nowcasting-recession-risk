function test_token(token)
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

% Make a test request to check if the token is valid
wo = weboptions('HeaderFields',{'Content-Type','application/json'; 'Authorization', token});
urlFixed = 'https://api.haverview.com/v2/data/databases/series/export?content=full&format=json&names=';
url = [urlFixed 'GDPH@USECON'];

try
    % Make an HTTP GET request to the API
    response = webread(url, wo);

    % Display the response if successful
    disp('Token is valid.');

catch ME
    % Display error message if the request fails
    error('Error occurred while testing the token. Update Token!');
end


