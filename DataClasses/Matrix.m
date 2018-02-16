
classdef Matrix
    %Data class to store Flanker results
    properties
        correct
        duration
        trial_number
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %BEGIN METHODS        %%
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        %constructor function from a line of data
        function obj=Matrix(line)
            if iscell(line)
                dat=line;
            else
                dat=strsplit(line,',');
            end
            if strcmpi(dat{4}(1),'T')
                obj.correct = true;
            elseif strcmpi(dat{4}(1),'F')
                obj.correct = false;
            end
            obj.trial_number = str2double(dat{3});         
            obj.duration = str2double(dat{5});
        end
    end    
end