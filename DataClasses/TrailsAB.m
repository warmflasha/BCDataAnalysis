classdef TrailsAB
    %Data class to store TrailsAB results
    properties
        duration
        trial_number
        test_type
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %BEGIN METHODS        %%
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        %constructor function from a line of data
        function obj=TrailsAB(line)
            if iscell(line)
                dat=line;
            else
                dat=strsplit(line,',');
            end
            obj.duration=str2double(dat{4});
            obj.trial_number=str2double(dat{7});
            tt=str2double(dat{3});
            if tt == 1
                obj.test_type = 'A';
            elseif tt==2
                obj.test_type = 'B';
            end
            
        end      
    end
end