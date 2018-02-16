load('Manuscript_final_data/alldata.mat');
%%
normal = false(length(batteries),1);
concuss = normal;
control = normal;
for ii = 1:length(batteries)
    if batteries(ii).is_complete && ~isempty(strfind(lower(batteries(ii).classification),'nrm'))
        normal(ii) = true;
    elseif batteries(ii).is_complete && ~isempty(strfind(lower(batteries(ii).classification),'concus'))
        concuss(ii) = true;
    elseif batteries(ii).is_complete && ~isempty(strfind(lower(batteries(ii).classification),'contr'))
        control(ii) = true;
    end
end
%% export the data
propToUse = {'age','gender'};
methodsToUse = {'flanker_reaction_time_correct_median','digit_symbol_duration_median','stroop_reaction_time',...
    'trails_cognitive_time_sec_median','trails_executive_time_sec_median','balance(1).mean_dist_from_center/100','recall_fraction_correct'...
    'evidence_for_malingering'};
allToUse = {propToUse{:}, methodsToUse{:}};
exportDataToCsv('normative.csv',batteries(normal),allToUse);
%%
exportDataToCsv('control.csv',batteries(control),allToUse);
%%
exportDataToCsv('concuss.csv',batteries(concuss),allToUse);
