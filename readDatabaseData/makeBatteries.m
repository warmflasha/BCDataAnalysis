function batteries=makeBatteries(datadirs,metadatafile,oldestdate)
% Main function that makes the batteries data structure. datadirs is a cell
% array of folder names containing the data. metadatafile is the name of
% the file containing the metadata, oldestdate is an optional argument.
% Batteries collected before this date will be skipped.

q = 1;

metadata = readMetaDataFile(metadatafile);

if exist('oldestdate','var')
    oldestdate = datenum(oldestdate);
end

for ii = 1:length(datadirs)
    datadir = datadirs{ii};
    f1=dir([datadir filesep 'batter*.csv']);
    f1=f1(1).name;
    fid=fopen([datadir filesep f1],'r');
    tline=fgetl(fid);
    while tline ~=-1
        disp(int2str(q));
        if length(tline) < 50 %too short to be real data.
            tline = fgetl(fid);
            continue;
        end
        newBattery = Battery(tline,metadata);
        %skip if already exists or too old
        if (q == 1 || ~any([batteries.id]==newBattery.id)) &&...
                ~(exist('oldestdate','var') && datenum(newBattery.date)-oldestdate < 0)
            batteries(q) = newBattery;
            q = q+1;
        else
            %if newBattery.admin_by == 1242
            disp(['Skipping battery ' int2str(newBattery.id) ': too old or duplicate']);
            %end
        end
        tline = fgetl(fid);
    end
    batteries = addAssessmentDataToBatteries(datadir,batteries);
    batteries = removeEmptyBatteries(batteries);
    batteries = addSymptomDataToBatteries(datadir,batteries);
    batteries = addUserDataToBatteries(datadir,batteries,metadata);
    
    badinds = false(length(batteries),1);
    for jj = 1:length(batteries)
        try
            batteries(jj) =  bdayToAge(batteries(jj));
        catch
            badinds(jj)=true;
            if batteries(jj).admin_by == 1242
                disp(['Discarding battery ' int2str(batteries(jj).id) ': bad age']);
            end
        end
    end
    batteries(badinds)=[];
    batterylookup = mkBatteryLookup(batteries);
    
    disp('Reading Balance');
    batteries=readBalance(datadir,batteries,batterylookup,ii);
    disp('Reading DigitSpan');
    batteries=readDigitSpan(datadir,batteries,batterylookup,ii);
    disp('Reading DigitSym');
    batteries=readDigitSym(datadir,batteries,batterylookup,ii);
    disp('Reading Recall');
    batteries=readRecall(datadir,batteries,batterylookup,ii);
    disp('Reading Ebbinghaus');
    batteries=readEbbinghaus(datadir,batteries,batterylookup,ii);
    disp('Reading Flanker');
    batteries=readFlanker(datadir,batteries,batterylookup,ii);
    disp('Reading Stroop');
    batteries=readStroop(datadir,batteries,batterylookup,ii);
    disp('Reading Trails');
    batteries=readTrailsAB(datadir,batteries,batterylookup,ii);
    disp('Reading Matrix');
    batteries=readMatrix(datadir,batteries,batterylookup,ii);
    
end

function batteries = removeEmptyBatteries(batteries)

badbatteries = false(length(batteries),1);

for ii = 1:length(batteries)
    if isempty(batteries(ii).assessments) || all(isnan(batteries(ii).assessments))
        badbatteries(ii) = true;
        if batteries(ii).admin_by==1242
            disp(['Removing battery ' int2str(batteries(ii).id) ': Empty battery']);
        end
    end
end

batteries(badbatteries) = [];


function batterylookup = mkBatteryLookup(batteries)
high_assess = max([batteries.assessments]);
batterylookup = -1*ones(high_assess,1);
for ii = 1:length(batteries)
    batterylookup(batteries(ii).assessments) = ii;
end

function batteries=readBalance(datadir,batteries,batterylookup,filenum)
f1=dir([datadir filesep 'balance*.csv']);
f1=f1(1).name;
fid=fopen([datadir filesep f1],'r');
 line=fgetl(fid);

