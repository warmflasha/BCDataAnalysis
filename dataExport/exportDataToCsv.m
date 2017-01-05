function exportDataToCsv(csvfile,batteries,methodnames,columnheaders)
%Export the data in batteries to a .csv file. methodnames gives names of
%properties or methods to run. optional argument columnheaders will be
%printed on top of columns. If absent will print method names. If 'none'
%will skip.

fid = fopen(csvfile,'w');

if ~exist('columnheaders','var')
    columnheaders = methodnames;
end

ncol = length(columnheaders);

if iscell(columnheaders) && length(columnheaders) == length(methodnames)
    for ii = 1:ncol
        fprintf(fid,'%s',columnheaders{ii});
        if ii < ncol
            fprintf(fid,',');
        else
            fprintf(fid,'\n');
        end
    end
elseif ~strcmpi(columnheaders,'none')
    disp('Warning: Invalid column header. Must be cell of length of methodnames or ''none''');
end


ncol = length(methodnames);
for jj = 1:length(batteries)
    disp(['Exporting battery ' int2str(jj)]);
    for ii = 1:ncol
        try
            valtoprint = eval(['batteries(jj).' methodnames{ii} ';']);
            if isnumeric(valtoprint)
                valtoprint = num2str(valtoprint);
            end
            fprintf(fid,'%s',valtoprint);
            
        catch
            fprintf(fid,'NoValue');
        end
        if ii < ncol
            fprintf(fid,',');
        else
            fprintf(fid,'\n');
        end
    end
    
end

fclose(fid);