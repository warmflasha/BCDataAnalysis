classdef Flanker
    %Data class to store Flanker results
    properties
        trial_type
        trial_number
        cue_type
        correct
        duration
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %BEGIN METHODS        %%
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        %constructor function from a line of data
        function obj=Flanker(line)
            if iscell(line)
                dat=line;
            else
                dat=strsplit(line,',');
            end
            if strcmpi(dat{6}(1),'T')
                obj.correct = true;
            elseif strcmpi(dat{6}(1),'F')
                obj.correct = false;
            end
            obj.trial_number = str2double(dat{5});
            ct = str2double(dat{4});
            if ct == 1
                obj.cue_type = 'C';
            elseif ct == 2
                obj.cue_type = 'S';
            end
            tt = str2double(dat{3});
            if tt == 1
                obj.trial_type = 'C';
            elseif tt == 2
                obj.trial_type = 'I';
            end
            obj.duration = str2double(dat{7});
        end
    end    
end