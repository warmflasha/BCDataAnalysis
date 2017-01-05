function mm=meannonan(x)

notin=isnan(x) | isinf(x);
x(notin)=[];
mm=mean(x);