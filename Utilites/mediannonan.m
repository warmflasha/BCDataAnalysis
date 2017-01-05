function mm=mediannonan(x)

notin=isnan(x) | isinf(x);
x(notin)=[];
mm=median(x);