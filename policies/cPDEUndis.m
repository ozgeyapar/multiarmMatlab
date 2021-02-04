function [ evi] = cPDEUndis( parameters, mu, sigma, i, THoriz, precfactor )
%cPDEUndis
% PURPOSE: Calculates the EVI estimated by cPDE approach for undiscounted
% problem, defined in Chick, Gans, Yapar (2020)
%
% INPUTS: 
% parameters: struct, problem parameters are included as fields (See 
%   ExampleProblemSetup.m for an example of how to generate this struct)
% mu: numerical vector that contains the prior mean vector
% sigma: numerical matrix that contains the prior covariance matrix
% i: numerical scalar, index of the arm whose EVI will be calculated
% THoriz (optional, default = 80): numerical scalar, lookahead this many 
%       steps for adaptive stopping time
% precfactor (optional, default = 30): numerical scalar, controls how 
%       fine the grid is on w-scale.
%
% OUTPUTS: 
% evi: EVI of arm i estimated using cPDE approach
%
% SUGGESTED WORKFLOW: See ExampleProblemSetup.m for an example of 
% generating the 'parameters' input

%%
    %default if input is not given
    if nargin <= 4
        THoriz = 80;    % set to below 0 for infinite horizon. Look ahead this many steps for adaptive stopping time. or 150?
        precfactor = 30;
    elseif nargin == 5
        precfactor = 30;
    end

    generictermreward=@(wvec,s,p1,p2) PDECRNsimplereward(wvec,s,p1,p2); %PDEsimplereward(wvec);   %    % this is valid terminal reward for undiscounted rewards, valued in time s currency
    CFApproxValuefunc=@(wvec,s,p1,p2) PDECRNsimplereward(wvec,s,p1,p2); %PDECFApproxValue(wvec,s,p1); % PDECFCRNApproxValue(wvec,s,p1,p2);   % this is valid terminal reward for undiscounted rewards, valued in time s currency
    %upperNoDisc=@(s,p1,p2) CFApproxBoundW(s); %CFCRNApproxBoundW(s);
    %upperNoDisc=@(s,p1,p2) CFApproxBoundW(s); %CFCRNApproxBoundW(s,p1,p2);
    upperNoDisc=@(s,p1,p2) CFCRNApproxBoundW(s,p1,p2);

    % set the prior mean and variance and the lambda vector
    myLambdaMat = diag(parameters.lambdav);   % put this to be the diagonal with the sampling variances
    efnsi = myLambdaMat(i,i)/sigma(i,i);       % effective number of samples in prior distribution

    baseparams = { 'online', 0, 'DoPlot', 0, 'DoFileSave', 0 }; % NOTE: DoSaveFile is default by true, 
    CFfunctionset = {'termrewardfunc', generictermreward, 'approxvaluefunc', CFApproxValuefunc, 'approxmethod', upperNoDisc}; % use this to have KG* type rule at time 'infinity' for ca

    % First, set up the parameters for the scaling to account for
    % normal distribution.
    %shiftval = mu(i);   
    shiftval = max(mu);   % shifting should not change theoretical EVI, but may make some of the computations more stable if shifted so 'best' has mean 0
    myvec = mu - shiftval; % need to add this back after computing result (not for the EVI)

    CFparamvec = { 'tEND', efnsi+THoriz, 'precfactor', precfactor, 'ceilfactor', 1.15, 'finiteT', (THoriz > 0)  };
    CFscalevec = {'c', parameters.c(i)/parameters.P, 'sigma', sqrt(parameters.lambdav(i)), 'discrate', 0.0, 'P', parameters.P, 'I', parameters.I};

    scalevec = CFscalevec;
    paramvec = [CFparamvec, CFfunctionset, baseparams];
    [scale, param] = PDEInputConstructor( scalevec, paramvec );
    [scale, ~] = PDEInputValidator( scale, param );

    %Convert the problem into simplified linear version which includes only
    %the alternatives which might become best, and past this to the
    %terminal reward function for correlated arms.
    [a,b,d,Mprime] = TransformtoLinearVersion( scale.beta * myvec, scale.beta^2 * sigma, parameters, i );
    if Mprime == 1 %there is no value in sampling and it is optimal to stop immediately. 
        %Ozge note: PDESolnCompute does not stop in this case, so this if clause is needed
        evi = 0;
    else
        [rewardg0,g0] = max(a); %current best alternative
        distribparams = { 'myi', i, 't0', efnsi, 'myMutVec', myvec', 'mySigtMat', sigma , 'myLambdaMat', myLambdaMat, 'a', a, 'b', b, 'd', d, 'Mprime', Mprime, 'g0', g0, 'rewardg0', rewardg0};

        paramvec = [CFparamvec, CFfunctionset, baseparams, distribparams];
        [scale, param] = PDEInputConstructor( scalevec, paramvec );
        [scale, param] = PDEInputValidator( scale, param );

        %tic
        %[rval, MAXFiles] = PDESolnCompute(scale, param);
        [~, ~, output] = PDESolnCompute(scale, param); % if DoFileSave flag is 0, then output is a structure with full set of data rather 

        if max(size(output)) == 0
            kgistar = cKGstarUndis( parameters, mu, sigma, i );
            evi =  parameters.P*log(kgistar);
            warning('PDESolnCompute threw an error. Used cKG* for EVI instead.')
            %save('ouch2.mat','scale','param','output')
        else
            % Load in the data structures form those computations
            output.Bwsmatrix = output.Bwsmatrix;
            %toc
            s0 = 1/(scale.gamma * efnsi);
            %        evalinfo =  interp2(outpumyMut t.svec,output.wvec,output.Bwsmatrix,s0,scale.beta*0.0)/scale.beta; 
            %evi = interp2(output.svec,output.wvec,output.Bwsmatrix,s0,scale.beta*myvec(i))/scale.beta;
            evi = interp2(output.svec,output.wvec,output.Bwsmatrix,s0,scale.beta*0)/scale.beta;
            evi = parameters.P*(evi);
            %Ozge: Add shiftval?

        end
    end

end