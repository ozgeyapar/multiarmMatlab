function [ i ] = AllocationTieBreaker( parameters, ind, muin, sigmain, option)
%AllocationTieBreaker
% PURPOSE: Used to break the ties when an allocation policy estimates the
% same EVI for multiple arms.
%
% INPUTS: 
% parameters: struct, problem parameters are included as fields 
% ind: indices of the arms that the allocation policy tied among
% muin: numerical vector that contains the prior mean vector
% sigmain: numerical matrix that contains the prior covariance matrix
% option: string, following options are available, if the option provided 
%   is not defined random is used as default.
%    - random (default) breaks ties using uniform randomly
%    - efns breaks ties by selecting the arm with lowest effective number 
%       of samples,
%    - lexi breaks ties lexicographically
%    - kgstarold breaks ties by selecting the arm with highest cKGstar 
%       estimation (difference definition)
%    - kgstar:highest breaks ties by selecting the arm with highest cKGstar 
%       estimation (ratio definition)
%    - If cKGstar tie breaker also ties, it uses random
%
% OUTPUTS: 
% i: index of the arm to be sampled
%
% WORKFLOW: Called in Allocation* files
%%
if strcmp(option, 'random')
    %use default: random
    ri = randi([1,size(ind,2)],1,1);
    i = ind(ri);
elseif strcmp(option, 'lexi')
    %alternative with lowest index
    i = ind(1);
elseif strcmp(option, 'efns')
    %alternative with lowest effective number of samples
    efns = zeros(1,size(ind,2)); %preallocation for speed
    for j = 1:size(ind,2)
        efns(j) = parameters.lambdav(ind(j))/sigmain(ind(j),ind(j));
    end
    [efnsmin,ri] = min(efns);
    
    idx = find(efns == efnsmin);
    if size(idx,2) > 1
        i = randi([1,size(idx,2)],1,1);
        ri = idx(i);
    end
    i = ind(ri);
elseif strcmp(option, 'kgstarold')
    %break ties with kgstar between the ones original rule is tied, uses
    %the difference definition for KG value
    kg = zeros(1,size(ind,2)); %preallocation for speed
    for j = 1:size(ind,2)
        if parameters.delta == 1           
            [ ~, kg(j)] = cKGstarUndis( parameters, muin, sigmain, ind(j) );
        elseif parameters.delta < 1 && parameters.delta > 0
            kg(j) = cKGstarDis( parameters, muin, sigmain, ind(j) );
        else
            warning('cannot calculate undiscounted upper bound: discounting rate delta has to be between 0 and 1');
            return;
        end
    end
    [kgi,ri] = max(kg);
    %random tie breaker if kgstar also ties
    idx = find(kg == kgi);
    if size(idx,2) > 1  
        i = randi([1,size(idx,2)],1,1);
        ri = idx(i);
    end
    i = ind(ri);
elseif strcmp(option, 'kgstar')
    %break ties with kgstar between the ones original rule is tied, uses
    %the ratio definition for KG value
    kg = zeros(1,size(ind,2)); %preallocation for speed
    for j = 1:size(ind,2)
        if parameters.delta == 1           
            [ ~, kg(j)] = cKGstarUndisRatio( parameters, muin, sigmain, ind(j) );
        elseif parameters.delta < 1 && parameters.delta > 0
            kg(j) = cKGstarDisRatio( parameters, muin, sigmain, ind(j) );
        else
            warning('cannot calculate undiscounted upper bound: discounting rate delta has to be between 0 and 1');
            return;
        end
    end
    [kgi,ri] = max(kg);
    %random tie breaker if kgstar also ties
    idx = find(kg == kgi);
    if size(idx,2) > 1  
        i = randi([1,size(idx,2)],1,1);
        ri = idx(i);
    end
    i = ind(ri);
else
    %use random
    ri = randi([1,size(ind,2)],1,1);
    i = ind(ri);
end

end

