function [cdf_out, xbw, ybw] = LLR_CCDF(y_eval, x_eval, x_data, y_data, xbw, ybw)
% Code from Adrian, Boyarchenko, Giannone - Vulnerable Growth (AER, 2019)
% Adapted from "ComputeNonparCondQuantiles.m"

% Settings
if nargin < 6
    % Manually compute bandwidths if both ybw, xbw not provided
    [xbw, ybw] = ComputeNonparCondCDFbw(x_data, y_data);
end

neval = size(x_eval,1);
[n, q] = size(x_data);


% To speed up iterations, precompute differences and kernel values for x
% xdiff(i, j, s) = Xeval(i, s) - Xfit(j, s)
xdiff = NaN(neval, n, q);
for i = 1:neval
    for j = 1:n
        xdiff(i, j, :) = x_eval(i, :) - x_data(j, :);
    end
end

% xbwmat(i, j, s) = xbw(s)
xbwmat(1, 1, :) = xbw; xbwmat = repmat(xbwmat, neval, n, 1);

% Kmat(i, j) = K_h(Xeval(i, :), Xfit(j, :))
Kmat = prod(normpdf(xdiff ./ xbwmat), 3) / prod(xbw);

% sumKmat = (unscaled) kernel density estimate of marginal density of x
sumKmat = sum(Kmat, 2);


% computing ccdf
cdf_out = ComputeNonparCondCDF(y_eval, y_data, ybw, Kmat, sumKmat);




end

function Feval = ComputeNonparCondCDF(yeval, yfit, ybw, K, sumK)

G = normcdf((yeval - yfit) ./ ybw);
Feval = dot(G, K) / sumK;

end