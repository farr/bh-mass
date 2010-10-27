function pdf = skewGaussian(xi, omega, alpha, x)
    arg = (x-xi)/omega;
    pdf = 2/omega.*normpdf(arg,0,1).*normcdf(alpha.*arg);
end