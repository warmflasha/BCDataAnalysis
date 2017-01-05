classdef Balance
    %Data class to store Balance  results
    properties
        duration_in_target
        duration_out_target
        mean_position
        standard_deviation
        time_unpressed
        number_exits
        xy_data
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %BEGIN METHODS        %%
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        %constructor function from a line of data
        %NOTE: duration does not appear to be in the data file
        function obj=Balance(line,xydat)
            if iscell(line)
                dat=line;
            else
                dat=strsplit(line,',');
            end
            obj.duration_in_target=str2double(dat{4});
            obj.duration_out_target=str2double(dat{5});
            obj.mean_position=str2double(dat{6});
            obj.standard_deviation=str2double(dat{7});
            obj.time_unpressed=str2double(dat{8});
            obj.number_exits=str2double(dat{9});
            if length(xydat) > 1
                xydat = xydat(2:end-1);
                xydat = strrep(xydat,'"','');
                xydat = strrep(xydat,'x=>','');
                xydat = strrep(xydat,'y=>','');
                xydat = strrep(xydat,'{','');
                xydat = strrep(xydat,'}','');
                xydat = strsplit(xydat,',');
                xydat = cellfun(@str2double,xydat);
                obj.xy_data = [xydat(1:2:end)' xydat(2:2:end)'];
                
            end
            
        end
        
        function pit = percent_in_target(obj)
            pit=obj.duration_in_target/(obj.duration_in_target+obj.duration_out_target);
        end
        
        function mxy = mean_dist_from_center(obj)
            dat = obj.xy_data;
            mxy = mean(sqrt(sum(dat.*dat,2)));
            
        end
        
        function td = total_dist(obj)
            dat = obj.xy_data;
            dat = diff(dat);
            td = sum(sqrt(sum(dat.*dat,2)));
            
        end
    end
    
end