function outdat=makeDataFromMethodNames(batteries,methodnames)

nbatteries = length(batteries);
nmethods = length(methodnames);

outdat = zeros(nbatteries,nmethods);

for bb=1:nbatteries
    for mm=1:nmethods
        try
            outp =eval(['batteries(' int2str(bb) ').' methodnames{mm}]);
            if ~isempty(outp)
                outdat(bb,mm)=outp;
            else
                outdat(bb,mm)=NaN;
            end
        catch
            outp=NaN;
        end
    end
end