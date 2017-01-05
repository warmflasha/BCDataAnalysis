classdef DigitSym
    %Data class to store Digit Symbol results
    properties
        duration
        number_attempts
        trial_number
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %BEGIN METHODS        %%
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        %constructor function from a line of data
        %NOTE: data doesn't make sense to me. fix column numbers
        function obj=DigitSym(line)
            if iscell(line)
                dat=line;
            else
                dat=strsplit(line,',');
            end
            obj.duration = str2double(dat{5});
            obj.number_attempts=str2double(dat{6});
            obj.trial_number=str2double(dat{7});
            
        end
    end
end