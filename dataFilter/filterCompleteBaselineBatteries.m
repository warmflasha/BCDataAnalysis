function [batteries,inds] = filterCompleteBaselineBatteries(batteries)
%Takes a set of batteries and returns those that are complete and are a
%baseline test. Also returns inds of those batteries in the original array

baseline = [batteries.baseline];
nbat = length(batteries);
iscomplete = false(1,nbat);
for ii = 1:nbat
    iscomplete(ii) = batteries(ii).is_complete;
end
inds = iscomplete & baseline;
batteries = batteries(inds);
