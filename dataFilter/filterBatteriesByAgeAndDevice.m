function [batteries, inds] = filterBatteriesByAgeAndDevice(batteries,ageRange,deviceType)
% Return only those batteries with ages between ageRange(1) and ageRange(2) (inclusive of lower
% but not upper bound), and deviceType indicated (0=iphone, 1=ipad, 2=browser)
%Also returns inds of those batteries in theoriginal battery array 

ages = [batteries.age];
deviceTypes = [batteries.deviceType];

inds = ages >= ageRange(1) & ages < ageRange(2) & deviceTypes == deviceType;

batteries = batteries(inds);