oldestdate = '01-Jul-2016';
datadir = {'oct_combined'}; % to do multiple directories together, add them here.
metafile = 'metadata_unity.csv';
batteries = makeBatteries(datadir,metafile,oldestdate);
%%
outfile = 'oct_data.mat';
save(outfile,'batteries');