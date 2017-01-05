classdef Ebbinghaus
    %Data class to store Ebbinghaus results
    properties
        trial_number
        trial_type
        trial_duration
        radius_difference
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %BEGIN METHODS        %%
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        %constructor function from a line of data
        function obj=Ebbinghaus(line)
            if iscell(line)
                dat=line;
            else
                dat=strsplit(line,',');
            end
            obj.trial_number = str2double(dat{4});
            obj.trial_duration=str2double(dat{5});
            obj.radius_difference=str2double(dat{6});
            num = str2double(dat{3});
            if num==1
                obj.trial_type = 'C';
            elseif num==2
                obj.trial_type = 'E';
            end
        end
        
        
        
        
    end
    
end