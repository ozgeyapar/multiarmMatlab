function [ rulename ] = AssignPolicyNames( functionname, functiontype, rtype, rprob, Tfixed)
%AssignPolicyNames
% PURPOSE: Generates a name for allocation policy or stopping time 
%   to be used in legends
%
% INPUTS: 
% functionname: string, use func2str when inputting
% functiontype: numerical, 1 or 2. 1 for 'allocation' and 2 for 'stopping'
% rtype: randomization type for each allocation policy
% rprob: randomization probability for each allocation policy
% Tfixed: fixed stopping time for fixed stopping policy .
%
% OUTPUTS: 
% rulename: string that summarizes the allocaiton policy or stopping time 
%   name
%
%%

    if functiontype == 1
        temp = strrep(strsplit(functionname,{'(',')'},'CollapseDelimiters',true),'Allocation','');
    elseif functiontype == 2
        temp = strrep(strsplit(functionname,{'(',')'},'CollapseDelimiters',true),'Stopping','');
    else
        warning('function type should be either 1 or 2');
    end
    rulename = char(temp(3));
    if strcmp(rulename,'cPDE')
        if functiontype == 1
            rulename = 'cPDE';
        else
            rulename = 'cPDE';
        end
    end
    if strcmp(rulename,'cPDEHeu')
        if functiontype == 1
            rulename = 'cPDE';
        else
            rulename = 'cPDE';
        end
    end
    if strcmp(rulename,'cPDEUpperNoOpt')
        if functiontype == 1
            rulename = 'cPDEUpper';
        else
            rulename = 'cPDEUpper';
        end
    end
    if strcmp(rulename,'cPDEUpperOpt')
       if functiontype == 1
            rulename = 'cPDEUpper(8)';
        else
            rulename = 'cPDEUpper(8)';
       end
    end
    if strcmp(rulename,'cPDELower')
       if functiontype == 1
            rulename = 'cPDELower';
       else
            rulename = 'cPDELower';
       end
    end
    if strcmp(rulename,'cKGstar')
       if functiontype == 1
           rulename =  'cKG_\ast';
       else
           rulename = 'cKG_\ast';
       end   
    end
    if strcmp(rulename,'cKG1')
       if functiontype == 1
           rulename =  'cKG_1';
       else
           rulename = 'cKG_1';
       end  
    end
    if strcmp(rulename,'cKGstarRatio')
       if functiontype == 1
           rulename = 'cKG_\ast';
       else
           rulename = 'cKG_\ast';
       end   
    end
    if strcmp(rulename,'cKG1Ratio')
       if functiontype == 1
           rulename = 'cKG_1';
       else
           rulename = 'cKG_1';
       end 
    end
    if strcmp(rulename,'IndESPb')
       if functiontype == 1
           rulename = 'ESPb';
       else
           rulename = 'ESPb';
       end 
    end
    if strcmp(rulename,'IndESPcapB')
       if functiontype == 1
           rulename = 'ESPB';
       else
           rulename = 'ESPB';
       end 
    end
    if strcmp(rulename,'Fixed')
        rulename = strcat('Fixed','-',num2str(Tfixed));
    end
    if strcmp(rulename,'Equal')
        rulename = 'Equal';
    end
    if strcmp(rulename,'Variance')
        rulename = 'Variance';
    end
    if functiontype == 1
        if rprob >= 1
            rulename = 'Random';
        elseif rprob > 0 && rtype == 1
            rulename = strcat(rulename, ' with p = ', num2str(rprob));
        elseif rprob > 0 && rtype == 2
            rulename = strcat(rulename, '-TTVS with p = ', num2str(rprob));
        end
    end
end

