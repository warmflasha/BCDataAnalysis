classdef Recall
    %Data class to store Recall results
    properties
        trial_number
        trial_type
        trial_duration
        correct
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %BEGIN METHODS        %%
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        %constructor function from a line of data
        function obj=Recall(line)
            if iscell(line)
                dat=line;
            else
                dat=strsplit(line,',');
            end
            obj.trial_number = str2double(dat{3});
            obj.trial_duration=str2double(dat{5});
            tt = str2double(dat{9});
            if tt == 2
                obj.trial_type = 'A';
            elseif tt == 3
                obj.trial_type = 'B';
            end
                
            if strcmpi(dat{4}(1),'T')
                obj.correct = 1;
            elseif strcmpi(dat{4}(1),'F')
                obj.correct = 0;
            end
    
        end
    end
        
        
        
            
end