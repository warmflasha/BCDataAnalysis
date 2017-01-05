classdef Battery < handle
    %Data class to store a battery of tests
    properties
        assessments
        assessment_present
        assessment_type
        date
        userID
        organizationID
        age
        gender
        type
        version
        device
        deviceType
        plan
        classification
        admin_by
        site
        id
        ebbinghaus
        recall
        digitSym
        flanker
        trailsAB
        digitSpan
        stroop
        balance
        symptomID
        symptoms
        compositeScore
        baseline
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %BEGIN METHODS        %%
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        %constructor function with a single integer, otherwise makes an
        %empty object
        
        
        function obj=Battery(varargin)
            % can have 1 or two arguments. first argument is dataline from
            % batteries data file. 2nd is metadata which will be used to
            % match the admin_by,classification, and site fields.
            % metadata is created by readMetaDataFile.m
            if nargin > 0
                tline = varargin{1};
                tline = fixcommas(tline);
                sline = strsplit(tline,',');
                obj.id = str2double(sline{1}); %battery ID
                obj.date = sline{4}; %administered at
                obj.userID = str2double(sline{2});
                obj.admin_by = str2double(sline{5}); %now an integer, admin_id
                obj.device = str2double(sline{9}); %confirm
                obj.organizationID = str2double(sline{10});
                tmp = lower(sline{16});
                tmp = strtrim(tmp);
                if length(tmp) > 4
                    tmp = tmp(1:4);
                end
                if strcmpi(tmp,'ipad')
                    obj.deviceType = 1;
                elseif strcmpi(tmp,'debu') %this is Flanker with mouse
                    obj.deviceType = 20;
                elseif strcmpi(tmp,'brow') %this is Flanker with keyboard
                    obj.deviceType = 2;
                else
                    obj.deviceType = 0;
                end
                if strcmpi(sline{11}(1),'t')
                    obj.baseline =true;
                else
                    obj.baseline = false;
                end
                type = str2double(sline{3});
                if type == 1
                    obj.type = 'concussion';
                elseif type == 2
                    obj.type = 'dementia';
                end
            end
            if nargin > 1
                %check if admin_by field matches anything in
                %metadata.email. if so, will classify as 'nrm'
                metadata = varargin{2};
                if any(metadata.email == obj.admin_by )
                    if obj.admin_by == 1242
                        disp(['here: b_id = ' int2str(obj.id)]);
                    end
                    obj.classification = 'nrm';
                end
            end
        end
        
        %A battery is complete if it contains all assessments
        function comp = is_complete(obj)
            if ~isempty(obj.ebbinghaus) && ~isempty(obj.digitSym) && ~isempty(obj.flanker) ...
                    && ~isempty(obj.trailsAB) && ~isempty(obj.stroop)...
                    && ~isempty(obj.recall) %&&   ~isempty(obj.balance)
                comp = true;
            else
                comp=false;
            end
        end
        
        %Removes Flanker reaction times more than 3 sds from the mean
        function obj=removeBadFlankerData(obj)
            tt = [obj.flanker.duration];
            badinds = find(tt > meannonan(tt)+3*std(tt) | tt < meannonan(tt)-3*std(tt));
            for ii=1:length(badinds)
                obj.flanker(badinds(ii)).duration = NaN;
            end
        end
        
        function ntrials=flanker_number_trials(obj)
            ntrials=length(obj.flanker);
        end
        
        function ncorr=flanker_number_correct(obj)
            ncorr=sum([obj.flanker.correct]);
        end
        
        function rtc=flanker_reaction_time_correct(obj)
            inds=[obj.flanker.correct];
            dur=[obj.flanker.duration];
            rtc=meannonan(dur(inds));
        end
        
        function rtc=flanker_reaction_time_correct_median(obj)
            %needs to be at least 80% correct to score. otherwise NaN.
            
            if obj.flanker_fraction_correct > 0.8
                inds=[obj.flanker.correct];
                dur=[obj.flanker.duration];
                rtc=median(dur(inds));
            else
                rtc = NaN;
            end
        end
        
        function rtc=flanker_reaction_time_correct_meann(obj)
            %needs to be at least 80% correct to score. otherwise NaN.
            
            if obj.flanker_fraction_correct > 0.8
                inds=[obj.flanker.correct];
                dur=[obj.flanker.duration];
                rtc=mean(dur(inds));
            else
                rtc = NaN;
            end
        end
        function rti=flanker_reaction_time_incorrect(obj)
            inds=[obj.flanker.correct];
            dur=[obj.flanker.duration];
            rti=meannonan(dur(~inds));
        end
        
        function rtc=flanker_reaction_time_central(obj)
            inds=[obj.flanker.cue_type]=='C';
            dur=[obj.flanker.duration];
            rtc=meannonan(dur(inds));
        end
        
        function rts=flanker_reaction_time_spatial(obj)
            inds=[obj.flanker.cue_type]=='S';
            dur=[obj.flanker.duration];
            rts=meannonan(dur(inds));
        end
        
        function rtc=flanker_reaction_time_congruent(obj)
            inds=[obj.flanker.trial_type]=='C';
            dur=[obj.flanker.duration];
            rtc=meannonan(dur(inds));
        end
        
        function rti=flanker_reaction_time_incongruent(obj)
            inds=[obj.flanker.trial_type]=='I';
            dur=[obj.flanker.duration];
            rti=meannonan(dur(inds));
        end
        
        function oe=flanker_orienting_effect_mean(obj)
            oe=obj.flanker_reaction_time_central-obj.flanker_reaction_time_spatial;
        end
        
        function ee=flanker_executive_effect_mean(obj)
            ee=obj.flanker_reaction_time_incongruent-obj.flanker_reaction_time_congruent;
        end
        
        function fc=flanker_fraction_correct(obj)
            fc=obj.flanker_number_correct/obj.flanker_number_trials;
        end
        
        % Digit Symbol - computes median trial duration
        function md=digit_symbol_duration_median(obj)
            dur=[obj.digitSym.duration];
            md=median(dur);
        end
        
        function cpsm = digit_symbol_correct_per_second_mean(obj)
            dur = [obj.digitSym.duration];
            ntrial = length(obj.digitSym);
            cpsm = ntrial/sum(dur);
        end
        %Removes Trails reaction times more than 3 sds from the mean
        function obj=removeBadTrailsData(obj)
            tt = [obj.trailsAB.duration];
            badinds = find(tt > meannonan(tt)+3*std(tt) | tt < meannonan(tt)-3*std(tt));
            for ii=1:length(badinds)
                obj.trailsAB(badinds(ii)).duration = NaN;
            end
        end
        
        % Trails AB - computes the mean trial duration for trails A
        function ct=trails_cognitive_time_sec_mean(obj)
            if isempty(obj.trailsAB)
                disp('No Trails AB data for this battery.');
                return;
            else
                inds=[obj.trailsAB.test_type]=='A';
                tt=[obj.trailsAB.duration];
                ct=meannonan(tt(inds));
            end
        end
        
        % Trails B - computes the mean trial duration for trails B
        function et=trails_executive_time_sec_mean(obj)
            if isempty(obj.trailsAB)
                disp('No Trails AB data for this battery.');
                return;
            else
                inds=[obj.trailsAB.test_type]=='B';
                tt=[obj.trailsAB.duration];
                et=meannonan(tt(inds));
            end
        end
        
        % Trails AB - computes the mean trial duration for trails A
        function ct=trails_cognitive_time_sec_median(obj)
            if isempty(obj.trailsAB)
                disp('No Trails AB data for this battery.');
                return;
            else
                inds=[obj.trailsAB.test_type]=='A';
                tt=[obj.trailsAB.duration];
                ct=mediannonan(tt(inds));
            end
        end
        
        % Trails B - computes the mean trial duration for trails B
        function et=trails_executive_time_sec_median(obj)
            if isempty(obj.trailsAB)
                disp('No Trails AB data for this battery.');
                return;
            else
                inds=[obj.trailsAB.test_type]=='B';
                tt=[obj.trailsAB.duration];
                et=mediannonan(tt(inds));
            end
        end
        % Ebbinghaus Effect - computes the average of the radius_difference for the trial type = 2
        % *** Note: The letters are backwards in the data, so changed this when reading in the data.
        % Now  1?>?C? and 2?> ?E? so ebbinghaus effect from ?E? is correct.
        function ec=ebbinghaus_effect_mean(obj)
            eb=obj.ebbinghaus;
            if isempty(eb)
                disp('No Ebbinghaus data for this battery');
                return;
            else
                trial_types=[eb.trial_type];
                inds= trial_types=='E';
                rad=[eb.radius_difference];
                ec=meannonan(rad(inds));
            end
        end
        
        % Evidence for malingering - computes the average of the radius_difference for the trial type = 1
        function efm=evidence_for_malingering(obj)
            eb=obj.ebbinghaus;
            if isempty(eb)
                disp('No Ebbinghaus data for this battery');
                return;
            else
                trial_types=[eb.trial_type];
                inds= trial_types=='C';
                rad=[eb.radius_difference];
                efm=meannonan(rad(inds));
            end
        end
        
        % Immediate and Delayed Recall - computes fraction correct by trial type
        % NOTE: Some batteries have multiple assessment numbers assigned to Recall.
        % Appears that type A and type B were called separate assessments.
        % We take care of this by concatenating all data and recording both assessment numbers.
        function fc = recall_fraction_correct(obj)
            ntotal = length(obj.recall);
            ncorrect = sum([obj.recall.correct]);
            fc = ncorrect/ntotal;
        end
        
        function fc=immediate_recall_fraction_correct(obj)
            inds = [obj.recall.trial_type] == 'A';
            ntotal = sum(inds);
            ncorrect = sum([obj.recall(inds).correct]);
            fc=ncorrect/ntotal;
        end
        
        function nc=immediate_recall_correct(obj)
            inds = [obj.recall.trial_type] == 'A';
            nc = sum([obj.recall(inds).correct]);
        end
        
        function fc=delayed_recall_fraction_correct(obj)
            inds = [obj.recall.trial_type] == 'B';
            ntotal = sum(inds);
            ncorrect = sum([obj.recall(inds).correct]);
            fc=ncorrect/ntotal;
        end
        
        function nc = delayed_recall_correct(obj)
            inds = [obj.recall.trial_type] == 'B';
            nc = sum([obj.recall(inds).correct]);
        end
        % Max Digit Span - Simon test
        function mds = digitSpan_max(obj)
            if isempty(obj.digitSpan)
                disp('No digit span data for this object');
                return;
            else
                inds=[obj.digitSpan.correct];
                sl=[obj.digitSpan.string_length];
                mds=max(sl(inds));
            end
        end
        
        % Stroop - Computes Stroop variables for the two test versions.
        % stroop_effect_ratio is implemented as ratio of N and C (note there is no I in the version 2 dataset)
        % Implemented recording 1 as ?N? and 3 as ?C?.
        function ver = stroop_version(obj)
            stroop_ind = ~cellfun(@isempty,strfind(obj.assessment_type,'Stroop'));
            ver = obj.version(stroop_ind);
        end
        
        function snt = stroop_number_trials(obj)
            if isempty(obj.stroop)
                disp('No Stroop data for this battery');
                return;
            else
                snt=length(obj.stroop);
            end
        end
        
        function sni=stroop_number_incorrect(obj)
            if isempty(obj.stroop)
                disp('No Stroop data for this battery');
                return;
            else
                sni=sum([obj.stroop.number_attempts])-obj.stroop_number_trials;
            end
        end
        
        function sbrt = stroop_basic_reaction_time_mean(obj)
            if isempty(obj.stroop)
                disp('No Stroop data for this battery');
                return;
            else
                inds=[obj.stroop.trial_type]=='N';
                tt=[obj.stroop.reaction_time];
                sbrt=meannonan(tt(inds));
            end
        end
        
        function sbrt = stroop_C_reaction_time(obj)
            if isempty(obj.stroop)
                disp('No Stroop data for this battery');
                return;
            else
                inds=[obj.stroop.trial_type]=='C';
                tt=[obj.stroop.reaction_time];
                sbrt=meannonan(tt(inds));
            end
        end
        
         function sbrt = stroop_reaction_time_incongruent_median(obj)
            if isempty(obj.stroop)
                disp('No Stroop data for this battery');
                return;
            else
                inds=[obj.stroop.trial_type]=='C';
                tt=[obj.stroop.reaction_time];
                sbrt=mediannonan(tt(inds));
            end
        end
        
        function sbrt = stroop_reaction_time(obj)
            if isempty(obj.stroop)
                disp('No Stroop data for this battery');
                return;
            else
                tt=[obj.stroop.reaction_time];
                sbrt=meannonan(tt);
            end
        end
        
        function se = stroop_effect_ms_mean(obj)
            if isempty(obj.stroop)
                disp('No Stroop data for this battery');
                return;
            else
                tt=[obj.stroop.reaction_time];
                inds=[obj.stroop.trial_type]=='N';
                sbri=meannonan(tt(inds));
                inds=[obj.stroop.trial_type]=='C';
                sbrc=meannonan(tt(inds));
                se=sbri-sbrc;
            end
        end
        
        function ser = stroop_effect_ratio(obj)
            if isempty(obj.stroop)
                disp('No Stroop data for this battery');
                return;
            else
                tt=[obj.stroop.reaction_time];
                inds=[obj.stroop.trial_type]=='N';
                sbrn=meannonan(tt(inds));
                inds=[obj.stroop.trial_type]=='C';
                sbrc=meannonan(tt(inds));
                % change this line to reflect different variables
                ser=sbrn/sbrc;
            end
        end
        
        % Balance - only good for v2 and v3
        function ver = balance_version(obj)
            balance_ind = ~cellfun(@isempty,strfind(obj.assessment_type,'Balance'));
            ver = obj.version(balance_ind);
        end
        
        function mdist = balance_mean_distance_from_center(obj)
            nbal = length(obj.balance);
            mdist_all = zeros(nbal,1);
            for ii = 1:length(nbal)
                mdist_all(ii) = obj.balance(ii).mean_dist_from_center;
            end
            mdist = mean(mdist_all);
            
        end
        function mdist = balance_percent_in_target_mean(obj)
            nbal = length(obj.balance);
            mdist_all = zeros(nbal,1);
            for ii = 1:length(nbal)
                mdist_all(ii) = obj.balance(ii).percent_in_target;
            end
            mdist = mean(mdist_all);
            
        end
    end
end

