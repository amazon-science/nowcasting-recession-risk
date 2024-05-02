function [outdata]= fromhaver(series,token)
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

%FROMHAVER  Create a table by reading a series from Haver API. 
%   Use the fromhaver function to download data from haver. 
%The fromhaver function creates a table with dates, value,  
% and series metadata.
% Metadata includes Description, LastModified, and the HaverCode 
% Inputs are SERIES:  the desired series name as in HaverView  
% The series name is givens as Series@Database. 
%   E.g. gdp@usecon, ffed@weekly, etc.  

wo = weboptions('HeaderFields',{'Content-Type','application/json'; 'Authorization', token});
urlFixed = 'https://api.haverview.com/v2/data/databases/series/export?content=full&format=json&names=';

wo.Timeout = 20;

url = [urlFixed upper(series)];
dataout = webread(url,wo);

% If Series is Unvailable/Empty, an error message is produced and the process quits
if strcmp(dataout.SeriesDescription, "Series Unavailable")
    error(strcat("Series ", string(series) , " is unavailable - aborting."));
end


DataTable = struct2table(dataout.DataPoints);
date = datenum(DataTable.date);
value = DataTable.nSeriesData;

%If value has no missing elements you don't have to do this step. 
%But if it isnt' then you have to replace the empty values with NaN. 
if iscell(DataTable.nSeriesData);
    %warning('Data Series seems to have missing values,Replacing with NaNs');
    valuefixed = zeros(numel(value),1);  
    for zx=1:numel(value);
        if isnumeric(value{zx})
            if isempty(value{zx})
                valuefixed(zx,1) = NaN;
            else
                valuefixed(zx,1) = value{zx};
            end
        else
            valuefixed(zx,1) = NaN;
        end
    end
    value = valuefixed;
end


outdata = table(date,value);
outdata.Properties.Description = dataout.SeriesDescription;

outdata = addprop(outdata,'HaverCode', 'variable');
outdata.Properties.CustomProperties.HaverCode =  {'date', series};

outdata = addprop(outdata, 'Frequency', 'table');

if (dataout.Frequency == 10)
    outdata.Properties.CustomProperties.Frequency = 'Annual';
elseif (dataout.Frequency == 30)
    outdata.Properties.CustomProperties.Frequency = 'Quarterly';
elseif (dataout.Frequency == 40)
    outdata.Properties.CustomProperties.Frequency = 'Monthly';
elseif (dataout.Frequency == 55)
    outdata.Properties.CustomProperties.Frequency = 'Weekly';
elseif (dataout.Frequency == 60)
    outdata.Properties.CustomProperties.Frequency = 'Daily';
else
    %warning('Unknown Haver Frequency - Please check');
end
    
outdata = addprop(outdata,'LastModified', 'table');
outdata.Properties.CustomProperties.LastModified = datenum(1970,1,1)+dataout.LastModified/(60*60*24);

end



