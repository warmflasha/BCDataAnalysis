oldestdate = '01-Jul-2016';
datadir = {'jan_combined'}; % to do multiple directories together, add them here.
metafile = 'metadata_unity.csv';
batteries = makeBatteries(datadir,metafile,oldestdate);
%%
outfile = 'jan_data.mat';
save(outfile,'batteries');