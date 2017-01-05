function batteries = addSymptomDataToBatteries(datadir,batteries)

symptomfile = dir([datadir filesep 'symptom*.csv']);
fid = fopen(fullfile(datadir,symptomfile(1).name),'r');
fgetl(fid); tline = fgetl(fid);

while tline ~= -1
    tline = fixcommas(tline);
    dat=strsplit(tline,',');
    battery_id = str2double(dat{14});
    ind = find([batteries.id]==battery_id);
    if ~isempty(ind)
        batteries(ind).symptomID = str2double(dat{1});
        batteries(ind).symptoms = cellfun(@str2double,dat(2:13));
    end
    tline = fgetl(fid);
end