while line ~=-1
    
    %remove "dot position" data
    ind1 = strfind(line,'[');
    ind2 = strfind(line,']');
    
    xydat = line(ind1:ind2);
    
    if isempty(ind1) || isempty(ind2)
        %disp('Here. Lacking balance data. Skipping');
        line = fgetl(fid);
        continue;
    end
    
    line(ind1:ind2)=[];
    
    line = fixcommas(line);
    
    dat=strsplit(line,',');
    assess_num = str2double(dat{2});
    if assess_num <= length(batterylookup)
        batnum=batterylookup(assess_num);
    else
        batnum = 0;
    end
    newBalance = Balance(dat,xydat);
    if batnum > 0
        
        ind = batteries(batnum).assessments == assess_num;
        
        if ~any(ind)
            disp('Warning assessment not found in battery');
            line = fgetl(fid);
            continue;
        elseif batteries(batnum).assessment_present(ind) > 0 && batteries(batnum).assessment_present(ind) < filenum
            line = fgetl(fid);
            continue;
        end
        
        if isempty(batteries(batnum).balance)
            batteries(batnum).balance = newBalance;
        else
            batteries(batnum).balance(end+1)=newBalance;
        end
        batteries(batnum).assessment_present(ind) = filenum;
        batteries(batnum).assessment_type{ind} = 'Balance';
    end
    line=fgetl(fid);
end

function batteries=readDigitSpan(datadir,batteries,batterylookup,filenum)
f1=dir([datadir filesep 'digit_span*.csv']);
f1=f1(1).name;
fid=fopen([datadir filesep f1],'r');
 line=fgetl(fid);

while line ~=-1
    line = fixcommas(line);
    dat=strsplit(line,',');
    assess_num=str2double(dat{2});
    if assess_num <= length(batterylookup)
        batnum=batterylookup(assess_num);
    else
        batnum = 0;
    end
    newDigitSpan = DigitSpan(dat);
    if batnum > 0
        
        ind = batteries(batnum).assessments == assess_num;
        
        if isempty(ind)
            disp('Warning assessment not found in battery');
            line = fgetl(fid);
            continue;
        elseif batteries(batnum).assessment_present(ind) > 0 && batteries(batnum).assessment_present(ind) < filenum
            line = fgetl(fid);
            continue;
        end
        
        if isempty(batteries(batnum).digitSpan)
            batteries(batnum).digitSpan = newDigitSpan;
        else
            batteries(batnum).digitSpan(end+1)=newDigitSpan;
        end
        batteries(batnum).assessment_present(ind) = filenum;
        batteries(batnum).assessment_type{ind} = 'DigitSpan';
    end
    line=fgetl(fid);
end

function batteries=readDigitSym(datadir,batteries,batterylookup,filenum)
f1=dir([datadir filesep 'digit_symbol*.csv']);
f1=f1(1).name;
fid=fopen([datadir filesep f1],'r');
line=fgetl(fid);

while line ~=-1
    line = fixcommas(line);
    
    dat=strsplit(line,',');
    assess_num=str2double(dat{2});
    if assess_num <= length(batterylookup)
        batnum=batterylookup(assess_num);
    else
        batnum = 0;
    end
    if batnum > 0
        
        newDigitSym = DigitSym(dat);
        
        ind = batteries(batnum).assessments == assess_num;
        
        if isempty(ind)
            disp('Warning assessment not found in battery');
            line = fgetl(fid);
            continue;
        elseif batteries(batnum).assessment_present(ind) > 0 && batteries(batnum).assessment_present(ind) < filenum
            line = fgetl(fid);
            continue;
        end
        
        if isempty(batteries(batnum).digitSym)
            batteries(batnum).digitSym = newDigitSym;
        else
            batteries(batnum).digitSym(end+1)=newDigitSym;
        end
        batteries(batnum).assessment_present(ind) = filenum;
        batteries(batnum).assessment_type{ind} = 'DigitSym';
        
        
    end
    line=fgetl(fid);
end

function batteries=readRecall(datadir,batteries,batterylookup,filenum)
f1=dir([datadir filesep '*recall*.csv']);
f1=f1(1).name;
fid=fopen([datadir filesep f1],'r');
 line=fgetl(fid);

