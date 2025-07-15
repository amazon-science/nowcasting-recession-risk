function recessionplot_dates = Get_shades_quarterly(Dataset)
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

T = size(Dataset, 1);
start_dates = [];
end_dates = [];

for t = 1 : T
    date_aux = Dataset.Properties.RowTimes(t, 1);
    x_aux = Dataset{t, 1};

    if (x_aux == 1)
        year_aux = year(date_aux);
        quarter_aux = quarter(date_aux);
        start_dates = [start_dates; datetime([year_aux, quarter_aux * 3 - 2, 1]) ];
        end_dates = [end_dates; dateshift(datetime([year_aux, quarter_aux * 3 - 2, 1]), "end", "quarter") ];
    end

end

recessionplot_dates = [start_dates, end_dates];


end




