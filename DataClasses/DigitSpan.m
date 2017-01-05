classdef DigitSpan
    %Data class to store digit span  results
    properties
        trial_number
        string_length
        trial_duration
        correct
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %BEGIN METHODS        %%
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        %constructor function from a line of data
        %NOTE: duration does not appear to be in the data file
        function obj=DigitSpan(line)
            if iscell(line)
                dat=line;
            else
                dat=strsplit(line,',');
            end
            obj.trial_number = str2double(dat{3});
            obj.string_length=str2double(dat{4});
            if strcmpi(dat{5},'TRUE')
                obj.correct = true;
            elseif strcmpi(dat{5},'FALSE')
                obj.correct = false;
            end
        end
        
        
        
        
    end
    
end