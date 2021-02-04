function [ reward, numsamps ] = PDECRNsimplereward( wvec, sval, scale, param )
%PDECRNsimplereward: returns expected reward and 0 added samples to achieve it,
%   using the (w, s) time scale. Useful as generic terminal condition.
%INPUTS:
%   wvec: a column vector of values of w to check, the scaled posterior means of
%       the sampled alternative
%   sval: the time s in the reverse time scale
%   scale: the scal parameter
%   param: the param parameter which assumes a number of additional fields
%       which are required for computing the posterior of each alternative,
%       see the docs for the CRN correlated means.
%OUTPUTS:
%   reward: vector of rewards, written in w coords.
%   numsamps: a vector of number of samples, one for each value of wvec,
%       which is the number of samples taken, written in s coordinates

% first compute the value of Wvec at the later time, for all such wvec
%    reward = max(wvec, 0);
%    numsamps = 0*reward;

% then compute the maximum of the rewards, given the inference to come
    % from the wvec for the given alternative, compute the
    t0plustau = 1/(scale.gamma*sval);
    t0 = param.t0; 
    myi = param.myi;

    % assumes that the parameters which pick the potential best has already
    % been called.
    reward = 0 * wvec;
    for l = 1:param.Mprime-1
        reward = reward + (param.b(l+1)-param.b(l)) * max(0, wvec - abs(param.d(l+1)));
    end
    tau = max(t0plustau - t0, 0);
    numsamps = tau * ones(size(wvec));
	% now do the max, and the number of samples required to achieve it
end
