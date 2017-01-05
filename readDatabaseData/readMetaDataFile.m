function metadata = readMetaDataFile(metadatafile)

fid = fopen(metadatafile,'r');
fgetl(fid); fgetl(fid);
line = fgetl(fid);
q = 1;
while line ~= -1
    line = strrep(line,',,,',',placeholder,placeholder,');
    line = strrep(line,',,',',placeholder,');
    sline = strsplit(line,',');
    metadata.email{q} = str2double(sline{1});
    metadata.classification{q} = sline{2};
    metadata.site{q} = sline{3};
    metadata.bad{q} = sline{4};  
    line = fgetl(fid);
    q = q + 1;
end
metadata.email = cell2mat(metadata.email);