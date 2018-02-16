oldestdate = '01-Jan-2017';
datadir = {'CKD Combined'}; % to do multiple directories together, add them here.
metafile = '/Users/aryeh/Dropbox/Braincheck/DementiaAnalysis/metadata_unity.csv';
batteries = makeBatteries(datadir,metafile,oldestdate);
 outfile = 'CKD.mat';
 save(outfile,'batteries');
 %%
%  oldestdate = '01-Jan-2016';
% datadir = {'alldata_research_combined'}; % to do multiple directories together, add them here.
% metafile = 'metadata_unity.csv';
% batteries = makeBatteries(datadir,metafile,oldestdate);
% %%
%  outfile = 'alldata_research_combined.mat';
%  save(outfile,'batteries');
 %%
