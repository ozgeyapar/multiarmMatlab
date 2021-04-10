function [ rulename ] = AssignPolicyNames( functionname, functiontype, randprob, Tfixed)
%AssignPolicyNames
% PURPOSE: Generates a name for allocation policy or stopping time 
%   to be used in legends
%
% INPUTS: 
% functionname: string, use func2str when inputting
% functiontype: numerical, 1 or 2. 1 for 'allocation' and 2 for 'stopping'
% parameters: struct, problem parameters are included as fields (See 
%   ExampleProblemSetup.m for an example of how to generate this struct)
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
           rulename =  'cKG\fontsize{20}\ast';
       else
           rulename = 'cKG\fontsize{20}\ast';
       end   
    end
    if strcmp(rulename,'cKG1')
       if functiontype == 1
           rulename =  'cKG\fontsize{20}1';
       else
           rulename = 'cKG\fontsize{20}1';
       end  
    end
    if strcmp(rulename,'cKGstarRatio')
       if functiontype == 1
           rulename = 'cKG\fontsize{20}\ast';
       else
           rulename = 'cKG\fontsize{20}\ast';
       end   
    end
    if strcmp(rulename,'cKG1Ratio')
       if functiontype == 1
           rulename = 'cKG\fontsize{20}1';
       else
           rulename = 'cKG\fontsize{20}1';
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
    if randprob >= 1
        rulename = 'Random';
    elseif randprob > 0
        rulename = strcat(rulename, ' with p = ', randprob);
    end
end

