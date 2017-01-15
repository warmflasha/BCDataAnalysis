function batteriesFirst = filterByFirstBattery(batteries,batnum)
%filtered batteries contains only the first battery for each user. batnum 
%allows to filter by a different battery number (e.g. 2nd). default is 1. 

if ~exist('batnum','var')
    batnum = 1;
end
batteriesTestRetest = sortTestRetest(batteries,false); %sort by user
batteriesFirst = cellfun( @(x) x(batnum),batteriesTestRetest,'UniformOutput',false); % take the first one
batteriesFirst = [batteriesFirst{:}]; %cell array to array of objects