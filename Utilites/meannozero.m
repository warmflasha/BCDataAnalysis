function mm=meannozero(x,maxx)

notin=isnan(x) | isinf(x) | x == 0;
if exist('maxx','var')
    notin = notin | x > maxx;
end
x(notin)=[];
mm=mean(x);