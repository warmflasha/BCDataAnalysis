function batteries = addAssessmentDataToBatteries(datadir,batteries)

assessfile = dir([datadir filesep 'assess*.csv']);
fid = fopen(fullfile(datadir,assessfile(1).name),'r');
fgetl(fid); tline = fgetl(fid);

while tline ~= -1
    tline = fixcommas(tline);
    dat=strsplit(tline,',');
    battery_id = str2double(dat{3});
    ind = find([batteries.id]==battery_id);
    if ~isempty(ind) && ~any(ismember(batteries(ind).assessments,str2double(dat{1})))
        batteries(ind).assessments = [batteries(ind).assessments str2double(dat{1})];
        batteries(ind).version{end+1} = dat{6};
    end
    tline = fgetl(fid);
end

for ii = 1:length(batteries)
    for jj = 1:length(batteries(ii).assessments)
        batteries(ii).assessment_type{jj}='';
    end
    batteries(ii).assessment_present = false(length(batteries(ii).assessments),1);
end