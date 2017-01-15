function [batteries,inds] = filterCompleteBaselineBatteries(batteries,baseval)
%Takes a set of batteries and returns those that are complete and are a
%baseline test. Also returns inds of those batteries in the original array
%baseval indicates whether baseline should be true or false (default true)

if ~exist('baseval','var')
    baseval = true;
end

if baseval
    baseline = [batteries.baseline];
else
    baseline = ~[batteries.baseline];
end

nbat = length(batteries);
iscomplete = false(1,nbat);
for ii = 1:nbat
    iscomplete(ii) = batteries(ii).is_complete;
end
inds = iscomplete & baseline;
batteries = batteries(inds);
