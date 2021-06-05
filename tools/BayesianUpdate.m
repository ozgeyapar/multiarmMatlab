function [ newmu, newsigma ] = BayesianUpdate (mu, sigma, i, y, lambda)
%BayesianUpdate
% PURPOSE: Updates Multivariate Normal Distribution prior when we sample 
% from arm i and obtain sample y
% This function uses Potter Square Root Filter
% (http://ccar.colorado.edu/asen5070/handouts/PSRF2.pdf)
%
% INPUTS: 
%   mu, sigma: Current mean vector and covariance matrix
%   i: index of the alternative we sampled from
%   y: sample obtained for arm i
%   lambda: Sampling variance for alternative i
% 
% OUTPUTS: 
% newmu, newsigma: Updated mean and covariance matrix
%
%%

% if we have perfect information about the alternative, do not update
if (lambda == 0 && sigma(i,i)==0)
    warning('Zero sampling and prior variance, no update');
	newmu = mu;
	newsigma = sigma;
	return
end

M = size(sigma,2);
%Cholesky decomposition sigma = W*W'
W = cholcov(sigma)';
if size(W,2)<M || size(W,1)<M
    [U,D] = eig(sigma);
    W = sqrt(D) * U';
    W = real(W');
end

% Observation model
M = length(mu);  % compute number of alternatives
H = full(sparse(1,i,1,1,M)); %row unit vector with 1 for the ith element

F =W'*H';
alpha = 1/(F'*F+lambda);
K = alpha*W*F;

[m n] = size(y);
if m>1   % force y to be row vector
    y = y';
end
diff = y - mu(i); %we observe only one alternative
newmu = mu(:) * ones(size(y)) + K*diff;

gamma = 1/(1+alpha*lambda);
newW = W - gamma*K*F';
newsigma = newW*newW';

end

