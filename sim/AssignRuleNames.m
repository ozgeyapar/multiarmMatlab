function [ rulename ] = AssignRuleNames( functionname, functiontype, parameters)
%AssignRuleNames
% PURPOSE: Generates a name for allocation policy or stopping time 
%   that summarizes the tie breaking options and other details
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
    if strcmp(rulename,'PDEDirect')
        if functiontype == 1
            rulename = strcat('cPDE','-tie-',parameters.pdetieoption);
        else
            rulename = 'cPDE';
        end
    end
    if strcmp(rulename,'PDEDirectHeuristic')
        if functiontype == 1
            rulename = strcat('cPDE','-tie-',parameters.pdetieoption);
        else
            rulename = 'cPDE-Heuristic';
        end
    end
    if strcmp(rulename,'PDEUpperNoOpt')
        if functiontype == 1
            rulename = strcat('cPDEUpper(equal)','-tie-',parameters.pdetieoption);
        else
            rulename = 'cPDEUpper(equal)';
        end
    end
    if strcmp(rulename,'PDEUpper')
       if functiontype == 1
            rulename = strcat('cPDEUpper(8)','-tie-',parameters.pdetieoption);
        else
            rulename = 'cPDEUpper(8)';
       end
    end
    if strcmp(rulename,'PDELower')
       if functiontype == 1
             rulename = strcat('cPDELower','-tie-',parameters.pdetieoption);
       else
            rulename = 'cPDELower';
       end
    end
    if strcmp(rulename,'PDEMidpointNoOpt')
       if functiontype == 1
           rulename = strcat('cPDEMid(equal)','-tie-',parameters.pdetieoption);
       else
            rulename = 'cPDEMid(equal)';
       end
    end
    if strcmp(rulename,'PDEMidpoint')
       if functiontype == 1
           rulename = strcat('cPDEMid(alpha*)','-tie-',parameters.pdetieoption);
       else
            rulename = 'cPDEMid(alpha*)';
       end
    end
    if strcmp(rulename,'PDEKGLower')
       if functiontype == 1
           rulename = strcat('max(cPDELower,cKG*)','-tie-',parameters.tieoption);
       else
           rulename = 'max(cPDELower,cKG*)';
       end       
    end
    if strcmp(rulename,'KGLowerRatio')
       if functiontype == 1
           rulename =  strcat('cKG* (ratio)','-tie-',parameters.tieoption);
       else
           rulename = 'cKG* (ratio)';
       end   
    end
    if strcmp(rulename,'CorrelatedKGRatio')
       if functiontype == 1
           rulename =  strcat('cKG1 (ratio)','-tie-',parameters.tieoption);
       else
           rulename = 'cKG1 (ratio)';
       end  
    end
    if strcmp(rulename,'KGLower')
       if functiontype == 1
           rulename = strcat('cKG* (diff)','-tie-',parameters.tieoption);
       else
           rulename = 'cKG* (diff)';
       end   
    end
    if strcmp(rulename,'CorrelatedKG')
       if functiontype == 1
           rulename = strcat('cKG1 (diff)','-tie-',parameters.tieoption);
       else
           rulename = 'cKG1 (diff)';
       end 
    end
    if strcmp(rulename,'IndESPb')
       if functiontype == 1
           rulename = strcat('ESPb','-tie-',parameters.tieoption);
       else
           rulename = 'ESPb';
       end 
    end
    if strcmp(rulename,'IndESPcapB')
       if functiontype == 1
           rulename = strcat('ESPcapB','-tie-',parameters.pdetieoption);
       else
           rulename = 'ESPcapB';
       end 
    end
    if strcmp(rulename,'Fixed')
        rulename = strcat('Fixed','-',num2str(parameters.Tfixed));
    end
    if strcmp(rulename,'Equal')
        rulename = strcat('Equal','-tie-',parameters.tieoption);
    end
    if strcmp(rulename,'Variance')
        rulename = strcat('Variance','-tie-',parameters.tieoption);
    end

end

