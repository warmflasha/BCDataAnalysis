function outTests=sortTestRetest(batteries,onlymultiple)
%Function to sort data for test-retest. Takes input as batteries and
%outputs cell array where each cell contains batteries with the same userID
%sorted by date (oldest test first).
% onlymultiple is a flag to return only those batteries for users who have
% taken more than once (useful for test-retest compare). Default is true.

if ~exist('onlymultiple','var')
    onlymultiple = true;
end

uIds = [batteries.userID];
done = false(length(uIds),1);
q = 1;
for ii = 1:length(uIds)
    if done(ii)
        continue;
    end
    ids_now = uIds == uIds(ii);
    done(ids_now) = true;
    n_test = sum(ids_now);
    if n_test > 1
        tdate = cell(n_test,1);
        inds = find(ids_now);
        for jj = 1:n_test
            %tdate{jj}=convertDateString(batteries(inds(jj)).date);
            tdate{jj}=batteries(inds(jj)).date;
        end
        datenums = cellfun(@datenum,tdate);
        [~, inds2] = sort(datenums);
        outTests{q}=batteries(inds(inds2));
        q = q + 1;
    elseif n_test == 1 && ~onlymultiple %there is only 1 test for this user, but we are returning all
        outTests{q} = batteries(ids_now);
        q = q + 1;
    end
end



function newstr = convertDateString(dstring)

dd = strsplit(dstring,' ');
empties = cellfun(@isempty,dd);
dd(empties)=[];
newstr = [dd{2}(1:2) '-' dd{1}(1:3) '-' dd{3}(end-1:end) ' ' dd{4}];