while line ~=-1
    line = fixcommas(line);
    
    dat=strsplit(line,',');
    
    assess_num=str2double(dat{2});
    if assess_num <= length(batterylookup)
        batnum=batterylookup(assess_num);
    else
        batnum = 0;
    end
    newRecall = Recall(dat);
    if batnum > 0
        
        ind = batteries(batnum).assessments == assess_num;
        
        if isempty(ind)
            disp('Warning assessment not found in battery');
            line = fgetl(fid);
            continue;
        elseif batteries(batnum).assessment_present(ind) > 0 && batteries(batnum).assessment_present(ind) < filenum
            line = fgetl(fid);
            continue;
        end
        
        if isempty(batteries(batnum).recall)
            batteries(batnum).recall = newRecall;
        else
            batteries(batnum).recall(end+1)=newRecall;
        end
        batteries(batnum).assessment_present(ind) = filenum;
        batteries(batnum).assessment_type{ind} = 'Recall';
        
    end
    line=fgetl(fid);
end

function batteries=readEbbinghaus(datadir,batteries,batterylookup,filenum)
f1=dir([datadir filesep 'ebbinghaus*.csv']);
f1=f1(1).name;
fid=fopen([datadir filesep f1],'r');
line=fgetl(fid);

while line ~=-1
    line = fixcommas(line);
    
    dat=strsplit(line,',');
    
    assess_num=str2double(dat{2});
    if assess_num <= length(batterylookup)
        batnum=batterylookup(assess_num);
    else
        batnum = 0;
    end
    newEbb = Ebbinghaus(dat);
    if batnum > 0
        
        ind = batteries(batnum).assessments == assess_num;
        
        if isempty(ind)
            disp('Warning assessment not found in battery');
            line = fgetl(fid);
            continue;
        elseif batteries(batnum).assessment_present(ind) > 0 && batteries(batnum).assessment_present(ind) < filenum
            line = fgetl(fid);
            continue;
        end
        
        if isempty(batteries(batnum).ebbinghaus)
            batteries(batnum).ebbinghaus = newEbb;
        else
            batteries(batnum).ebbinghaus(end+1)=newEbb;
        end
        batteries(batnum).assessment_present(ind) = filenum;
        batteries(batnum).assessment_type{ind} = 'Ebbinghaus';
        
    end
    line=fgetl(fid);
end

function batteries=readFlanker(datadir,batteries,batterylookup,filenum)
f1=dir([datadir filesep 'flanker*.csv']);
f1=f1(1).name;
fid=fopen([datadir filesep f1],'r');
line=fgetl(fid);

while line ~=-1
    line = fixcommas(line);
    
    dat=strsplit(line,',');
    
    assess_num=str2double(dat{2});
    
    if assess_num <= length(batterylookup)
        batnum=batterylookup(assess_num);
    else
        batnum = 0;
    end
    batnum=batterylookup(assess_num);
    newFlanker = Flanker(dat);
    if batnum > 0
        
        ind = batteries(batnum).assessments == assess_num;
        
        if isempty(ind)
            disp('Warning assessment not found in battery');
            line = fgetl(fid);
            continue;
        elseif batteries(batnum).assessment_present(ind) > 0 && batteries(batnum).assessment_present(ind) < filenum
            line = fgetl(fid);
            continue;
        end
        
        if isempty(batteries(batnum).flanker)
            batteries(batnum).flanker = newFlanker;
        else
            batteries(batnum).flanker(end+1)=newFlanker;
        end
        batteries(batnum).assessment_present(ind) = filenum;
        batteries(batnum).assessment_type{ind} = 'Flanker';
        
    end
    line=fgetl(fid);
end

function batteries=readMatrix(datadir,batteries,batterylookup,filenum)
f1=dir([datadir filesep 'matrix*.csv']);
f1=f1(1).name;
fid=fopen([datadir filesep f1],'r');
line=fgetl(fid);

