% Script to combine data. All files in directory direc containing the
% keywords on the list will be combined into a file in outdirec with the
% name in the corresponding entry in outfiles. 


indirec = 'CKD';
outdirec = 'CKD Combined';
keywords = {'batteries','balanc','delayed','digit_span','digit_sym','ebbing','flanker',...
    'stroop','trails','assessments','symptoms','users_2','matrix'};
outfiles = {'battery','balance','recall','digit_span','digit_symbol','ebbinghaus',...
    'flanker','stroop','trails_ab','assessments','symptoms','users','matrix'};

%make the output directory if necessary
if ~exist(outdirec,'file')
    mkdir(outdirec);
end

for ii = 1:length(keywords)
    combineFiles(indirec,keywords{ii},[outdirec filesep outfiles{ii} '.csv']);
end