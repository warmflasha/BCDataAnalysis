function line = fixcommas(line)
%sets all commas between double quotes to colons
%allows commas to be used as first delimiter and colons as subdelimter
%if there are an odd number of double quotes, ignores the last one

dq_inds = strfind(line,'"');
com_inds = strfind(line,',');

ndq = length(dq_inds);
if ~mod(ndq,2) %if an odd number only go the 2nd to last one
    maxind = ndq;
else
    maxind = ndq-1;
end

for ii = 1:2:maxind
    tofix = com_inds > dq_inds(ii) & com_inds < dq_inds(ii+1);
    line(com_inds(tofix)) = ':';
end

line(dq_inds)=' ';

double_com_inds=strfind(line,',,');
for ii = length(double_com_inds):-1:1
    curr_ind = double_com_inds(ii);
    line = [line(1:curr_ind) ' ' line(curr_ind+1:end)];
end
end
    