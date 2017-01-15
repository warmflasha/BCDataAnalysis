%% load the data
outfile = 'jan_data.mat';
load(outfile);
%% filter the data
%orgList = [2666, 2671, 2694, 2806, 2821, 2918, 2977, 2708, 2815, 2787,
%2785, 2760, 2784, 2707, 2783]; % old data
%orgList = [2821, 2918, 2977]; %Rice data
orgList = [2819, 2820, 2920, 2921, 2922, 2924:2966]; %Rice self-admin
batteries = filterCompleteBaselineBatteries(batteries);
batteries =filterBatteriesByOrg(batteries,orgList);
%% export the data
propToUse = {'id','userID','organizationID','age','gender','type','device','deviceType','plan','classification'...
    'admin_by','site','baseline'};
methodsToUse = {'balance_mean_distance_from_center','balance_percent_in_target_mean','delayed_recall_correct',...
'delayed_recall_fraction_correct','digit_symbol_correct_per_second_mean','digit_symbol_duration_median',...
'ebbinghaus_effect_mean','flanker_executive_effect_mean','flanker_orienting_effect_mean'...
'flanker_reaction_time_correct_mean','flanker_reaction_time_correct_median','immediate_recall_correct',...
'immediate_recall_fraction_correct','stroop_basic_reaction_time_mean','stroop_effect_ms_mean','stroop_effect_ratio',...
'stroop_reaction_time_incongruent_median','trails_cognitive_time_sec_mean','trails_executive_time_sec_mean'...
'trails_cognitive_time_sec_median','trails_executive_time_sec_median','evidence_for_malignering'};
allToUse = {propToUse{:}, methodsToUse{:}};
exportDataToCsv('jan_data.csv',batteries,allToUse);