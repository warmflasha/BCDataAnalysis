function [batteries, inds] = filterBatteriesByOrg(batteries,orgNumList)
% Return only those batteries with organization ID on the list. List is an
% array input as orgNumList. Also returns inds of those batteries in the
% original battery array 

nbat = length(batteries);
inds = false(nbat,1);
for ii = 1:nbat
    inds(ii) = ismember(batteries(ii).organizationID,orgNumList);
end

batteries = batteries(inds);
