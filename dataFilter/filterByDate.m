function batteries = filterByDate(batteries,oldestdate)
%filters battery data by date. oldestdate is the oldest date of data to
%use.

isgood = false(length(batteries),1);
oldestdatenum = datenum(oldestdate);
for ii = 1:length(batteries)
    batdatenum = datenum(batteries(ii).date);
    if batdatenum - oldestdatenum > 0
        isgood(ii) = true;
    end
end
batteries = batteries(isgood);


