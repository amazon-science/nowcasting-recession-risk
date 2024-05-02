function posterior_joint = Bayesian_Logit(Y, X, Parameters)
% Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
% SPDX-License-Identifier: Apache-2.0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Priors = Parameters.Priors;
B = Parameters.B;
Burnin = Parameters.Burnin;
T_delay = 0;


Y = Y(1:end-T_delay, :);
X = X(1:end-T_delay, :);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T = length(Y);
K = size(X, 2);
initial = zeros(K+1, 1)';
slicer_width = 5 * ones(K+1, 1)';

if (K == 2)

    % Auxiliary Vars
    X1 = X(:, 1);
    X2 = X(:, 2);
    
    % Logit Link Function
    logit_link = @(beta, X1, X2) exp( beta(1)+ beta(2).* X1 + beta(3) .* X2)./(1 + exp( beta(1)+ beta(2).* X1 + beta(3) .* X2 ));

    % Priors' pdfs
    priors.intercept = @(beta) normpdf(beta, Priors.intercept.mean, Priors.intercept.sigma);
    priors.X1 = @(beta) normpdf(beta, Priors.X1.mean, Priors.X1.sigma);
    priors.X2 = @(beta) normpdf(beta, Priors.X2.mean, Priors.X2.sigma);

    % Posterior Kernel
    posterior_kernel = @(beta) prod( binopdf(Y, ones(T, 1), logit_link(beta, X1, X2)) ) ...  
            * priors.intercept(beta(1)) * priors.X1(beta(2))* priors.X2(beta(3)); 

    % Posterior Simulations
    posterior_joint = slicesample(initial, B, 'pdf', posterior_kernel, 'width', slicer_width);
    posterior_joint = posterior_joint';
    posterior_joint = posterior_joint(:, Burnin+1:end);

elseif (K == 1)

    % Auxiliary Vars
    X1 = X(:, 1);
    
    % Logit Link Function
    logit_link = @(beta, X1, X2) exp( beta(1)+ beta(2).* X1 )./(1 + exp( beta(1)+ beta(2).* X1 ) );
    
    
    % Priors' pdfs
    priors.intercept = @(beta) normpdf(beta, Priors.intercept.mean, Priors.intercept.sigma);
    priors.X1 = @(beta) normpdf(beta, Priors.X1.mean, Priors.X1.sigma);
    priors.X2 = @(beta) normpdf(beta, Priors.X2.mean, Priors.X2.sigma);
        
    % Posterior Kernel
    posterior_kernel = @(beta) prod( binopdf(Y, ones(T, 1), logit_link(beta, X1)) ) ...  
                * priors.intercept(beta(1)) * priors.X1(beta(2)) ; 
    
    
    % Posterior Simulations
    posterior_joint = slicesample(initial, B, 'pdf', posterior_kernel, 'width', slicer_width);
    posterior_joint = posterior_joint';
    posterior_joint = posterior_joint(:, Burnin+1:end);

elseif (K==3)

    % Auxiliary Vars
    X1 = X(:, 1);
    X2 = X(:, 2);
    X3 = X(:, 3);
    
    % Logit Link Function
    logit_link = @(beta, X1, X2, X3) exp( beta(1)+ beta(2).* X1 + beta(3) .* X2 + beta(4) .* X3) ...
        ./(1 + exp( beta(1)+ beta(2).* X1 + beta(3) .* X2 + beta(4) .* X3));

    % Priors' pdfs
    priors.intercept = @(beta) normpdf(beta, Priors.intercept.mean, Priors.intercept.sigma);
    priors.X1 = @(beta) normpdf(beta, Priors.X1.mean, Priors.X1.sigma);
    priors.X2 = @(beta) normpdf(beta, Priors.X2.mean, Priors.X2.sigma);
    priors.X3 = @(beta) normpdf(beta, Priors.X3.mean, Priors.X3.sigma);

    % Posterior Kernel
    posterior_kernel = @(beta) prod( binopdf(Y, ones(T, 1), logit_link(beta, X1, X2, X3)) ) ...  
            * priors.intercept(beta(1)) * priors.X1(beta(2)) * priors.X2(beta(3)) * priors.X3(beta(4)); 

    % Posterior Simulations
    posterior_joint = slicesample(initial, B, 'pdf', posterior_kernel, 'width', slicer_width);
    posterior_joint = posterior_joint';
    posterior_joint = posterior_joint(:, Burnin+1:end);

else
    error('Function currently does not support more than 3 predictors');
end




end