function batteries = addUserDataToBatteries(datadir,batteries,metadata)

userfile = dir([datadir filesep 'user*.csv']);
fid = fopen(fullfile(datadir,userfile(1).name),'r');
fgetl(fid); tline = fgetl(fid);

while tline ~= -1
    tline = fixcommas(tline);
    dat=strsplit(tline,',');
    user_id = str2double(dat{1});
    ind = find([batteries.userID]==user_id);
    if ~isempty(ind)
        if exist('metadata','var')
            classToUse = [];
            siteToUse = [];
            tmp1 = dat{22}; tmp2 = dat{23};
            
            %check for classification match to metadata.classification, if so, will overwrite
            %'nrm' with the match
            for ii = 1:length(metadata.classification)
                strtests = lower({tmp1, tmp2});
                is_in = ~cellfun(@isempty,strfind(strtests,lower(metadata.classification{ii})));
                if any(is_in)
                    classToUse= metadata.classification{ii};
                end
            end
            
            %check for site match to metadata.site. will find in
            %site field if match is found.
            for ii = 1:length(metadata.site)
                strtests = {tmp1, tmp2};
                is_in = ~cellfun(@isempty,strfind(strtests,lower(metadata.site{ii})));
                if any(is_in)
                    siteToUse = metadata.site{ii};
                end
            end
            
            for ii = 1:length(metadata.bad)
                strtests = {tmp1, tmp2};
                is_in = strcmpi(strtests,metadata.bad{ii});
                if any(is_in)
                    classToUse = 'Skip';
                end
            end
            
        else
            classToUse = [];
            siteToUse =[];
        end
        for ii = 1:length(ind)
            batteries(ind(ii)).age = dat{25};
            batteries(ind(ii)).gender = dat{26};
            batteries(ind(ii)).classification = classToUse;
            batteries(ind(ii)).site = siteToUse;
        end
    end
    tline = fgetl(fid);
end