while line ~=-1
    line = fixcommas(line);
    
    dat=strsplit(line,',');
    assess_num=str2double(dat{2});
    if assess_num <= length(batterylookup)
        batnum=batterylookup(assess_num);
    else
        batnum = 0;
    end
    newMatrix = Matrix(dat);
    if batnum > 0
        
        ind = batteries(batnum).assessments == assess_num;
        
        if isempty(ind)
            disp('Warning assessment not found in battery');
            line = fgetl(fid);
            continue;
        elseif batteries(batnum).assessment_present(ind) > 0 && batteries(batnum).assessment_present(ind) < filenum
            line = fgetl(fid);
            continue;
        end
        
        if isempty(batteries(batnum).matrix)
            batteries(batnum).matrix = newMatrix;
        else
            batteries(batnum).matrix(end+1)=newMatrix;
        end
        batteries(batnum).assessment_present(ind) = filenum;
        batteries(batnum).assessment_type{ind} = 'Matrix';
        
    end
    line=fgetl(fid);
end

function batteries=readStroop(datadir,batteries,batterylookup,filenum)
f1=dir([datadir filesep 'stroop*.csv']);
if isempty(f1)
    return;
end

f1=f1(1).name;
fid=fopen([datadir filesep f1],'r');
line=fgetl(fid);

while line ~=-1
    line = fixcommas(line);
    
    dat=strsplit(line,',');
    assess_num=str2double(dat{2});
    if assess_num <= length(batterylookup)
        batnum=batterylookup(assess_num);
    else
        batnum = 0;
    end
    newStroop = Stroop(dat);
    if batnum > 0
        
        ind = batteries(batnum).assessments == assess_num;
        
        if isempty(ind)
            disp('Warning assessment not found in battery');
            line = fgetl(fid);
            continue;
        elseif batteries(batnum).assessment_present(ind) > 0 && batteries(batnum).assessment_present(ind) < filenum
            line = fgetl(fid);
            continue;
        end
        
        if isempty(batteries(batnum).stroop)
            batteries(batnum).stroop = newStroop;
        else
            batteries(batnum).stroop(end+1)=newStroop;
        end
        batteries(batnum).assessment_present(ind) = filenum;
        batteries(batnum).assessment_type{ind} = 'Stroop';
        
    end
    line=fgetl(fid);
end

function batteries=readTrailsAB(datadir,batteries,batterylookup,filenum)
f1=dir([datadir filesep 'trails_ab*.csv']); %NOTE: FILE WAS NAMED "trails..."

if isempty(f1)
    return;
end

f1=f1(1).name;
fid=fopen([datadir filesep f1],'r');
 line=fgetl(fid);



while line ~=-1
    line = fixcommas(line);
    
    dat=strsplit(line,',');
    assess_num=str2double(dat{2});
    if assess_num <= length(batterylookup)
        batnum=batterylookup(assess_num);
    else
        batnum = 0;
    end
    newAB = TrailsAB(dat);
    if batnum > 0
        
        ind = batteries(batnum).assessments == assess_num;
        
        if isempty(ind)
            disp('Warning assessment not found in battery');
            line = fgetl(fid);
            continue;
        elseif batteries(batnum).assessment_present(ind) > 0 && batteries(batnum).assessment_present(ind) < filenum
            line = fgetl(fid);
            continue;
        end
        
        if isempty(batteries(batnum).trailsAB)
            batteries(batnum).trailsAB = newAB;
        else
            batteries(batnum).trailsAB(end+1)=newAB;
        end
        batteries(batnum).assessment_present(ind) = filenum;
        batteries(batnum).assessment_type{ind} = 'TrailsAB';
        
    end
    line=fgetl(fid);
end


function battery = bdayToAge(battery)

age = (datenum(strrep(battery.date,'UTC',''))-datenum(battery.age))/365;
if age < 0
    age = age + 100;
end
battery.age = age;

%
% function newstr = convertDateString(dstring)
%
% dstring = strrep(dstring,'-',' ');
% dd = strsplit(dstring,' ');
% empties = [cellfun(@isempty,dd)];
% dd(empties)=[];
% newstr = [dd{2}(1:2) '-' dd{1}(1:3) '-' dd{3}(end-1:end)];

