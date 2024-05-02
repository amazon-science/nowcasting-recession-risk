function shaded_area_out = confidence_bands(x, y1, y2, color, alpha_input)
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

x = x';
y1 = y1';
y2 = y2';
y = [y1; (y2-y1)]'; 
shaded_area_out = area(x, y);
set(shaded_area_out(1), 'FaceColor', 'none')
set(shaded_area_out(2), 'FaceColor', color)
set(shaded_area_out(2), 'FaceAlpha', alpha_input)
set(shaded_area_out, 'LineStyle', 'none')

end
