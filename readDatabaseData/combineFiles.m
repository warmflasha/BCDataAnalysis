function combineFiles(direc,keyword,outfile)
%Function to combine data files. Will join all files in directory direc
%with file name containing keyword into 1 file - outfile. 


filesToCombine = dir([direc filesep keyword '*']);

fid_out = fopen(outfile,'w');

for ii=1:length(filesToCombine)
    %skip the _types_ files
    if ~isempty(strfind(filesToCombine(ii).name,'types'))
        continue;
    end
    fid = fopen([direc filesep filesToCombine(ii).name],'r');
    fgetl(fid); tline = fgetl(fid);
    while tline ~= -1
        fprintf(fid_out,'%s\n',tline);
        tline = fgetl(fid);
    end
    fclose(fid);
end
fclose(fid_out);