function [meandOCatgivenT, sedOCatgivenT] = CalculateCIofOC( result, atgivenT )
%CalculateCIofOC

%%
    NUMOFPPOL = result.nofpols;
    NUMOFREPS  = result.nofreps;
    Tfixed = size(result.policy(1).detailed(1).SCeach,2) - 1;
    
    % Create a matrix of OC values at each period and at each replication
    OCmatrix = ones(NUMOFPPOL,NUMOFREPS,Tfixed+1);
    for rep = 1:NUMOFREPS
        for polnum=1:NUMOFPPOL
            OCmatrix(polnum,rep,:) = result.policy(polnum).detailed(rep).OCeach;
        end
    end
    % Create a matrix of differences
    diffOCmatrix = zeros(NUMOFPPOL,NUMOFPPOL,NUMOFREPS,Tfixed-1);
    for stoppingt = 1:Tfixed+1
        trOCmatrix = OCmatrix(:,:,stoppingt)';
        for i=1:NUMOFREPS 
           diffOCmatrix(:,:,i,stoppingt) = bsxfun(@minus,OCmatrix(:,i,stoppingt),trOCmatrix(i,:));
        end
    end
    % Calculate the mean difference and standard error of differences
    meandOCeach = squeeze(mean(diffOCmatrix,3));
    stdevdOCeach = squeeze(std(diffOCmatrix,0,3));
    sedOCeach = squeeze(stdevdOCeach./sqrt(NUMOFREPS));
    
    % Return the statistics at the period given as input
    meandOCatgivenT = meandOCeach(:,:, atgivenT);
    sedOCatgivenT = sedOCeach(:,:, atgivenT);

end

