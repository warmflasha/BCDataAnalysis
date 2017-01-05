classdef Stroop
    %Data class to store Stroop results
    properties
        trial_number
        number_attempts
        trial_type
        reaction_time
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %BEGIN METHODS        %%
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        %constructor function from a line of data
        function obj=Stroop(varargin)
            if nargin == 1
                line = varargin{1};
                if iscell(line)
                    dat=line;
                else
                    dat=strsplit(line,',');
                end
                obj.trial_number = str2double(dat{4});
                obj.number_attempts=str2double(dat{5});
                tt = str2double(dat{3});
                if tt == 1
                    tt = 'N';
                elseif tt == 2 
                    tt = 'I';
                elseif tt == 3
                    tt = 'C';
                end
                obj.trial_type=tt;
                
                obj.reaction_time=str2double(dat{6});
            end
            
        end
        
        
        
        
    end
    
end